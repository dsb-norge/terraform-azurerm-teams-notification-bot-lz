#
# entry point for the landing zone module
#

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.2"
  suffix  = [var.name]
}

locals {
  tenant_id = data.azurerm_client_config.current.tenant_id

  # Derived: storage ip_rules require single IPs without /32 suffix
  allowed_management_ips = [for rule in var.management_ip_rules : trimsuffix(rule.cidr, "/32")]

  common_tags = merge(
    {
      "Environment" = var.name
      "component"   = "teams-notification-bot"
      "managed-by"  = "terraform"
    },
    var.tags,
  )

  # Query pack queries have a 5-label limit (Azure API restriction).
  # Use a fixed subset instead of the full common_tags.
  query_labels = {
    "Environment" = var.name
    "component"   = "teams-notification-bot"
    "managed-by"  = "terraform"
  }

  # Network mode resolution
  create_network = var.network_config.create_network

  subnet_function_app_id = (
    local.create_network
    ? azurerm_subnet.function_app[0].id
    : var.network_config.existing_subnet_function_app_id
  )

  subnet_private_endpoints_id = (
    local.create_network
    ? azurerm_subnet.private_endpoints[0].id
    : var.network_config.existing_subnet_private_endpoints_id
  )

  # DNS zone resolution: caller-provided > module-created > none
  create_dns_zones = (
    local.create_network
    && var.network_config.manage_private_dns_zone_groups
    && length(var.network_config.private_dns_zone_resource_ids) == 0
  )

  # Map from subresource key to DNS zone ID (when managed).
  # Module-created zones are keyed by dns_zone_name in the resource, so remap
  # via the private_endpoints local to get subresource keys.
  private_dns_zone_ids = (
    local.create_dns_zones
    ? { for k, pe in local.private_endpoints : pe.subresource => azurerm_private_dns_zone.zones[pe.dns_zone_name].id }
    : var.network_config.private_dns_zone_resource_ids
  )
}

data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}
