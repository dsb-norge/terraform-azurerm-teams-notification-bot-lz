# Full Example

Comprehensive deployment of the Teams Notification Bot landing zone demonstrating all available features.

This example creates:

- A resource group (via the Azure naming module)
- The full bot landing zone with:
  - Monitoring alerts delivered to an ops channel
  - Management IP rules for CI runner access
  - GitHub Actions OIDC deploy identity with federated credentials
  - Custom tags
  - Custom app namespace

## Usage

```bash
terraform init
terraform plan -var="name=my-bot" -var="bot_app_id=..." -var="api_app_id=..." -var="api_app_object_id=..."
terraform apply -var="name=my-bot" -var="bot_app_id=..." -var="api_app_id=..." -var="api_app_object_id=..."
```

<!-- BEGIN_TF_DOCS -->



```hcl
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
```
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_application_insights_connection_string"></a> [application\_insights\_connection\_string](#output\_application\_insights\_connection\_string) | The connection string of the Application Insights instance. |
| <a name="output_bot_service_name"></a> [bot\_service\_name](#output\_bot\_service\_name) | The name of the Bot Service. |
| <a name="output_deploy_uami_client_id"></a> [deploy\_uami\_client\_id](#output\_deploy\_uami\_client\_id) | The client ID of the deploy user-assigned managed identity. Null when deploy\_github\_actions\_from is empty. |
| <a name="output_function_app_name"></a> [function\_app\_name](#output\_function\_app\_name) | The name of the Function App. |
| <a name="output_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#output\_log\_analytics\_workspace\_id) | The ID of the Log Analytics workspace. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the resource group (passthrough from input). |
<!-- END_TF_DOCS -->
