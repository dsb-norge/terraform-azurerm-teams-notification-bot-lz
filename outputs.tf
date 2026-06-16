output "application_insights_connection_string" {
  description = "The connection string of the Application Insights instance. Null when `enable_observability = false`."
  value       = var.enable_observability ? azurerm_application_insights.bot[0].connection_string : null
  sensitive   = true
}

output "application_insights_instrumentation_key" {
  description = "The instrumentation key of the Application Insights instance. Null when `enable_observability = false`."
  value       = var.enable_observability ? azurerm_application_insights.bot[0].instrumentation_key : null
  sensitive   = true
}

output "bot_service_name" {
  description = "The name of the Bot Service."
  value       = azurerm_bot_service_azure_bot.bot.name
}

output "deploy_uami_client_id" {
  description = "The client ID of the deploy user-assigned managed identity. Null when deploy_github_actions_from is empty."
  value       = length(var.deploy_github_actions_from) > 0 ? azurerm_user_assigned_identity.deploy[0].client_id : null
}

output "function_app_hostname" {
  description = "The default hostname of the Function App."
  value       = azapi_resource.bot.output.properties.defaultHostName
}

output "function_app_name" {
  description = "The name of the Function App."
  value       = azapi_resource.bot.name
}

output "infrastructure_requirements_unique_hash" {
  description = "Fingerprint of infra-relevant app requirements. Compare against a new release to detect if terraform apply is needed."
  value       = var.app_requirements.infrastructure_requirements_unique_hash
}

output "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics workspace used by the module — either the one created here or the BYO workspace passed via `var.log_analytics_workspace_id`. Null when `enable_observability = false`."
  value       = local.log_analytics_workspace_id
}

output "private_endpoint_ids" {
  description = "Map of private endpoint resource IDs."
  value = {
    for k, pe in(
      var.network_config.manage_private_dns_zone_groups
      ? azurerm_private_endpoint.managed
      : azurerm_private_endpoint.unmanaged
    ) : k => pe.id
  }
}

output "resource_group_name" {
  description = "The name of the resource group (passthrough from input)."
  value       = var.resource_group_name
}

output "storage_account_name" {
  description = "The name of the Storage Account."
  value       = azurerm_storage_account.bot.name
}

output "subnet_function_app_id" {
  description = "ID of the function app VNet integration subnet."
  value       = local.subnet_function_app_id
}

output "subnet_private_endpoints_id" {
  description = "ID of the private endpoints subnet."
  value       = local.subnet_private_endpoints_id
}

output "uami_client_id" {
  description = "The client ID of the bot's user-assigned managed identity."
  value       = local.bot_uami_client_id
}

output "uami_principal_id" {
  description = "The principal ID of the bot's user-assigned managed identity."
  value       = local.bot_uami_principal_id
}

output "vnet_id" {
  description = "ID of the VNet (null when using existing network)."
  value       = local.create_network ? azurerm_virtual_network.bot[0].id : null
}
