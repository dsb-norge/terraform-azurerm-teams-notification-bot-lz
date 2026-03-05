output "api_app_id" {
  description = "Random UUID for API app registration (test placeholder)."
  value       = random_uuid.api_app_id.result
}

output "api_app_object_id" {
  description = "Random UUID for API app object ID (test placeholder)."
  value       = random_uuid.api_app_object_id.result
}

output "bot_app_id" {
  description = "Random UUID for bot app registration (test placeholder)."
  value       = random_uuid.bot_app_id.result
}

output "resource_group_name" {
  description = "The name of the resource group."
  value       = azurerm_resource_group.this.name
}

output "subnet_function_app_id" {
  description = "ID of the function app subnet (WITHOUT delegation)."
  value       = azurerm_subnet.func_no_delegation.id
}

output "subnet_private_endpoints_id" {
  description = "ID of the private endpoints subnet."
  value       = azurerm_subnet.pe.id
}
