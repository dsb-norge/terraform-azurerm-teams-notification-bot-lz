#
# monitoring - log analytics workspace and application insights
#

# enable_observability is the master switch; create_log_analytics_workspace
# decides whether the module creates its own LAW or uses one passed via
# log_analytics_workspace_id (BYO). The "should create" decision is its own
# bool input (not inferred from `log_analytics_workspace_id == null`) so
# count is plan-time-known even when the BYO id depends on resources created
# in the same configuration.
locals {
  create_log_analytics_workspace = var.enable_observability && var.create_log_analytics_workspace
  log_analytics_workspace_id = (
    !var.enable_observability ? null :
    var.create_log_analytics_workspace ? azurerm_log_analytics_workspace.bot[0].id :
    var.log_analytics_workspace_id
  )
}

resource "azurerm_log_analytics_workspace" "bot" {
  count = local.create_log_analytics_workspace ? 1 : 0

  location            = var.location
  name                = local.names.log_analytics_workspace
  resource_group_name = var.resource_group_name
  retention_in_days   = 30
  sku                 = "PerGB2018"
  tags                = local.common_tags
}

# Saved KQL queries (query pack) live in main.monitoring.queries.tf.

#
# application insights
#

resource "azurerm_application_insights" "bot" {
  count = var.enable_observability ? 1 : 0

  application_type    = "web"
  location            = var.location
  name                = local.names.application_insights
  resource_group_name = var.resource_group_name
  tags                = local.common_tags
  workspace_id        = local.log_analytics_workspace_id
}
