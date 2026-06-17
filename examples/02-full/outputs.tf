output "application_insights_connection_string" {
  description = "The connection string of the Application Insights instance."
  value       = module.teams_notification_bot.application_insights_connection_string
  sensitive   = true
}

output "bot_service_name" {
  description = "The name of the Bot Service."
  value       = module.teams_notification_bot.bot_service_name
}

output "deploy_uami_client_id" {
  description = "The client ID of the deploy user-assigned managed identity. Null when deploy_github_actions_from is empty."
  value       = module.teams_notification_bot.deploy_uami_client_id
}

output "function_app_name" {
  description = "The name of the Function App."
  value       = module.teams_notification_bot.function_app_name
}

output "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics workspace."
  value       = module.teams_notification_bot.log_analytics_workspace_id
}

output "private_endpoint_ids" {
  description = "Map of private endpoint resource IDs."
  value       = module.teams_notification_bot.private_endpoint_ids
}

output "resource_group_name" {
  description = "The name of the resource group (passthrough from input)."
  value       = module.teams_notification_bot.resource_group_name
}

output "uami_client_id" {
  description = "The client ID of the bot's user-assigned managed identity."
  value       = module.teams_notification_bot.uami_client_id
}

output "uami_principal_id" {
  description = "The principal ID of the bot's user-assigned managed identity."
  value       = module.teams_notification_bot.uami_principal_id
}

output "vnet_id" {
  description = "ID of the VNet created by the module."
  value       = module.teams_notification_bot.vnet_id
}
