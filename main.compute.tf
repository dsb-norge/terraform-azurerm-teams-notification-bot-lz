#
# app service plan and function app
#

resource "azurerm_service_plan" "bot" {
  location            = var.location
  name                = module.naming.app_service_plan.name
  os_type             = "Linux"
  resource_group_name = var.resource_group_name
  sku_name            = "FC1" # Flex Consumption (the only FC tier) — serverless, per-execution billing with always-ready instance support and VNet integration. Instance size is controlled by instanceMemoryMB, not the SKU.
  tags                = local.common_tags

  lifecycle {
    create_before_destroy = true # prevent replacement failures when the function app still references the old plan
  }
}

# Blob container used by the Flex Consumption runtime to store deployment packages.
# tflint-ignore: azurerm_resources_missing_prevent_destroy
resource "azurerm_storage_container" "deployments" {
  name                  = "deployments"
  container_access_type = "private"
  storage_account_id    = azurerm_storage_account.bot.id
}

# Using azapi_resource instead of azurerm_function_app_flex_consumption to avoid the provider
# auto-injecting AzureWebJobsStorage and DEPLOYMENT_STORAGE_CONNECTION_STRING with empty AccountKey
# on every apply. The empty AzureWebJobsStorage blocks the Flex Consumption scale controller from
# using component-based identity settings, silently preventing queue/blob trigger scaling.
# Tracked: https://github.com/hashicorp/terraform-provider-azurerm/issues/29149
#          https://github.com/hashicorp/terraform-provider-azurerm/issues/29693
#          https://github.com/hashicorp/terraform-provider-azurerm/issues/29993
#          https://github.com/hashicorp/terraform-provider-azurerm/issues/30732
resource "azapi_resource" "bot" {
  type          = "Microsoft.Web/sites@2025-03-01"
  name          = module.naming.function_app.name
  location      = var.location
  parent_id     = data.azurerm_resource_group.this.id
  tags          = local.common_tags
  ignore_casing = true

  body = {
    kind = "functionapp,linux"
    properties = {
      serverFarmId           = azurerm_service_plan.bot.id
      httpsOnly              = true
      virtualNetworkSubnetId = local.subnet_function_app_id

      functionAppConfig = {
        deployment = {
          storage = {
            type  = "blobContainer"
            value = "${azurerm_storage_account.bot.primary_blob_endpoint}${azurerm_storage_container.deployments.name}"
            authentication = {
              type                           = "UserAssignedIdentity"
              userAssignedIdentityResourceId = local.bot_uami_id
            }
          }
        }
        runtime = {
          name    = "dotnet-isolated"
          version = var.app_requirements.function_app_runtime_version
        }
        scaleAndConcurrency = {
          maximumInstanceCount = 100
          instanceMemoryMB     = 2048 # next down is 512 MB, which is too small
          triggers = {
            http = {
              perInstanceConcurrency = 16
            }
          }
        }
      }

      siteConfig = {
        minTlsVersion          = "1.2" # Bot Framework Connector uses TLS 1.2 — 1.3 blocks all inbound Teams traffic
        remoteDebuggingEnabled = false
        vnetRouteAllEnabled    = true

        appSettings = [
          # Identity-based connection for AzureWebJobsStorage (queue/blob/table triggers and host storage).
          # Uses explicit service URIs + __clientId per:
          # https://learn.microsoft.com/azure/azure-functions/functions-reference#connecting-to-host-storage-with-an-identity
          { name = "AzureWebJobsStorage__credential", value = "managedidentity" },
          { name = "AzureWebJobsStorage__clientId", value = local.bot_uami_client_id },
          { name = "AzureWebJobsStorage__blobServiceUri", value = azurerm_storage_account.bot.primary_blob_endpoint },
          { name = "AzureWebJobsStorage__queueServiceUri", value = "https://${azurerm_storage_account.bot.name}.queue.core.windows.net" },
          { name = "AzureWebJobsStorage__tableServiceUri", value = "https://${azurerm_storage_account.bot.name}.table.core.windows.net" },
          { name = "StorageAccountName", value = azurerm_storage_account.bot.name },
          { name = "APPLICATIONINSIGHTS_CONNECTION_STRING", value = azurerm_application_insights.bot.connection_string },
          # M365 Agents SDK identity — env vars override zero-GUID placeholders in appsettings.json.
          # Program.cs maps BotAppId/TenantId/AzureWebJobsStorage__clientId to nested SDK config paths.
          # No client secret needed — UAMI authenticates as the bot app registration via federated trust.
          { name = "BotAppId", value = var.bot_app_id },
          { name = "TenantId", value = local.tenant_id },
          { name = "ApiAppId", value = var.api_app_id },
          { name = "PoisonAlertAlias", value = var.alert_target_alias },
        ]

        # Priority layout for main app inbound rules:
        #   100-199: module-default allows (Bot Service, Teams channel, Action Group)
        #   200-399: allowed_caller_rules (applications pushing to /api/v1/*)
        #   400+   : debug_ip_rules (operators manually hitting /api/*)
        ipSecurityRestrictionsDefaultAction = "Deny"
        ipSecurityRestrictions = concat(
          [
            # Allow Azure Bot Service to reach the messaging endpoint (Direct Line, management)
            { action = "Allow", name = "AllowAzureBotService", priority = 100, tag = "ServiceTag", ipAddress = "AzureBotService" },
            # Allow Microsoft Teams channel connector to deliver inbound activities to /api/messages.
            # The AzureBotService service tag does NOT cover Teams channel delivery IPs — Teams
            # uses Microsoft 365 infrastructure (52.112.0.0/14, 52.122.0.0/15) per MS docs.
            # Note: Microsoft states IP-based allow-listing is not officially supported for
            # inbound bot traffic; JWT token validation in the Bot Framework SDK is the
            # recommended security mechanism.
            { action = "Allow", name = "AllowTeamsService1", priority = 101, ipAddress = "52.112.0.0/14", description = "Microsoft Teams service IP range for bot channel delivery" },
            { action = "Allow", name = "AllowTeamsService2", priority = 102, ipAddress = "52.122.0.0/15", description = "Microsoft Teams service IP range for bot channel delivery" },
            # Allow Azure Monitor Action Group webhook delivery for alert notifications
            { action = "Allow", name = "AllowAzureMonitorActionGroup", priority = 103, tag = "ServiceTag", ipAddress = "ActionGroup", description = "Azure Monitor Action Group webhook delivery" },
          ],
          [for i, rule in var.allowed_caller_rules : merge(
            {
              action      = "Allow"
              name        = rule.name
              priority    = 200 + i
              description = rule.description
            },
            rule.service_tag != null ? { tag = "ServiceTag", ipAddress = rule.service_tag } : { ipAddress = rule.cidr }
          )],
          [for i, rule in var.debug_ip_rules : {
            action = "Allow", name = rule.name, priority = 400 + i, ipAddress = rule.cidr, description = rule.description
          }]
        )

        # SCM/Kudu endpoint: debug access only. Application callers do not need Kudu.
        scmIpSecurityRestrictionsDefaultAction = "Deny"
        scmIpSecurityRestrictions = [for i, rule in var.debug_ip_rules : {
          action = "Allow", name = rule.name, priority = 100 + i, ipAddress = rule.cidr, description = rule.description
        }]
      }
    }
  }

  response_export_values = ["properties.defaultHostName"]

  identity {
    type         = "UserAssigned"
    identity_ids = [local.bot_uami_id]
  }
}

# Auth settings as a child resource. The ARM API requires authsettingsV2 as
# Microsoft.Web/sites/config, not as a property of the site.
# Using azapi_update_resource because authsettingsV2 is implicitly created
# as a child resource when the Function App is provisioned.
# The Bot Framework Connector sends its own JWT tokens (issued by botframework.com, audience = bot app ID).
# EasyAuth intercepts these tokens, can't validate them against our Entra ID configuration, and strips
# the Authorization header — causing the Bot SDK to fail with "No Authorization header".
# Excluding /api/messages from EasyAuth lets Bot Framework tokens pass through untouched.
# The Bot Framework SDK validates these tokens itself (JwtTokenValidation.AuthenticateRequest).
resource "azapi_update_resource" "bot_auth_settings" {
  type      = "Microsoft.Web/sites/config@2025-03-01"
  name      = "authsettingsV2"
  parent_id = azapi_resource.bot.id

  body = {
    properties = {
      platform = {
        enabled = var.app_requirements.bot_auth_settings.platform_enabled
      }
      globalValidation = {
        requireAuthentication       = var.app_requirements.bot_auth_settings.require_authentication
        unauthenticatedClientAction = var.app_requirements.bot_auth_settings.unauthenticated_action
        excludedPaths               = [var.app_requirements.bot_service.messaging_endpoint]
      }
      identityProviders = {
        azureActiveDirectory = {
          enabled = true
          registration = {
            clientId     = var.api_app_id
            openIdIssuer = "https://login.microsoftonline.com/${local.tenant_id}/v2.0"
          }
          validation = {
            allowedAudiences = ["api://${var.api_app_id}"]
          }
        }
      }
      login = {}
    }
  }

  lifecycle {
    precondition {
      condition     = var.app_requirements.bot_auth_settings.identity_provider == "azureActiveDirectory"
      error_message = "This module only supports azureActiveDirectory as the identity provider."
    }
  }
}
