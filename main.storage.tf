#
# storage account with queues
#

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

resource "azurerm_storage_queue" "notifications" {
  name               = "notifications"
  storage_account_id = azurerm_storage_account.bot.id
}

resource "azurerm_storage_queue" "notifications_poison" {
  name               = "notifications-poison"
  storage_account_id = azurerm_storage_account.bot.id
}

resource "azurerm_storage_queue" "botoperations" {
  name               = "botoperations"
  storage_account_id = azurerm_storage_account.bot.id
}

resource "azurerm_storage_queue" "botoperations_poison" {
  name               = "botoperations-poison"
  storage_account_id = azurerm_storage_account.bot.id
}

# Network rules: Deny by default. The function app accesses storage through private
# endpoints via VNet integration. Management IPs are allowed for terraform operations.
resource "azurerm_storage_account_network_rules" "bot" {
  default_action     = "Deny"
  storage_account_id = azurerm_storage_account.bot.id
  bypass             = ["AzureServices"]
  ip_rules           = local.allowed_management_ips
}
