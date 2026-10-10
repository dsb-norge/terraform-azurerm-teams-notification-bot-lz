# Test setup helper — creates a UAMI in a separate resource group to simulate
# the enterprise pattern where the identity team pre-creates the bot UAMI.

# random part of the names, so that runs do not collide
resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

resource "azurerm_resource_group" "identity" {
  location = "norwayeast"
  name     = "rg-${var.name}-${random_string.suffix.result}-identity"
  tags     = {}

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_user_assigned_identity" "bot" {
  location            = azurerm_resource_group.identity.location
  name                = "uai-${var.name}"
  resource_group_name = azurerm_resource_group.identity.name
  tags                = {}
}
