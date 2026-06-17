#
# storage account with queues
#

# tflint-ignore: azurerm_resources_missing_prevent_destroy
resource "azurerm_storage_account" "bot" {
  account_replication_type = "LRS"
  account_tier             = "Standard"
  location                 = var.location
  # Storage accounts require all-lowercase alphanumeric names; the naming module
  # does not strip hyphens from within suffix elements, so we construct manually.
  name                          = "st${replace(var.name, "-", "")}"
  resource_group_name           = var.resource_group_name
  public_network_access_enabled = true
  shared_access_key_enabled     = false
  tags                          = local.common_tags
}

resource "azurerm_storage_queue" "app" {
  for_each = toset(var.app_requirements.storage_account_required_queues)

  name               = each.value
  storage_account_id = azurerm_storage_account.bot.id
}


# Network rules: Deny by default. The function app accesses storage through
# private endpoints via VNet integration. Management IPs are allowed for
# terraform operations.
#
# Two variants gated on var.data_scanner_private_link_access:
#   true  → declares the Microsoft Defender for Storage data scanner endpoint
#           as a private_link_access entry. Use in subscriptions where Defender
#           for Storage is enabled — Azure adds this entry via its
#           reconciliation pass anyway, declaring it explicitly avoids a
#           perpetual drift loop.
#   false → no private_link_access block; terraform owns the network rules
#           plainly. Use in subscriptions without Defender for Storage.
resource "azurerm_storage_account_network_rules" "bot" {
  count = var.data_scanner_private_link_access ? 1 : 0

  default_action     = "Deny"
  storage_account_id = azurerm_storage_account.bot.id
  bypass             = ["AzureServices"]
  ip_rules           = local.allowed_management_ips

  private_link_access {
    endpoint_resource_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/providers/Microsoft.Security/datascanners/storageDataScanner"
    endpoint_tenant_id   = data.azurerm_client_config.current.tenant_id
  }
}

resource "azurerm_storage_account_network_rules" "bot_no_data_scanner" {
  count = var.data_scanner_private_link_access ? 0 : 1

  default_action     = "Deny"
  storage_account_id = azurerm_storage_account.bot.id
  bypass             = ["AzureServices"]
  ip_rules           = local.allowed_management_ips
}
