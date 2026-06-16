# BYO Log Analytics Workspace Example

Deploys the bot landing zone configured to send all telemetry to an externally-owned Log Analytics workspace, instead of one the module creates itself.

This is the typical setup when a central platform team owns a shared workspace for cross-workload correlation (security signals, cost rollups, etc.) and individual workloads route their diag settings to it.

What this changes vs. the default (`enable_observability = true`, `create_log_analytics_workspace = true`):

| Resource | Default | BYO LAW |
|---|---|---|
| Log Analytics workspace | Created by the module under `var.resource_group_name` | Module skips creation; uses the workspace passed via `var.log_analytics_workspace_id` |
| Application Insights | Created, `workspace_id` → module's LAW | Created, `workspace_id` → BYO LAW |
| Diagnostic settings | Routed to module's LAW | Routed to BYO LAW |
| Saved-query pack | Created under `var.resource_group_name` | Same — query packs are per-RG, decoupled from the LAW location |
| Action group / metric alerts | Same | Same |

To switch to BYO LAW, set:

```hcl
create_log_analytics_workspace = false
log_analytics_workspace_id     = "<your workspace resource id>"
```

The flag is separate from the id because Terraform needs the LAW resource count to be known at plan time. If we inferred "BYO" from `log_analytics_workspace_id != null`, that breaks when the BYO id depends on another resource being created in the same configuration (as it does in this example, where the shared LAW is created alongside the module call).

If you want the module to skip the observability stack entirely (no LAW, no AI, no diag settings), see [`05-observability-disabled`](../05-observability-disabled/) instead.

## Usage

```bash
terraform init
terraform plan -var="name=my-bot" -var="bot_app_id=..." -var="api_app_id=..." -var="api_app_object_id=..."
terraform apply -var="name=my-bot" -var="bot_app_id=..." -var="api_app_id=..." -var="api_app_object_id=..."
```

In production this example would reference an existing workspace via a `data` source rather than creating one alongside the module — the integration test creates one here so the example is self-contained.

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

# Pretend this LAW is owned by a central observability team and is shared
# across many workloads. In a real BYO scenario you'd typically reference an
# existing workspace via data source or pass the id in as a variable —
# here we create one alongside the example so the integration test is
# self-contained.
resource "azurerm_log_analytics_workspace" "shared" {
  location            = azurerm_resource_group.this.location
  name                = "log-${var.name}-shared"
  resource_group_name = azurerm_resource_group.this.name
  retention_in_days   = 30
  sku                 = "PerGB2018"
  tags                = {}
}

# Demonstrates BYO LAW. The module skips creating its own workspace and
# routes App Insights + every diagnostic setting to the workspace we pass
# in. Saved-query pack still lives in `var.resource_group_name` (it's a
# per-RG resource, decoupled from the LAW location).
module "teams_notification_bot" {
  source = "../../"

  name                = var.name
  resource_group_name = azurerm_resource_group.this.name

  bot_app_id        = var.bot_app_id
  api_app_id        = var.api_app_id
  api_app_object_id = var.api_app_object_id

  app_requirements = {}

  # Tell the module to skip creating its own LAW, then point it at ours.
  # The flag (instead of inferring from log_analytics_workspace_id != null)
  # is required so the module's LAW resource count is known at plan time —
  # the workspace id below is apply-time-known here, which would otherwise
  # block plan.
  create_log_analytics_workspace = false
  log_analytics_workspace_id     = azurerm_log_analytics_workspace.shared.id

  depends_on = [time_sleep.rbac_propagation]
}
```

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_application_insights_connection_string"></a> [application\_insights\_connection\_string](#output\_application\_insights\_connection\_string) | Set even with BYO LAW — App Insights is still created and points at the shared workspace. |
| <a name="output_bot_service_name"></a> [bot\_service\_name](#output\_bot\_service\_name) | The name of the Bot Service. |
| <a name="output_function_app_hostname"></a> [function\_app\_hostname](#output\_function\_app\_hostname) | The default hostname of the Function App. |
| <a name="output_function_app_name"></a> [function\_app\_name](#output\_function\_app\_name) | The name of the Function App. |
| <a name="output_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#output\_log\_analytics\_workspace\_id) | The ID of the Log Analytics workspace the module is wired to. Should match `shared_log_analytics_workspace_id` in this example. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the resource group (passthrough from input). |
| <a name="output_shared_log_analytics_workspace_id"></a> [shared\_log\_analytics\_workspace\_id](#output\_shared\_log\_analytics\_workspace\_id) | The ID of the externally-managed Log Analytics workspace this example owns. |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | The name of the Storage Account. |
<!-- END_TF_DOCS -->
