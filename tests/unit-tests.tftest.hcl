mock_provider "azurerm" {}
mock_provider "azapi" {}
mock_provider "time" {}

override_data {
  target = data.azurerm_client_config.current
  values = {
    tenant_id       = "00000000-0000-0000-0000-000000000000"
    subscription_id = "00000000-0000-0000-0000-000000000000"
    client_id       = "00000000-0000-0000-0000-000000000000"
    object_id       = "00000000-0000-0000-0000-000000000000"
  }
}

override_data {
  target = data.azurerm_resource_group.this
  values = {
    id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test-bot"
    location = "norwayeast"
  }
}

override_resource {
  target = azurerm_storage_account.bot
  values = {
    id                     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test-bot/providers/Microsoft.Storage/storageAccounts/sttestbot"
    primary_blob_endpoint  = "https://sttestbot.blob.core.windows.net/"
    primary_queue_endpoint = "https://sttestbot.queue.core.windows.net/"
    primary_table_endpoint = "https://sttestbot.table.core.windows.net/"
    name                   = "sttestbot"
  }
}

override_resource {
  target = azurerm_log_analytics_workspace.bot
  values = {
    id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test-bot/providers/Microsoft.OperationalInsights/workspaces/log-test-bot"
    workspace_id = "00000000-0000-0000-0000-000000000099"
  }
}

override_resource {
  target = azurerm_application_insights.bot
  values = {
    id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test-bot/providers/Microsoft.Insights/components/appi-test-bot"
    connection_string   = "InstrumentationKey=00000000-0000-0000-0000-000000000000;IngestionEndpoint=https://norwayeast-0.in.applicationinsights.azure.com/"
    instrumentation_key = "00000000-0000-0000-0000-000000000000"
  }
}

override_resource {
  target = azurerm_user_assigned_identity.bot
  values = {
    id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test-bot/providers/Microsoft.ManagedIdentity/userAssignedIdentities/uai-test-bot"
    client_id    = "00000000-0000-0000-0000-000000000010"
    principal_id = "00000000-0000-0000-0000-000000000011"
  }
}

override_data {
  target = data.azapi_resource.existing_bot
  values = {
    output = {
      properties = {
        clientId    = "00000000-0000-0000-0000-000000000030"
        principalId = "00000000-0000-0000-0000-000000000031"
      }
    }
  }
}

override_resource {
  target = azurerm_user_assigned_identity.deploy
  values = {
    id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test-bot/providers/Microsoft.ManagedIdentity/userAssignedIdentities/uai-test-bot-deploy"
    client_id    = "00000000-0000-0000-0000-000000000020"
    principal_id = "00000000-0000-0000-0000-000000000021"
  }
}

override_resource {
  target = azurerm_service_plan.bot
  values = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test-bot/providers/Microsoft.Web/serverFarms/plan-test-bot"
  }
}

override_resource {
  target = azurerm_log_analytics_query_pack.bot
  values = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test-bot/providers/Microsoft.OperationalInsights/queryPacks/qp-test-bot"
  }
}

override_resource {
  target = azurerm_virtual_network.bot
  values = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test-bot/providers/Microsoft.Network/virtualNetworks/vnet-test-bot"
  }
}

override_resource {
  target = azurerm_subnet.function_app
  values = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test-bot/providers/Microsoft.Network/virtualNetworks/vnet-test-bot/subnets/snet-test-bot-func"
  }
}

override_resource {
  target = azurerm_subnet.private_endpoints
  values = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test-bot/providers/Microsoft.Network/virtualNetworks/vnet-test-bot/subnets/snet-test-bot-pe"
  }
}

override_resource {
  target = azurerm_storage_container.deployments
  values = {
    id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test-bot/providers/Microsoft.Storage/storageAccounts/sttestbot/blobServices/default/containers/deployments"
    name = "deployments"
  }
}

override_resource {
  target = azurerm_bot_service_azure_bot.bot
  values = {
    id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test-bot/providers/Microsoft.BotService/botServices/bot-test-bot"
    name = "bot-test-bot"
  }
}

override_resource {
  target = azurerm_private_dns_zone.zones
  values = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test-bot/providers/Microsoft.Network/privateDnsZones/mock-zone"
  }
}

override_resource {
  target = azurerm_private_dns_zone_virtual_network_link.links
  values = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test-bot/providers/Microsoft.Network/privateDnsZones/mock-zone/virtualNetworkLinks/mock-link"
  }
}

override_resource {
  target = azurerm_private_endpoint.managed
  values = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test-bot/providers/Microsoft.Network/privateEndpoints/mock-pe"
  }
}

override_resource {
  target = azurerm_private_endpoint.unmanaged
  values = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test-bot/providers/Microsoft.Network/privateEndpoints/mock-pe-unmanaged"
  }
}

override_resource {
  target = azurerm_monitor_diagnostic_setting.function_app
  values = {
    id                 = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test-bot/providers/Microsoft.Insights/diagnosticSettings/mock-ds"
    target_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test-bot/providers/Microsoft.Web/sites/func-test-bot"
  }
}

override_resource {
  target = azurerm_monitor_diagnostic_setting.storage_blob
  values = {
    id                 = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test-bot/providers/Microsoft.Insights/diagnosticSettings/mock-ds-blob"
    target_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test-bot/providers/Microsoft.Storage/storageAccounts/sttestbot/blobServices/default"
  }
}

override_resource {
  target = azurerm_monitor_diagnostic_setting.storage_queue
  values = {
    id                 = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test-bot/providers/Microsoft.Insights/diagnosticSettings/mock-ds-queue"
    target_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test-bot/providers/Microsoft.Storage/storageAccounts/sttestbot/queueServices/default"
  }
}

override_resource {
  target = azurerm_monitor_diagnostic_setting.storage_table
  values = {
    id                 = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test-bot/providers/Microsoft.Insights/diagnosticSettings/mock-ds-table"
    target_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test-bot/providers/Microsoft.Storage/storageAccounts/sttestbot/tableServices/default"
  }
}
override_resource {
  target = azapi_resource.bot
  values = {
    id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test-bot/providers/Microsoft.Web/sites/func-test-bot"
    name = "func-test-bot"
    output = {
      properties = {
        defaultHostName = "func-test-bot.azurewebsites.net"
      }
    }
  }
}

override_resource {
  target = azapi_update_resource.bot_auth_settings
  values = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test-bot/providers/Microsoft.Web/sites/func-test-bot/config/authsettingsV2"
  }
}
# --- Required variable validation ---

run "name_rejects_uppercase" {
  command = plan

  variables {
    name = "Test-Bot"
  }

  expect_failures = [var.name]
}

run "name_rejects_spaces" {
  command = plan

  variables {
    name = "test bot"
  }

  expect_failures = [var.name]
}

run "bot_app_id_rejects_non_uuid" {
  command = plan

  variables {
    bot_app_id = "not-a-uuid"
  }

  expect_failures = [var.bot_app_id]
}

run "api_app_id_rejects_non_uuid" {
  command = plan

  variables {
    api_app_id = "not-a-uuid"
  }

  expect_failures = [var.api_app_id]
}

run "api_app_object_id_rejects_non_uuid" {
  command = plan

  variables {
    api_app_object_id = "invalid"
  }

  expect_failures = [var.api_app_object_id]
}

run "management_ip_rules_rejects_invalid_cidr" {
  command = plan

  variables {
    management_ip_rules = [
      { name = "bad", description = "bad cidr", cidr = "not-a-cidr" }
    ]
  }

  expect_failures = [var.management_ip_rules]
}

# --- Conditional resources ---

run "alerts_disabled_when_alias_empty" {
  command = plan

  variables {
    alert_target_alias = ""
  }

  assert {
    condition     = length(azurerm_monitor_action_group.bot_alerts) == 0
    error_message = "Action group should not be created when alert_target_alias is empty."
  }

  assert {
    condition     = length(azurerm_monitor_metric_alert.poison_queue) == 0
    error_message = "Poison queue alert should not be created when alert_target_alias is empty."
  }

  assert {
    condition     = length(azurerm_monitor_metric_alert.queue_backlog) == 0
    error_message = "Queue backlog alert should not be created when alert_target_alias is empty."
  }

  assert {
    condition     = length(azurerm_monitor_metric_alert.storage_heartbeat) == 0
    error_message = "Storage heartbeat alert should not be created when alert_target_alias is empty."
  }
}

run "alerts_created_when_alias_set" {
  command = plan

  variables {
    alert_target_alias = "ops-alerts"
  }

  assert {
    condition     = length(azurerm_monitor_action_group.bot_alerts) == 1
    error_message = "Action group should be created when alert_target_alias is set."
  }

  assert {
    condition     = length(azurerm_monitor_metric_alert.poison_queue) == 1
    error_message = "Poison queue alert should be created when alert_target_alias is set."
  }
}

run "deploy_uami_not_created_when_no_repos" {
  command = plan

  variables {
    deploy_github_actions_from = {}
  }

  assert {
    condition     = length(azurerm_user_assigned_identity.deploy) == 0
    error_message = "Deploy UAMI should not be created when deploy_github_actions_from is empty."
  }

  assert {
    condition     = length(azurerm_role_assignment.deploy_uami_website_contributor) == 0
    error_message = "Deploy UAMI role should not be created when deploy_github_actions_from is empty."
  }
}

run "deploy_uami_created_with_fics" {
  command = plan

  variables {
    github_org = "example-org"
    deploy_github_actions_from = {
      "my-repo" = {
        environments = ["prod"]
        branches     = ["main"]
      }
    }
  }

  assert {
    condition     = length(azurerm_user_assigned_identity.deploy) == 1
    error_message = "Deploy UAMI should be created when deploy_github_actions_from is non-empty."
  }

  assert {
    condition     = length(azurerm_role_assignment.deploy_uami_website_contributor) == 1
    error_message = "Deploy UAMI Website Contributor role should be created."
  }

  assert {
    condition     = length(azurerm_role_assignment.deploy_uami_reader) == 1
    error_message = "Deploy UAMI Reader role should be created."
  }
}

# --- Resource naming ---

run "resource_naming_uses_naming_module" {
  command = plan

  assert {
    condition     = azurerm_virtual_network.bot[0].name == "vnet-test-bot"
    error_message = "VNet name should use naming module prefix."
  }

  assert {
    condition     = azurerm_service_plan.bot.name == "plan-test-bot"
    error_message = "App service plan name should use naming module prefix."
  }

  assert {
    condition     = azurerm_storage_account.bot.name == "sttestbot"
    error_message = "Storage account name should use naming module output."
  }

  assert {
    condition     = azurerm_user_assigned_identity.bot[0].name == "uai-test-bot"
    error_message = "UAMI name should use naming module prefix."
  }

  assert {
    condition     = azurerm_bot_service_azure_bot.bot.name == "bot-test-bot"
    error_message = "Bot service name should follow 'bot-{name}' pattern (not in naming module)."
  }
}

# --- Default location ---

run "default_location_is_norwayeast" {
  command = plan

  assert {
    condition     = azurerm_storage_account.bot.location == "norwayeast"
    error_message = "Default location should be norwayeast."
  }
}

# --- Additional validation tests (positive) ---

run "name_accepts_valid_lowercase" {
  command = plan

  variables {
    name = "my-valid-bot-123"
  }

  assert {
    condition     = azurerm_virtual_network.bot[0].name == "vnet-my-valid-bot-123"
    error_message = "Valid lowercase name should be accepted."
  }
}

run "name_rejects_too_long" {
  command = plan

  variables {
    name = "this-name-is-way-too-long-for-storage"
  }

  expect_failures = [var.name]
}

run "management_ip_rules_accepts_valid_cidr" {
  command = plan

  variables {
    management_ip_rules = [
      { name = "office", description = "Office IP", cidr = "203.0.113.0/24" }
    ]
  }

  assert {
    condition     = length(var.management_ip_rules) == 1
    error_message = "Valid CIDR should be accepted."
  }
}

run "allowed_caller_rules_accepts_cidr" {
  command = plan

  variables {
    allowed_caller_rules = [
      { name = "onprem", description = "On-prem caller", cidr = "203.0.113.0/24" }
    ]
  }

  assert {
    condition     = length(var.allowed_caller_rules) == 1
    error_message = "Valid CIDR should be accepted."
  }
}

run "allowed_caller_rules_accepts_service_tag" {
  command = plan

  variables {
    allowed_caller_rules = [
      { name = "azure-cloud", description = "Azure Cloud (global)", service_tag = "AzureCloud" }
    ]
  }

  assert {
    condition     = length(var.allowed_caller_rules) == 1
    error_message = "Valid service tag should be accepted."
  }
}

run "allowed_caller_rules_rejects_both_cidr_and_tag" {
  command = plan

  variables {
    allowed_caller_rules = [
      { name = "bad", description = "both set", cidr = "10.0.0.0/8", service_tag = "AzureCloud" }
    ]
  }

  expect_failures = [var.allowed_caller_rules]
}

run "allowed_caller_rules_rejects_neither_cidr_nor_tag" {
  command = plan

  variables {
    allowed_caller_rules = [
      { name = "bad", description = "neither set" }
    ]
  }

  expect_failures = [var.allowed_caller_rules]
}

run "allowed_caller_rules_rejects_invalid_cidr" {
  command = plan

  variables {
    allowed_caller_rules = [
      { name = "bad", description = "bad cidr", cidr = "not-a-cidr" }
    ]
  }

  expect_failures = [var.allowed_caller_rules]
}

run "allowed_caller_rules_rejects_invalid_service_tag" {
  command = plan

  variables {
    allowed_caller_rules = [
      { name = "bad", description = "bad tag", service_tag = "has spaces!" }
    ]
  }

  expect_failures = [var.allowed_caller_rules]
}

run "allowed_caller_rules_rejects_description_with_comma" {
  command = plan

  variables {
    allowed_caller_rules = [
      { name = "bad", description = "Automation, Logic Apps", service_tag = "AzureCloud" }
    ]
  }

  expect_failures = [var.allowed_caller_rules]
}

run "allowed_caller_rules_rejects_description_with_semicolon" {
  command = plan

  variables {
    allowed_caller_rules = [
      { name = "bad", description = "rule one; rule two", service_tag = "AzureCloud" }
    ]
  }

  expect_failures = [var.allowed_caller_rules]
}

run "management_ip_rules_rejects_description_with_comma" {
  command = plan

  variables {
    management_ip_rules = [
      { name = "bad", description = "office, vpn", cidr = "10.0.0.0/24" }
    ]
  }

  expect_failures = [var.management_ip_rules]
}

run "management_ip_rules_rejects_description_with_semicolon" {
  command = plan

  variables {
    management_ip_rules = [
      { name = "bad", description = "office; vpn", cidr = "10.0.0.0/24" }
    ]
  }

  expect_failures = [var.management_ip_rules]
}

# --- New variable validations ---

run "location_rejects_empty" {
  command = plan

  variables {
    location = ""
  }

  expect_failures = [var.location]
}

run "resource_group_name_rejects_empty" {
  command = plan

  variables {
    resource_group_name = ""
  }

  expect_failures = [var.resource_group_name]
}

run "app_namespace_rejects_empty" {
  command = plan

  variables {
    app_namespace = ""
  }

  expect_failures = [var.app_namespace]
}

# --- GitHub org validation ---

run "github_org_allows_empty" {
  command = plan

  variables {
    github_org = ""
  }

  assert {
    condition     = length(azurerm_user_assigned_identity.deploy) == 0
    error_message = "Empty github_org with empty repos should not create deploy UAMI."
  }
}

run "github_org_rejects_special_chars" {
  command = plan

  variables {
    github_org = "my org!"
  }

  expect_failures = [var.github_org]
}

# --- deploy_github_actions_from sub-field validation ---

run "deploy_github_actions_from_rejects_empty_environment" {
  command = plan

  variables {
    github_org = "example-org"
    deploy_github_actions_from = {
      "my-repo" = {
        environments = [""]
      }
    }
  }

  expect_failures = [var.deploy_github_actions_from]
}

run "deploy_github_actions_from_rejects_empty_branch" {
  command = plan

  variables {
    github_org = "example-org"
    deploy_github_actions_from = {
      "my-repo" = {
        branches = [""]
      }
    }
  }

  expect_failures = [var.deploy_github_actions_from]
}

run "deploy_github_actions_from_rejects_empty_tag" {
  command = plan

  variables {
    github_org = "example-org"
    deploy_github_actions_from = {
      "my-repo" = {
        tags = [""]
      }
    }
  }

  expect_failures = [var.deploy_github_actions_from]
}

# --- Cross-variable precondition ---

run "deploy_uami_requires_github_org" {
  command = plan

  variables {
    github_org = ""
    deploy_github_actions_from = {
      "my-repo" = {
        environments = ["prod"]
      }
    }
  }

  expect_failures = [azurerm_user_assigned_identity.deploy]
}

# --- network_config validation ---

run "network_config_subnet_prefix_rejects_invalid_cidr" {
  command = plan

  variables {
    network_config = {
      subnet_function_app_prefix = "not-a-cidr"
    }
  }

  expect_failures = [var.network_config]
}

run "network_config_subnet_prefix_rejects_too_small" {
  command = plan

  variables {
    network_config = {
      subnet_function_app_prefix = "10.0.0.0/28"
    }
  }

  expect_failures = [var.network_config]
}

run "network_config_pe_subnet_prefix_rejects_invalid_cidr" {
  command = plan

  variables {
    network_config = {
      subnet_private_endpoints_prefix = "not-a-cidr"
    }
  }

  expect_failures = [var.network_config]
}

run "network_config_pe_subnet_prefix_rejects_too_small" {
  command = plan

  variables {
    network_config = {
      subnet_private_endpoints_prefix = "10.0.1.0/29"
    }
  }

  expect_failures = [var.network_config]
}

# --- BYON subnet postcondition tests (using override_data to simulate Azure API responses) ---

run "network_byon_rejects_missing_delegation" {
  command = plan

  override_data {
    target = data.azapi_resource.byon_subnet_function_app[0]
    values = {
      output = {
        properties = {
          delegations   = []
          addressPrefix = "10.100.0.0/24"
        }
      }
    }
  }

  override_data {
    target = data.azapi_resource.byon_subnet_private_endpoints[0]
    values = {
      output = {
        properties = {
          delegations   = []
          addressPrefix = "10.100.1.0/28"
        }
      }
    }
  }

  variables {
    network_config = {
      create_network                       = false
      existing_subnet_function_app_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/func"
      existing_subnet_private_endpoints_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/pe"
      manage_private_dns_zone_groups       = false
    }
  }

  expect_failures = [data.azapi_resource.byon_subnet_function_app[0]]
}

run "network_byon_rejects_delegated_pe_subnet" {
  command = plan

  override_data {
    target = data.azapi_resource.byon_subnet_function_app[0]
    values = {
      output = {
        properties = {
          delegations = [{
            name = "flex-consumption"
            properties = {
              serviceName = "Microsoft.App/environments"
              actions     = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
            }
          }]
          addressPrefix = "10.100.0.0/24"
        }
      }
    }
  }

  override_data {
    target = data.azapi_resource.byon_subnet_private_endpoints[0]
    values = {
      output = {
        properties = {
          delegations = [{
            name = "some-delegation"
            properties = {
              serviceName = "Microsoft.Sql/servers"
              actions     = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
            }
          }]
          addressPrefix = "10.100.1.0/28"
        }
      }
    }
  }

  variables {
    network_config = {
      create_network                       = false
      existing_subnet_function_app_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/func"
      existing_subnet_private_endpoints_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/pe"
      manage_private_dns_zone_groups       = false
    }
  }

  expect_failures = [data.azapi_resource.byon_subnet_private_endpoints[0]]
}

run "network_byon_rejects_func_subnet_too_small" {
  command = plan

  override_data {
    target = data.azapi_resource.byon_subnet_function_app[0]
    values = {
      output = {
        properties = {
          delegations = [{
            name = "flex-consumption"
            properties = {
              serviceName = "Microsoft.App/environments"
              actions     = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
            }
          }]
          addressPrefix = "10.100.0.0/28"
        }
      }
    }
  }

  override_data {
    target = data.azapi_resource.byon_subnet_private_endpoints[0]
    values = {
      output = {
        properties = {
          delegations   = []
          addressPrefix = "10.100.1.0/28"
        }
      }
    }
  }

  variables {
    network_config = {
      create_network                       = false
      existing_subnet_function_app_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/func"
      existing_subnet_private_endpoints_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/pe"
      manage_private_dns_zone_groups       = false
    }
  }

  expect_failures = [data.azapi_resource.byon_subnet_function_app[0]]
}

run "network_byon_rejects_pe_subnet_too_small" {
  command = plan

  override_data {
    target = data.azapi_resource.byon_subnet_function_app[0]
    values = {
      output = {
        properties = {
          delegations = [{
            name = "flex-consumption"
            properties = {
              serviceName = "Microsoft.App/environments"
              actions     = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
            }
          }]
          addressPrefix = "10.100.0.0/24"
        }
      }
    }
  }

  override_data {
    target = data.azapi_resource.byon_subnet_private_endpoints[0]
    values = {
      output = {
        properties = {
          delegations   = []
          addressPrefix = "10.100.1.0/29"
        }
      }
    }
  }

  variables {
    network_config = {
      create_network                       = false
      existing_subnet_function_app_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/func"
      existing_subnet_private_endpoints_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/pe"
      manage_private_dns_zone_groups       = false
    }
  }

  expect_failures = [data.azapi_resource.byon_subnet_private_endpoints[0]]
}

run "network_byon_accepts_valid_subnets" {
  command = plan

  override_data {
    target = data.azapi_resource.byon_subnet_function_app[0]
    values = {
      output = {
        properties = {
          delegations = [{
            name = "flex-consumption"
            properties = {
              serviceName = "Microsoft.App/environments"
              actions     = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
            }
          }]
          addressPrefix = "10.100.0.0/24"
        }
      }
    }
  }

  override_data {
    target = data.azapi_resource.byon_subnet_private_endpoints[0]
    values = {
      output = {
        properties = {
          delegations   = []
          addressPrefix = "10.100.1.0/28"
        }
      }
    }
  }

  variables {
    network_config = {
      create_network                       = false
      existing_subnet_function_app_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/func"
      existing_subnet_private_endpoints_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/pe"
      manage_private_dns_zone_groups       = false
    }
  }

  # No expect_failures — this should succeed
  assert {
    condition     = length(data.azapi_resource.byon_subnet_function_app) == 1
    error_message = "BYON should read the function app subnet."
  }

  assert {
    condition     = length(data.azapi_resource.byon_subnet_private_endpoints) == 1
    error_message = "BYON should read the PE subnet."
  }
}

run "network_byon_rejects_missing_func_subnet" {
  command = plan

  variables {
    network_config = {
      create_network                       = false
      existing_subnet_private_endpoints_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/pe"
      manage_private_dns_zone_groups       = false
    }
  }

  expect_failures = [var.network_config]
}

run "network_byon_rejects_missing_pe_subnet" {
  command = plan

  variables {
    network_config = {
      create_network                  = false
      existing_subnet_function_app_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/func"
      manage_private_dns_zone_groups  = false
    }
  }

  expect_failures = [var.network_config]
}

run "network_byon_managed_dns_rejects_missing_zone_ids" {
  command = plan

  variables {
    network_config = {
      create_network                       = false
      existing_subnet_function_app_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/func"
      existing_subnet_private_endpoints_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/pe"
      manage_private_dns_zone_groups       = true
    }
  }

  expect_failures = [var.network_config]
}

# --- network_config Mode 1 (self-contained) tests ---

run "network_default_creates_vnet" {
  command = plan

  assert {
    condition     = length(azurerm_virtual_network.bot) == 1
    error_message = "Default network_config should create a VNet."
  }

  assert {
    condition     = length(azurerm_subnet.function_app) == 1
    error_message = "Default network_config should create a function app subnet."
  }

  assert {
    condition     = length(azurerm_subnet.private_endpoints) == 1
    error_message = "Default network_config should create a private endpoints subnet."
  }
}

run "network_default_creates_dns_zones" {
  command = plan

  assert {
    condition     = length(azurerm_private_dns_zone.zones) == 3
    error_message = "Default network_config should create 3 DNS zones."
  }

  assert {
    condition     = length(azurerm_private_dns_zone_virtual_network_link.links) == 3
    error_message = "Default network_config should create 3 VNet links."
  }
}

run "network_default_creates_managed_pes" {
  command = plan

  assert {
    condition     = length(azurerm_private_endpoint.managed) == 3
    error_message = "Default network_config should create 3 managed PEs."
  }

  assert {
    condition     = length(azurerm_private_endpoint.unmanaged) == 0
    error_message = "Default network_config should create 0 unmanaged PEs."
  }
}

run "network_mode1_custom_prefixes" {
  command = plan

  variables {
    network_config = {
      vnet_address_space              = ["172.16.0.0/16"]
      subnet_function_app_prefix      = "172.16.0.0/24"
      subnet_private_endpoints_prefix = "172.16.1.0/24"
    }
  }

  assert {
    condition     = length(azurerm_virtual_network.bot) == 1
    error_message = "Mode 1 with custom prefixes should create a VNet."
  }
}

run "network_mode1_ignores_existing_subnet_ids" {
  command = plan

  variables {
    network_config = {
      create_network                       = true
      existing_subnet_function_app_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/func"
      existing_subnet_private_endpoints_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/pe"
    }
  }

  assert {
    condition     = length(azurerm_virtual_network.bot) == 1
    error_message = "Mode 1 should create VNet even if existing subnet IDs are set (they are ignored)."
  }
}

# --- network_config Mode 2 (BYON) tests ---

run "network_byon_skips_vnet" {
  command = plan

  override_data {
    target = data.azapi_resource.byon_subnet_function_app[0]
    values = {
      output = {
        properties = {
          delegations   = [{ name = "flex", properties = { serviceName = "Microsoft.App/environments", actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"] } }]
          addressPrefix = "10.100.0.0/24"
        }
      }
    }
  }

  override_data {
    target = data.azapi_resource.byon_subnet_private_endpoints[0]
    values = {
      output = {
        properties = {
          delegations   = []
          addressPrefix = "10.100.1.0/28"
        }
      }
    }
  }

  variables {
    network_config = {
      create_network                       = false
      existing_subnet_function_app_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/func"
      existing_subnet_private_endpoints_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/pe"
      manage_private_dns_zone_groups       = false
    }
  }

  assert {
    condition     = length(azurerm_virtual_network.bot) == 0
    error_message = "BYON mode should not create a VNet."
  }

  assert {
    condition     = length(azurerm_subnet.function_app) == 0
    error_message = "BYON mode should not create subnets."
  }

  assert {
    condition     = length(azurerm_subnet.private_endpoints) == 0
    error_message = "BYON mode should not create subnets."
  }
}

run "network_byon_skips_dns_zones" {
  command = plan

  override_data {
    target = data.azapi_resource.byon_subnet_function_app[0]
    values = {
      output = {
        properties = {
          delegations   = [{ name = "flex", properties = { serviceName = "Microsoft.App/environments", actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"] } }]
          addressPrefix = "10.100.0.0/24"
        }
      }
    }
  }

  override_data {
    target = data.azapi_resource.byon_subnet_private_endpoints[0]
    values = {
      output = {
        properties = {
          delegations   = []
          addressPrefix = "10.100.1.0/28"
        }
      }
    }
  }

  variables {
    network_config = {
      create_network                       = false
      existing_subnet_function_app_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/func"
      existing_subnet_private_endpoints_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/pe"
      manage_private_dns_zone_groups       = false
    }
  }

  assert {
    condition     = length(azurerm_private_dns_zone.zones) == 0
    error_message = "BYON mode should not create DNS zones."
  }

  assert {
    condition     = length(azurerm_private_dns_zone_virtual_network_link.links) == 0
    error_message = "BYON mode should not create VNet links."
  }
}

run "network_byon_creates_unmanaged_pes" {
  command = plan

  override_data {
    target = data.azapi_resource.byon_subnet_function_app[0]
    values = {
      output = {
        properties = {
          delegations   = [{ name = "flex", properties = { serviceName = "Microsoft.App/environments", actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"] } }]
          addressPrefix = "10.100.0.0/24"
        }
      }
    }
  }

  override_data {
    target = data.azapi_resource.byon_subnet_private_endpoints[0]
    values = {
      output = {
        properties = {
          delegations   = []
          addressPrefix = "10.100.1.0/28"
        }
      }
    }
  }

  variables {
    network_config = {
      create_network                       = false
      existing_subnet_function_app_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/func"
      existing_subnet_private_endpoints_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/pe"
      manage_private_dns_zone_groups       = false
    }
  }

  assert {
    condition     = length(azurerm_private_endpoint.managed) == 0
    error_message = "BYON with unmanaged DNS should create 0 managed PEs."
  }

  assert {
    condition     = length(azurerm_private_endpoint.unmanaged) == 3
    error_message = "BYON with unmanaged DNS should create 3 unmanaged PEs."
  }
}

run "network_byon_with_caller_dns" {
  command = plan

  override_data {
    target = data.azapi_resource.byon_subnet_function_app[0]
    values = {
      output = {
        properties = {
          delegations   = [{ name = "flex", properties = { serviceName = "Microsoft.App/environments", actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"] } }]
          addressPrefix = "10.100.0.0/24"
        }
      }
    }
  }

  override_data {
    target = data.azapi_resource.byon_subnet_private_endpoints[0]
    values = {
      output = {
        properties = {
          delegations   = []
          addressPrefix = "10.100.1.0/28"
        }
      }
    }
  }

  variables {
    network_config = {
      create_network                       = false
      existing_subnet_function_app_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/func"
      existing_subnet_private_endpoints_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/pe"
      manage_private_dns_zone_groups       = true
      private_dns_zone_resource_ids = {
        blob  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dns/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net"
        queue = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dns/providers/Microsoft.Network/privateDnsZones/privatelink.queue.core.windows.net"
        table = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dns/providers/Microsoft.Network/privateDnsZones/privatelink.table.core.windows.net"
      }
    }
  }

  assert {
    condition     = length(azurerm_private_endpoint.managed) == 3
    error_message = "BYON with caller DNS should create 3 managed PEs."
  }

  assert {
    condition     = length(azurerm_private_endpoint.unmanaged) == 0
    error_message = "BYON with caller DNS should create 0 unmanaged PEs."
  }

  assert {
    condition     = length(azurerm_private_dns_zone.zones) == 0
    error_message = "BYON with caller DNS should not create module DNS zones."
  }

  # Default DNS zone group name should be "default"
  assert {
    condition     = azurerm_private_endpoint.managed["storage_blob"].private_dns_zone_group[0].name == "default"
    error_message = "Default private_dns_zone_group_name should be 'default'."
  }
}

run "network_byon_with_caller_dns_custom_group_name" {
  command = plan

  override_data {
    target = data.azapi_resource.byon_subnet_function_app[0]
    values = {
      output = {
        properties = {
          delegations   = [{ name = "flex", properties = { serviceName = "Microsoft.App/environments", actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"] } }]
          addressPrefix = "10.100.0.0/24"
        }
      }
    }
  }

  override_data {
    target = data.azapi_resource.byon_subnet_private_endpoints[0]
    values = {
      output = {
        properties = {
          delegations   = []
          addressPrefix = "10.100.1.0/28"
        }
      }
    }
  }

  variables {
    network_config = {
      create_network                       = false
      existing_subnet_function_app_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/func"
      existing_subnet_private_endpoints_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/pe"
      manage_private_dns_zone_groups       = true
      private_dns_zone_group_name          = "deployedByPolicy"
      private_dns_zone_resource_ids = {
        blob  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dns/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net"
        queue = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dns/providers/Microsoft.Network/privateDnsZones/privatelink.queue.core.windows.net"
        table = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dns/providers/Microsoft.Network/privateDnsZones/privatelink.table.core.windows.net"
      }
    }
  }

  # Custom group name used on all 3 PEs — enables coexistence with CAF ALZ policy
  assert {
    condition     = alltrue([for k, pe in azurerm_private_endpoint.managed : pe.private_dns_zone_group[0].name == "deployedByPolicy"])
    error_message = "Custom private_dns_zone_group_name should be applied to all managed PEs."
  }
}

# --- network_config output tests (apply with mocks) ---

run "network_outputs_mode1" {
  command = apply

  assert {
    condition     = output.vnet_id != null
    error_message = "Mode 1 should output a non-null vnet_id."
  }

  assert {
    condition     = output.subnet_function_app_id != null && output.subnet_function_app_id != ""
    error_message = "Mode 1 should output a non-null subnet_function_app_id."
  }

  assert {
    condition     = output.subnet_private_endpoints_id != null && output.subnet_private_endpoints_id != ""
    error_message = "Mode 1 should output a non-null subnet_private_endpoints_id."
  }

  assert {
    condition     = length(output.private_endpoint_ids) == 3
    error_message = "Mode 1 should output 3 private endpoint IDs."
  }
}

run "network_outputs_mode2" {
  command = apply

  override_data {
    target = data.azapi_resource.byon_subnet_function_app[0]
    values = {
      output = {
        properties = {
          delegations   = [{ name = "flex", properties = { serviceName = "Microsoft.App/environments", actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"] } }]
          addressPrefix = "10.100.0.0/24"
        }
      }
    }
  }

  override_data {
    target = data.azapi_resource.byon_subnet_private_endpoints[0]
    values = {
      output = {
        properties = {
          delegations   = []
          addressPrefix = "10.100.1.0/28"
        }
      }
    }
  }

  variables {
    network_config = {
      create_network                       = false
      existing_subnet_function_app_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/func"
      existing_subnet_private_endpoints_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/pe"
      manage_private_dns_zone_groups       = false
    }
  }

  assert {
    condition     = output.vnet_id == null
    error_message = "Mode 2 should output null vnet_id."
  }

  assert {
    condition     = output.subnet_function_app_id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/func"
    error_message = "Mode 2 should output the provided subnet_function_app_id."
  }

  assert {
    condition     = length(output.private_endpoint_ids) == 3
    error_message = "Mode 2 should output 3 private endpoint IDs."
  }
}

# --- app_requirements tests ---

run "default_app_requirements_creates_four_queues" {
  command = plan

  variables {
    app_requirements = {}
  }

  assert {
    condition     = length(azurerm_storage_queue.app) == 4
    error_message = "Default app_requirements should create 4 queues."
  }
}

run "custom_queues_from_app_requirements" {
  command = plan

  variables {
    app_requirements = {
      storage_account_required_queues = ["myqueue", "myqueue-poison"]
    }
  }

  assert {
    condition     = length(azurerm_storage_queue.app) == 2
    error_message = "Custom app_requirements should create the specified number of queues."
  }
}

run "bot_service_type_from_app_requirements" {
  command = plan

  variables {
    app_requirements = {
      bot_service = {
        type = "SingleTenant"
      }
    }
  }

  assert {
    condition     = azurerm_bot_service_azure_bot.bot.microsoft_app_type == "SingleTenant"
    error_message = "Bot service type should come from app_requirements."
  }
}

run "auth_precondition_rejects_non_aad" {
  command = plan

  variables {
    app_requirements = {
      bot_auth_settings = {
        identity_provider = "google"
      }
    }
  }

  expect_failures = [azapi_update_resource.bot_auth_settings]
}

# --- Output tests (require apply with mock providers) ---

run "outputs_with_defaults" {
  command = apply

  assert {
    condition     = output.resource_group_name == "rg-test-bot"
    error_message = "resource_group_name output should passthrough the input variable."
  }

  assert {
    condition     = output.function_app_name == "func-test-bot"
    error_message = "function_app_name should use naming module prefix."
  }

  assert {
    condition     = output.storage_account_name == "sttestbot"
    error_message = "storage_account_name should use naming module output."
  }

  assert {
    condition     = output.bot_service_name == "bot-test-bot"
    error_message = "bot_service_name should follow 'bot-{name}' pattern."
  }

  assert {
    condition     = output.uami_client_id != null && output.uami_client_id != ""
    error_message = "uami_client_id should be non-null and non-empty."
  }

  assert {
    condition     = output.uami_principal_id != null && output.uami_principal_id != ""
    error_message = "uami_principal_id should be non-null and non-empty."
  }

  assert {
    condition     = output.deploy_uami_client_id == null
    error_message = "deploy_uami_client_id should be null when deploy_github_actions_from is empty."
  }

  assert {
    condition     = output.infrastructure_requirements_unique_hash == ""
    error_message = "infrastructure_requirements_unique_hash should be empty string with default app_requirements."
  }

  assert {
    condition     = output.log_analytics_workspace_id != null && output.log_analytics_workspace_id != ""
    error_message = "log_analytics_workspace_id should be non-null and non-empty."
  }
}

run "deploy_uami_output_set_when_repos_configured" {
  command = apply

  variables {
    github_org = "example-org"
    deploy_github_actions_from = {
      "my-repo" = {
        environments = ["prod"]
      }
    }
  }

  assert {
    condition     = output.deploy_uami_client_id != null
    error_message = "deploy_uami_client_id should be non-null when deploy_github_actions_from is non-empty."
  }
}

# --- existing_bot_uami_id (BYON identity) ---

run "existing_uami_rejects_invalid_resource_id" {
  command = plan

  variables {
    existing_bot_uami_id = "not-a-resource-id"
  }

  expect_failures = [var.existing_bot_uami_id]
}

run "existing_uami_accepts_empty" {
  command = plan

  variables {
    existing_bot_uami_id = ""
  }

  assert {
    condition     = length(azurerm_user_assigned_identity.bot) == 1
    error_message = "Empty existing_bot_uami_id should create a module-managed UAMI."
  }
}

run "existing_uami_skips_creation" {
  command = plan

  variables {
    existing_bot_uami_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-identity/providers/Microsoft.ManagedIdentity/userAssignedIdentities/uai-existing-bot"
  }

  assert {
    condition     = length(azurerm_user_assigned_identity.bot) == 0
    error_message = "Providing existing_bot_uami_id should skip UAMI creation."
  }

  assert {
    condition     = length(data.azapi_resource.existing_bot) == 1
    error_message = "Providing existing_bot_uami_id should read the existing UAMI via azapi."
  }
}

run "existing_uami_outputs" {
  command = apply

  variables {
    existing_bot_uami_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-identity/providers/Microsoft.ManagedIdentity/userAssignedIdentities/uai-existing-bot"
  }

  assert {
    condition     = output.uami_client_id == "00000000-0000-0000-0000-000000000030"
    error_message = "uami_client_id should come from the existing UAMI data source."
  }

  assert {
    condition     = output.uami_principal_id == "00000000-0000-0000-0000-000000000031"
    error_message = "uami_principal_id should come from the existing UAMI data source."
  }
}
