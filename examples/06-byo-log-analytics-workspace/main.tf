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
