#
# entry point for the landing zone module
#

locals {
  # Inlined name composition — replaces module "naming" / Azure/naming/azurerm
  # v0.4.3. Every type below uses AVM's <slug>-<suffix> pattern with no
  # randomness (.name, not .name_unique) and dashes=true (no dash stripping),
  # so substr("<slug>-${var.name}", 0, <max>) is byte-identical to AVM .name.
  # Slugs and max_length values are frozen from AVM's resourceDefinition
  # catalog at v0.4.3; substr on every type preserves AVM's per-type truncation
  # so output stays identical to AVM for any valid var.name.
  names = {
    app_service_plan        = substr("plan-${var.name}", 0, 40)
    function_app            = substr("func-${var.name}", 0, 60)
    application_insights    = substr("appi-${var.name}", 0, 260)
    log_analytics_workspace = substr("log-${var.name}", 0, 63)
    monitor_action_group    = substr("mag-${var.name}", 0, 260)
    user_assigned_identity  = substr("uai-${var.name}", 0, 128)
    virtual_network         = substr("vnet-${var.name}", 0, 64)
    subnet                  = substr("snet-${var.name}", 0, 80)
    private_endpoint        = substr("pe-${var.name}", 0, 80)
  }

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

  # Reference the data sources in BYON mode to ensure postcondition validation
  # runs before resources consume the subnet IDs.
  subnet_function_app_id = (
    local.create_network
    ? azurerm_subnet.function_app[0].id
    : data.azapi_resource.byon_subnet_function_app[0].resource_id
  )

  subnet_private_endpoints_id = (
    local.create_network
    ? azurerm_subnet.private_endpoints[0].id
    : data.azapi_resource.byon_subnet_private_endpoints[0].resource_id
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
