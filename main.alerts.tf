#
# Azure Monitor action group and metric alert rules.
# Conditional on alert_target_alias being set.
#

resource "azurerm_monitor_action_group" "bot_alerts" {
  count = var.alert_target_alias != "" ? 1 : 0

  name                = module.naming.monitor_action_group.name
  resource_group_name = var.resource_group_name
  short_name          = "BotAlerts"
  tags                = local.common_tags

  webhook_receiver {
    name                    = "teams-bot-alert"
    service_uri             = "https://${azapi_resource.bot.output.properties.defaultHostName}${replace(var.app_requirements.well_known_routes.azure_alert_webhook_receiver_endpoint, "{alias}", var.alert_target_alias)}"
    use_common_alert_schema = true

    aad_auth {
      object_id      = var.api_app_object_id
      identifier_uri = "api://${var.api_app_id}"
      tenant_id      = local.tenant_id
    }
  }
}

resource "azurerm_monitor_metric_alert" "poison_queue" {
  count = var.alert_target_alias != "" ? 1 : 0

  name                = "alert-poison-queue-messages"
  resource_group_name = var.resource_group_name
  scopes              = ["${azurerm_storage_account.bot.id}/queueServices/default"]
  auto_mitigate       = true
  description         = "Fires when queue message count exceeds baseline — poison queue messages indicate failed processing."
  frequency           = "PT1H"
  severity            = 2
  tags                = local.common_tags
  window_size         = "PT1H"

  # QueueMessageCount is aggregate across all queues (no per-queue dimension available).
  # Using dynamic criteria with Low sensitivity to alert when count deviates from baseline.
  # In practice, poison queues are rarely populated, so any sustained increase triggers.
  action {
    action_group_id = azurerm_monitor_action_group.bot_alerts[0].id
  }

  dynamic_criteria {
    aggregation       = "Average"
    alert_sensitivity = "Low"
    metric_name       = "QueueMessageCount"
    metric_namespace  = "Microsoft.Storage/storageAccounts/queueServices"
    operator          = "GreaterThan"
  }
}

# Static threshold alert for aggregate queue depth.
# Normal state is near 0 — sustained count above 50 indicates processor failure.
# QueueMessageCount requires minimum PT1H window size.
resource "azurerm_monitor_metric_alert" "queue_backlog" {
  count = var.alert_target_alias != "" ? 1 : 0

  name                = "alert-queue-backlog"
  resource_group_name = var.resource_group_name
  scopes              = ["${azurerm_storage_account.bot.id}/queueServices/default"]
  auto_mitigate       = true
  description         = "Fires when aggregate queue depth exceeds threshold — may indicate processor failure."
  frequency           = "PT1H"
  severity            = 2
  tags                = local.common_tags
  window_size         = "PT1H"

  action {
    action_group_id = azurerm_monitor_action_group.bot_alerts[0].id
  }

  criteria {
    aggregation      = "Average"
    metric_name      = "QueueMessageCount"
    metric_namespace = "Microsoft.Storage/storageAccounts/queueServices"
    operator         = "GreaterThan"
    threshold        = 50
  }
}

resource "azurerm_monitor_metric_alert" "storage_heartbeat" {
  count = var.alert_target_alias != "" ? 1 : 0

  name                = "alert-storage-heartbeat-test"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_storage_account.bot.id]
  auto_mitigate       = true
  description         = "Test alert — fires when storage has data. Verifies alert pipeline."
  frequency           = "PT1H"
  severity            = 4
  tags                = local.common_tags
  window_size         = "PT1H"

  action {
    action_group_id = azurerm_monitor_action_group.bot_alerts[0].id
  }

  criteria {
    aggregation      = "Average"
    metric_name      = "UsedCapacity"
    metric_namespace = "Microsoft.Storage/storageAccounts"
    operator         = "GreaterThan"
    threshold        = 0
  }
}
