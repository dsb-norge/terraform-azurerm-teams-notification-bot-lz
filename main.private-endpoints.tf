#
# private DNS zones, VNet links, and private endpoints
#
# The function app accesses storage through private endpoints
# via VNet integration, keeping data-plane traffic off the public internet.
#

locals {
  # Configuration for each private endpoint.
  private_endpoints = {
    storage_blob = {
      resource_id   = azurerm_storage_account.bot.id
      subresource   = "blob"
      dns_zone_name = "privatelink.blob.core.windows.net"
    }
    storage_queue = {
      resource_id   = azurerm_storage_account.bot.id
      subresource   = "queue"
      dns_zone_name = "privatelink.queue.core.windows.net"
    }
    storage_table = {
      resource_id   = azurerm_storage_account.bot.id
      subresource   = "table"
      dns_zone_name = "privatelink.table.core.windows.net"
    }
  }

  # Deduplicated set of DNS zone names across all endpoints.
  private_dns_zone_names = toset([for pe in local.private_endpoints : pe.dns_zone_name])
}

resource "azurerm_private_dns_zone" "zones" {
  for_each = local.private_dns_zone_names

  name                = each.value
  resource_group_name = var.resource_group_name
  tags                = local.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "links" {
  for_each = local.private_dns_zone_names

  name                  = "link-${replace(each.value, ".", "-")}"
  private_dns_zone_name = azurerm_private_dns_zone.zones[each.value].name
  resource_group_name   = var.resource_group_name
  virtual_network_id    = azurerm_virtual_network.bot.id
  tags                  = local.common_tags
}

resource "azurerm_private_endpoint" "endpoints" {
  for_each = local.private_endpoints

  location            = var.location
  name                = "${module.naming.private_endpoint.name}-${replace(each.key, "_", "-")}"
  resource_group_name = var.resource_group_name
  subnet_id           = azurerm_subnet.private_endpoints.id
  tags                = local.common_tags

  private_service_connection {
    is_manual_connection           = false
    name                           = "psc-${replace(each.key, "_", "-")}"
    private_connection_resource_id = each.value.resource_id
    subresource_names              = [each.value.subresource]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.zones[each.value.dns_zone_name].id]
  }
}
