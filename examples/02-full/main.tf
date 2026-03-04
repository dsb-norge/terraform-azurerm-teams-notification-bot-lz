provider "azurerm" {
  storage_use_azuread = true

  features {}
}

data "azurerm_client_config" "current" {}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.2"

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

  # App namespace — must match the deployed .NET app's root namespace
  app_namespace = "TeamsNotificationBot"

  # Management access — IP ranges for terraform apply, deployment, testing
  management_ip_rules = [
    {
      name        = "ci-runner"
      description = "GitHub Actions runner IP"
      cidr        = "203.0.113.0/24"
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
