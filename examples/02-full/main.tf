provider "azurerm" {
  features {}
  storage_use_azuread = true
}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.2"

  suffix = [var.name]
}

resource "azurerm_resource_group" "this" {
  name     = module.naming.resource_group.name
  location = "norwayeast"
}

module "teams_notification_bot" {
  source = "../../"

  name                = var.name
  resource_group_name = azurerm_resource_group.this.name

  bot_app_id        = var.bot_app_id
  api_app_id        = var.api_app_id
  api_app_object_id = var.api_app_object_id

  # Monitoring alerts — deliver to a channel alias
  alert_target_alias = "ops-alerts"

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

  depends_on = [azurerm_resource_group.this]
}
