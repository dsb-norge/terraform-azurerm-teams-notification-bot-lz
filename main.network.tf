#
# virtual network and subnets
#

resource "azurerm_virtual_network" "bot" {
  address_space       = var.vnet_address_space
  location            = var.location
  name                = module.naming.virtual_network.name
  resource_group_name = var.resource_group_name
  tags                = local.common_tags
}

# Subnet for Function App Flex Consumption VNet integration.
# Delegation to Microsoft.App/environments is required for Flex Consumption.
# /24 is the recommended minimum size.
resource "azurerm_subnet" "function_app" {
  address_prefixes     = [var.subnet_function_app_prefix]
  name                 = "${module.naming.subnet.name}-func"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.bot.name

  delegation {
    name = "flex-consumption"

    service_delegation {
      name = "Microsoft.App/environments"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

# Subnet for private endpoints (storage).
# Private endpoint network policies disabled to allow PE creation.
resource "azurerm_subnet" "private_endpoints" {
  address_prefixes     = [var.subnet_private_endpoints_prefix]
  name                 = "${module.naming.subnet.name}-pe"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.bot.name

  private_endpoint_network_policies = "Disabled"
}
