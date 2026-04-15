output "uami_client_id" {
  description = "Client ID of the pre-created UAMI."
  value       = azurerm_user_assigned_identity.bot.client_id
}

output "uami_id" {
  description = "Full resource ID of the pre-created UAMI."
  value       = azurerm_user_assigned_identity.bot.id
}

output "uami_principal_id" {
  description = "Principal ID of the pre-created UAMI."
  value       = azurerm_user_assigned_identity.bot.principal_id
}
