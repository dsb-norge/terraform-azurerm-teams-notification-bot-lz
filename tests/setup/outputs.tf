output "resource_group_name" {
  description = "Name of the resource group created for integration tests."
  value       = azurerm_resource_group.test.name
  depends_on  = [time_sleep.rbac_propagation]
}
