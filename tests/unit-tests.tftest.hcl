mock_provider "azurerm" {}
mock_provider "azapi" {}

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
  target = azurerm_private_endpoint.endpoints
  values = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test-bot/providers/Microsoft.Network/privateEndpoints/mock-pe"
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
    condition     = azurerm_virtual_network.bot.name == "vnet-test-bot"
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
    condition     = azurerm_user_assigned_identity.bot.name == "uai-test-bot"
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
    condition     = azurerm_virtual_network.bot.name == "vnet-my-valid-bot-123"
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

# --- VNet variable validation ---

run "vnet_address_space_rejects_empty" {
  command = plan

  variables {
    vnet_address_space = []
  }

  expect_failures = [var.vnet_address_space]
}

run "subnet_function_app_prefix_rejects_invalid" {
  command = plan

  variables {
    subnet_function_app_prefix = "not-a-cidr"
  }

  expect_failures = [var.subnet_function_app_prefix]
}

run "subnet_private_endpoints_prefix_rejects_invalid" {
  command = plan

  variables {
    subnet_private_endpoints_prefix = "not-a-cidr"
  }

  expect_failures = [var.subnet_private_endpoints_prefix]
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
