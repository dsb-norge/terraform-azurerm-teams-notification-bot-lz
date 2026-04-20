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


# Network rules: Deny by default. The function app accesses storage through private
# endpoints via VNet integration. Management IPs are allowed for terraform operations.
resource "azurerm_storage_account_network_rules" "bot" {
  default_action     = "Deny"
  storage_account_id = azurerm_storage_account.bot.id
  bypass             = ["AzureServices"]
  ip_rules           = local.allowed_debug_ips
}
