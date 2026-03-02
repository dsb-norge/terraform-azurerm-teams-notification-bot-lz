#
# diagnostic settings → log analytics
#

resource "azurerm_monitor_diagnostic_setting" "function_app" {
  name                       = "diag-to-log-analytics"
  target_resource_id         = azapi_resource.bot.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.bot.id

  enabled_log {
    category = "FunctionAppLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

resource "azurerm_monitor_diagnostic_setting" "storage_blob" {
  name                       = "diag-to-log-analytics"
  target_resource_id         = "${azurerm_storage_account.bot.id}/blobServices/default"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.bot.id

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
  name                       = "diag-to-log-analytics"
  target_resource_id         = "${azurerm_storage_account.bot.id}/queueServices/default"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.bot.id

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
  name                       = "diag-to-log-analytics"
  target_resource_id         = "${azurerm_storage_account.bot.id}/tableServices/default"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.bot.id

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
