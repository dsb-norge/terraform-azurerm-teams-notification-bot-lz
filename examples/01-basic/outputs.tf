output "resource_group_name" {
  description = "The name of the resource group (passthrough from input)."
  value       = module.teams_notification_bot.resource_group_name
}

output "function_app_name" {
  description = "The name of the Function App."
  value       = module.teams_notification_bot.function_app_name
}

output "bot_service_name" {
  description = "The name of the Bot Service."
  value       = module.teams_notification_bot.bot_service_name
}
