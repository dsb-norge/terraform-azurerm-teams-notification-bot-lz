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
  for_each = local.create_dns_zones ? local.private_dns_zone_names : toset([])

  name                = each.value
  resource_group_name = var.resource_group_name
  tags                = local.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "links" {
  for_each = local.create_dns_zones ? local.private_dns_zone_names : toset([])

  name                  = "link-${replace(each.value, ".", "-")}"
  private_dns_zone_name = azurerm_private_dns_zone.zones[each.value].name
  resource_group_name   = var.resource_group_name
  virtual_network_id    = azurerm_virtual_network.bot[0].id
  tags                  = local.common_tags
}

# Private endpoints with module-managed DNS zone groups (default).
# Used when manage_private_dns_zone_groups = true.
resource "azurerm_private_endpoint" "managed" {
  for_each = {
    for k, v in local.private_endpoints : k => v
    if var.network_config.manage_private_dns_zone_groups
  }

  location            = var.location
  name                = "${module.naming.private_endpoint.name}-${replace(each.key, "_", "-")}"
  resource_group_name = var.resource_group_name
  subnet_id           = local.subnet_private_endpoints_id
  tags                = local.common_tags

  private_service_connection {
    is_manual_connection           = false
    name                           = "psc-${replace(each.key, "_", "-")}"
    private_connection_resource_id = each.value.resource_id
    subresource_names              = [each.value.subresource]
  }

  dynamic "private_dns_zone_group" {
    for_each = lookup(local.private_dns_zone_ids, each.value.subresource, "") != "" ? ["this"] : []

    content {
      name                 = "default"
      private_dns_zone_ids = [local.private_dns_zone_ids[each.value.subresource]]
    }
  }
}

# Private endpoints without DNS zone groups (enterprise pattern).
# Used when manage_private_dns_zone_groups = false — central infrastructure
# (e.g. Azure Policy) handles DNS registration after PE creation.
resource "azurerm_private_endpoint" "unmanaged" {
  for_each = {
    for k, v in local.private_endpoints : k => v
    if !var.network_config.manage_private_dns_zone_groups
  }

  location            = var.location
  name                = "${module.naming.private_endpoint.name}-${replace(each.key, "_", "-")}"
  resource_group_name = var.resource_group_name
  subnet_id           = local.subnet_private_endpoints_id
  tags                = local.common_tags

  private_service_connection {
    is_manual_connection           = false
    name                           = "psc-${replace(each.key, "_", "-")}"
    private_connection_resource_id = each.value.resource_id
    subresource_names              = [each.value.subresource]
  }

  lifecycle {
    ignore_changes = [private_dns_zone_group]
  }
}
