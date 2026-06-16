output "bot_service_name" {
  description = "The name of the Bot Service."
  value       = module.teams_notification_bot.bot_service_name
}

output "function_app_hostname" {
  description = "The default hostname of the Function App."
  value       = module.teams_notification_bot.function_app_hostname
}

output "function_app_name" {
  description = "The name of the Function App."
  value       = module.teams_notification_bot.function_app_name
}

# Provided to the module — what we'd compare the module's output against
# to prove BYO LAW took effect.
output "shared_log_analytics_workspace_id" {
  description = "The ID of the externally-managed Log Analytics workspace this example owns."
  value       = azurerm_log_analytics_workspace.shared.id
}

# Should equal `shared_log_analytics_workspace_id` — proves the module
# used the externally-provided LAW, not a self-created one.
output "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics workspace the module is wired to. Should match `shared_log_analytics_workspace_id` in this example."
  value       = module.teams_notification_bot.log_analytics_workspace_id
}

output "application_insights_connection_string" {
  description = "Set even with BYO LAW — App Insights is still created and points at the shared workspace."
  value       = module.teams_notification_bot.application_insights_connection_string
  sensitive   = true
}

output "resource_group_name" {
  description = "The name of the resource group (passthrough from input)."
  value       = module.teams_notification_bot.resource_group_name
}

output "storage_account_name" {
  description = "The name of the Storage Account."
  value       = module.teams_notification_bot.storage_account_name
}
