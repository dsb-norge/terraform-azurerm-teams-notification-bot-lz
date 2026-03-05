#
# virtual network and subnets
#

resource "azurerm_virtual_network" "bot" {
  count = local.create_network ? 1 : 0

  address_space       = var.network_config.vnet_address_space
  location            = var.location
  name                = module.naming.virtual_network.name
  resource_group_name = var.resource_group_name
  tags                = local.common_tags
}

# Subnet for Function App Flex Consumption VNet integration.
# Delegation to Microsoft.App/environments is required for Flex Consumption.
# /24 is the recommended minimum size.
resource "azurerm_subnet" "function_app" {
  count = local.create_network ? 1 : 0

  address_prefixes     = [var.network_config.subnet_function_app_prefix]
  name                 = "${module.naming.subnet.name}-func"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.bot[0].name

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
  count = local.create_network ? 1 : 0

  address_prefixes     = [var.network_config.subnet_private_endpoints_prefix]
  name                 = "${module.naming.subnet.name}-pe"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.bot[0].name

  private_endpoint_network_policies = "Disabled"
}
