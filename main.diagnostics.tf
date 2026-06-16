#
# diagnostic settings → log analytics
#

resource "azurerm_monitor_diagnostic_setting" "function_app" {
  count = var.enable_observability ? 1 : 0

  name                       = "diag-to-log-analytics"
  target_resource_id         = azapi_resource.bot.id
  log_analytics_workspace_id = local.log_analytics_workspace_id

  enabled_log {
    category = "FunctionAppLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

resource "azurerm_monitor_diagnostic_setting" "storage_blob" {
  count = var.enable_observability ? 1 : 0

  name                       = "diag-to-log-analytics"
  target_resource_id         = "${azurerm_storage_account.bot.id}/blobServices/default"
  log_analytics_workspace_id = local.log_analytics_workspace_id

  enabled_log {
    category = "StorageRead"
  }

  enabled_log {
    category = "StorageWrite"
  }

  enabled_log {
    category = "StorageDelete"
  }

  enabled_metric {
    category = "Transaction"
  }
}

resource "azurerm_monitor_diagnostic_setting" "storage_queue" {
  count = var.enable_observability ? 1 : 0

  name                       = "diag-to-log-analytics"
  target_resource_id         = "${azurerm_storage_account.bot.id}/queueServices/default"
  log_analytics_workspace_id = local.log_analytics_workspace_id

  enabled_log {
    category = "StorageRead"
  }

  enabled_log {
    category = "StorageWrite"
  }

  enabled_log {
    category = "StorageDelete"
  }

  enabled_metric {
    category = "Transaction"
  }
}

resource "azurerm_monitor_diagnostic_setting" "storage_table" {
  count = var.enable_observability ? 1 : 0

  name                       = "diag-to-log-analytics"
  target_resource_id         = "${azurerm_storage_account.bot.id}/tableServices/default"
  log_analytics_workspace_id = local.log_analytics_workspace_id

  enabled_log {
    category = "StorageRead"
  }

  enabled_log {
    category = "StorageWrite"
  }

  enabled_log {
    category = "StorageDelete"
  }

  enabled_metric {
    category = "Transaction"
  }
}

# storage account root — metrics only (Availability, UsedCapacity). Log
# categories live on the sub-services above (blob/queue/table); the account
# itself doesn't have log categories.
resource "azurerm_monitor_diagnostic_setting" "storage_account" {
  count = var.enable_observability ? 1 : 0

  name                       = "diag-to-log-analytics"
  target_resource_id         = azurerm_storage_account.bot.id
  log_analytics_workspace_id = local.log_analytics_workspace_id

  enabled_metric {
    category = "Transaction"
  }
}

# app service plan — metrics only (no log categories). Useful for autoscale
# tuning + capacity-vs-instance-count investigations on Flex Consumption.
resource "azurerm_monitor_diagnostic_setting" "service_plan" {
  count = var.enable_observability ? 1 : 0

  name                       = "diag-to-log-analytics"
  target_resource_id         = azurerm_service_plan.bot.id
  log_analytics_workspace_id = local.log_analytics_workspace_id

  enabled_metric {
    category = "AllMetrics"
  }
}

# bot service — `allLogs` covers every current and future category Azure
# adds. Without this resource, ABSBotRequests + related tables stay empty
# (the Connector→bot path is opaque). The gap was found during the
# 2026-06-16 dev-wlzs bot-non-response triage; see the egress-fix doc
# in the peder-tester repo for the empirical trail.
resource "azurerm_monitor_diagnostic_setting" "bot_service" {
  count = var.enable_observability ? 1 : 0

  name                       = "diag-to-log-analytics"
  target_resource_id         = azurerm_bot_service_azure_bot.bot.id
  log_analytics_workspace_id = local.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
