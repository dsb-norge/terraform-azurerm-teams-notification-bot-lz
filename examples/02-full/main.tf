provider "azurerm" {
  storage_use_azuread = true

  features {
    # Allow `terraform destroy` to clean up the resource group even if Azure
    # has not finished evicting child resources. The Flex Consumption function
    # app delete returns success from ARM before the platform fully removes
    # the site, racing the RG delete. Safe for examples — these are ephemeral.
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

data "azurerm_client_config" "current" {}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.3"

  suffix = [var.name]
}

resource "azurerm_resource_group" "this" {
  location = "norwayeast"
  name     = module.naming.resource_group.name_unique
  tags     = {}
}

# Storage data plane RBAC for the deploying identity.
# Required because the module sets shared_access_key_enabled = false.
resource "azurerm_role_assignment" "deployer_blob" {
  principal_id         = data.azurerm_client_config.current.object_id
  scope                = azurerm_resource_group.this.id
  role_definition_name = "Storage Blob Data Owner"
}

resource "azurerm_role_assignment" "deployer_queue" {
  principal_id         = data.azurerm_client_config.current.object_id
  scope                = azurerm_resource_group.this.id
  role_definition_name = "Storage Queue Data Contributor"
}

resource "azurerm_role_assignment" "deployer_table" {
  principal_id         = data.azurerm_client_config.current.object_id
  scope                = azurerm_resource_group.this.id
  role_definition_name = "Storage Table Data Contributor"
}

resource "time_sleep" "rbac_propagation" {
  create_duration = "60s"

  depends_on = [
    azurerm_role_assignment.deployer_blob,
    azurerm_role_assignment.deployer_queue,
    azurerm_role_assignment.deployer_table,
  ]
}

module "teams_notification_bot" {
  source = "../../"

  name                = var.name
  resource_group_name = azurerm_resource_group.this.name

  bot_app_id        = var.bot_app_id
  api_app_id        = var.api_app_id
  api_app_object_id = var.api_app_object_id

  # App requirements from the function app release
  app_requirements = jsondecode(file("${path.module}/app-requirements.json"))

  # Monitoring alerts — deliver to a channel alias
  alert_target_alias = var.alert_target_alias

  # Pre-created UAMI — pass the full resource ID to skip module-managed UAMI creation
  existing_bot_uami_id = var.existing_bot_uami_id

  # App namespace — must match the deployed .NET app's root namespace
  app_namespace = "TeamsNotificationBot"

  # Management access — CIDRs for operators and CI deploy runners (main app + SCM/Kudu + storage)
  management_ip_rules = [
    {
      name        = "ci-runner"
      description = "Operator laptop / CI runner IP"
      cidr        = "203.0.113.0/24"
    },
  ]

  # Allowed callers to /api/v1/* — systems that push messages to Teams.
  # Mix of service tag and CIDR rules to exercise both code paths.
  #
  # NOTE: App Service ipSecurityRestrictions accepts a narrower service tag set
  # than NSG rules. Regional variants like 'AzureCloud.NorwayEast' are rejected
  # with "invalid ServiceTag". Use the global 'AzureCloud' tag instead.
  allowed_caller_rules = [
    {
      name        = "azure-cloud"
      description = "Any Azure service (Automation / Logic Apps / etc.)"
      service_tag = "AzureCloud"
    },
    {
      name        = "onprem-monitoring"
      description = "On-prem monitoring system egress IP"
      cidr        = "203.0.113.100/32"
    },
  ]

  # CI/CD deployment — federated identity credentials for GitHub Actions
  github_org = "example-org"
  deploy_github_actions_from = {
    "teams-notification-bot" = {
      environments = ["production"]
      branches     = ["main"]
    }
  }

  tags = {
    "ApplicationName" = "Notifications"
    "owner"           = "platform-team"
  }

  depends_on = [time_sleep.rbac_propagation]
}
