output "application_insights_connection_string" {
  description = "Null because observability is disabled in this example."
  value       = module.teams_notification_bot.application_insights_connection_string
  sensitive   = true
}

output "application_insights_instrumentation_key" {
  description = "Null because observability is disabled in this example."
  value       = module.teams_notification_bot.application_insights_instrumentation_key
  sensitive   = true
}

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

output "log_analytics_workspace_id" {
  description = "Null because observability is disabled in this example."
  value       = module.teams_notification_bot.log_analytics_workspace_id
}

output "resource_group_name" {
  description = "The name of the resource group (passthrough from input)."
  value       = module.teams_notification_bot.resource_group_name
}

output "storage_account_name" {
  description = "The name of the Storage Account."
  value       = module.teams_notification_bot.storage_account_name
}
