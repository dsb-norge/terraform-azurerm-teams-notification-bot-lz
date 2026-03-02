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
}

data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}
