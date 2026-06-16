# Observability Disabled Example

Deploys the bot landing zone with `enable_observability = false`. The module skips the entire observability stack:

- No Log Analytics workspace
- No Application Insights
- No saved-query pack
- No diagnostic settings on any resource (function app, storage, bot service, service plan)
- No action group / metric alerts (regardless of `alert_target_alias`)

The function app still runs — it just has no telemetry. `APPLICATIONINSIGHTS_CONNECTION_STRING` is not set, so the App Insights SDK initializes in no-op mode.

Use this when an external observability stack collects telemetry through another mechanism (Azure Container Apps platform logs, an external SIEM forwarder, etc.), or for cost-sensitive non-production scenarios where you genuinely don't want telemetry.

If you want to use the module's observability resources but route logs to a workspace you already own, see [`06-byo-log-analytics-workspace`](../06-byo-log-analytics-workspace/) instead.

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

# Demonstrates the `enable_observability = false` toggle. The module
# provisions the function app, bot service, storage, and networking, but
# skips: the Log Analytics workspace, App Insights, the saved-query pack,
# all diagnostic settings, the action group, and metric alerts.
#
# The function app runs without telemetry — APPLICATIONINSIGHTS_CONNECTION_STRING
# is not set, and the AI SDK initializes in no-op mode. Outputs
# `log_analytics_workspace_id` / `application_insights_*` return null.
module "teams_notification_bot" {
  source = "../../"

  name                = var.name
  resource_group_name = azurerm_resource_group.this.name

  bot_app_id        = var.bot_app_id
  api_app_id        = var.api_app_id
  api_app_object_id = var.api_app_object_id

  app_requirements     = {}
  enable_observability = false

  depends_on = [time_sleep.rbac_propagation]
}
```

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_application_insights_connection_string"></a> [application\_insights\_connection\_string](#output\_application\_insights\_connection\_string) | Null because observability is disabled in this example. |
| <a name="output_application_insights_instrumentation_key"></a> [application\_insights\_instrumentation\_key](#output\_application\_insights\_instrumentation\_key) | Null because observability is disabled in this example. |
| <a name="output_bot_service_name"></a> [bot\_service\_name](#output\_bot\_service\_name) | The name of the Bot Service. |
| <a name="output_function_app_hostname"></a> [function\_app\_hostname](#output\_function\_app\_hostname) | The default hostname of the Function App. |
| <a name="output_function_app_name"></a> [function\_app\_name](#output\_function\_app\_name) | The name of the Function App. |
| <a name="output_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#output\_log\_analytics\_workspace\_id) | Null because observability is disabled in this example. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the resource group (passthrough from input). |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | The name of the Storage Account. |
<!-- END_TF_DOCS -->
