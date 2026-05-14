variable "api_app_id" {
  description = "Client ID of the Entra ID app registration for API authentication (EasyAuth). Must be a valid UUID."
  type        = string

  validation {
    condition     = can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", var.api_app_id))
    error_message = "api_app_id must be a valid UUID."
  }
}

variable "api_app_object_id" {
  description = "Object ID of the Entra ID app registration for API authentication. Used by Azure Monitor action group AAD auth. The deploying identity must be an owner of this app registration when alert_target_alias is set."
  type        = string

  validation {
    condition     = can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", var.api_app_object_id))
    error_message = "api_app_object_id must be a valid UUID."
  }
}

variable "app_requirements" {
  description = <<-EOT
    App requirements declared by the function app (from app-requirements.json).
    Specifies infrastructure dependencies: queues, routes, runtime version, auth
    settings, bot service config, and required app settings.

    Pass the requirements from the app release:
      app_requirements = jsondecode(file("app-requirements.json"))

    Extra keys in the JSON (e.g. teams_app_configuration) are silently discarded
    by the object() type — only infrastructure-relevant fields are consumed.
  EOT
  type = object({
    infrastructure_requirements_unique_hash = optional(string, "")
    function_app_runtime_version            = optional(string, "10.0")
    storage_account_required_queues = optional(list(string), [
      "botoperations", "botoperations-poison",
      "notifications", "notifications-poison"
    ])
    well_known_routes = optional(object({
      azure_alert_webhook_receiver_endpoint = optional(string, "/api/v1/alert/{alias}")
    }), {})
    function_app_required_app_settings = optional(list(string), [
      "ApiAppId", "APPLICATIONINSIGHTS_CONNECTION_STRING",
      "AzureWebJobsStorage__blobServiceUri", "AzureWebJobsStorage__clientId",
      "AzureWebJobsStorage__credential", "AzureWebJobsStorage__queueServiceUri",
      "AzureWebJobsStorage__tableServiceUri", "BotAppId", "PoisonAlertAlias",
      "StorageAccountName", "TenantId"
    ])
    bot_auth_settings = optional(object({
      platform_enabled       = optional(bool, true)
      require_authentication = optional(bool, false)
      unauthenticated_action = optional(string, "AllowAnonymous")
      identity_provider      = optional(string, "azureActiveDirectory")
      required_role          = optional(string, "Notifications.Send")
    }), {})
    bot_service = optional(object({
      type               = optional(string, "SingleTenant")
      messaging_endpoint = optional(string, "/api/messages")
    }), {})
  })
}

variable "bot_app_id" {
  description = "Client ID of the Entra ID app registration for Bot Framework auth (SingleTenant). Must be a valid UUID."
  type        = string

  validation {
    condition     = can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", var.bot_app_id))
    error_message = "bot_app_id must be a valid UUID."
  }
}

variable "name" {
  description = "Base name for all resources."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.name))
    error_message = "Name must contain only lowercase letters, numbers, and hyphens."
  }

  validation {
    condition     = length(replace(var.name, "-", "")) <= 22
    error_message = "The 'name' (without hyphens) must be at most 22 characters to fit the storage account 24-char limit (prefix 'st' + name)."
  }
}

variable "resource_group_name" {
  description = "Name of the pre-existing resource group to deploy resources into."
  type        = string

  validation {
    condition     = length(var.resource_group_name) > 0
    error_message = "The 'resource_group_name' cannot be empty string."
  }
}

variable "alert_target_alias" {
  description = "Channel alias for alert webhook delivery. Empty string disables alert resources."
  type        = string
  default     = ""

  validation {
    condition     = var.alert_target_alias == "" || can(regex("^[a-zA-Z0-9_-]+$", var.alert_target_alias))
    error_message = "The 'alert_target_alias' must only contain letters, numbers, hyphens, and underscores (used as a URL path segment)."
  }
}

variable "allowed_caller_rules" {
  description = <<-EOT
    Inbound allow-list for systems calling the function app's API endpoints
    (/api/v1/*). Applied ONLY to the function app's public ipSecurityRestrictions
    — not to SCM and not to the storage account. Each rule takes either a CIDR
    or a service tag (mutually exclusive).

    Use this for:
      - Known Azure services calling the API (service_tag = "AzureCloud")
      - On-prem systems with stable egress IPs (cidr = "x.x.x.x/y")
      - Specific Azure VNets via their NAT gateway IPs

    Authorization is enforced separately by EasyAuth + the 'Notifications.Send'
    app role — allow-listing here only controls network reachability.

    Service tag constraint:
      App Service ipSecurityRestrictions accepts a narrower set of service tags
      than NSG rules. Microsoft documentation says "all publicly available
      service tags are supported" but in practice regional variants (e.g.
      'AzureCloud.NorwayEast') are rejected with "invalid ServiceTag".

      Known-working tags: AzureCloud, ActionGroup, AzureBotService.
      Other tags listed as supported but unverified here: ApplicationInsightsAvailability,
      AzureFrontDoor.Backend, AzureTrafficManager.

      This variable does NOT validate the tag value against a known list —
      MS may add/remove supported tags. An invalid tag will surface at apply
      time with a clear ARM error.

    Example:
      allowed_caller_rules = [
        { name = "azure-cloud", description = "Any Azure service", service_tag = "AzureCloud" },
        { name = "onprem-monitoring", description = "On-prem monitoring egress", cidr = "203.0.113.10/32" },
      ]
  EOT
  type = list(object({
    name        = string
    description = string
    cidr        = optional(string)
    service_tag = optional(string)
  }))
  default = []

  validation {
    condition     = alltrue([for rule in var.allowed_caller_rules : !can(regex("[;,]", rule.description))])
    error_message = "Rule descriptions must not contain ';' or ',' — Azure rejects these characters in IpSecurityRestriction.Description."
  }

  validation {
    condition = alltrue([
      for rule in var.allowed_caller_rules :
      (rule.cidr != null && rule.service_tag == null) || (rule.cidr == null && rule.service_tag != null)
    ])
    error_message = "Each allowed_caller_rules entry must set exactly one of 'cidr' or 'service_tag' (not both, not neither)."
  }

  validation {
    condition = alltrue([
      for rule in var.allowed_caller_rules :
      rule.cidr == null || can(cidrhost(rule.cidr, 0))
    ])
    error_message = "When 'cidr' is set on an allowed_caller_rules entry, it must be a valid CIDR (e.g. '10.0.0.0/24' or '1.2.3.4/32')."
  }

  validation {
    condition = alltrue([
      for rule in var.allowed_caller_rules :
      rule.service_tag == null || can(regex("^[A-Za-z][A-Za-z0-9.]*$", rule.service_tag))
    ])
    error_message = "When 'service_tag' is set, it must be a valid Azure service tag name (letters/digits/dots, e.g. 'AzureCloud', 'AzureCloud.NorwayEast')."
  }
}

variable "app_namespace" {
  description = "Root .NET namespace of the deployed function app. Used in Log Analytics KQL queries to filter by logger category."
  type        = string
  default     = "TeamsNotificationBot"

  validation {
    condition     = length(var.app_namespace) > 0
    error_message = "The 'app_namespace' cannot be empty string."
  }
}

variable "debug_ip_rules" {
  description = <<-EOT
    CIDR ranges allowed inbound for human operators and CI runners. Applied to:
      - the function app's public endpoint (manual /api/* smoke-testing)
      - the SCM/Kudu endpoint (live log streaming, portal debugging)
      - the storage account network rules (terraform apply uploading deployment packages)

    This is NOT for application callers pushing messages to the API — use
    allowed_caller_rules for that. Typical use: the DSB VPN CIDR for operators.
  EOT
  type = list(object({
    name        = string
    description = string
    cidr        = string
  }))
  default = []

  validation {
    condition     = alltrue([for rule in var.debug_ip_rules : !can(regex("[;,]", rule.description))])
    error_message = "Rule descriptions must not contain ';' or ',' — Azure rejects these characters in IpSecurityRestriction.Description."
  }

  validation {
    condition     = alltrue([for rule in var.debug_ip_rules : can(cidrhost(rule.cidr, 0))])
    error_message = "Each debug_ip_rules entry must have a valid CIDR (e.g. '10.0.0.0/24' or '1.2.3.4/32')."
  }
}

variable "deploy_github_actions_from" {
  description = <<-EOF
    Map of GitHub repositories that should get federated identity credentials for CI/CD deployment.
    Creates a deploy UAMI with FICs when non-empty. Keys are repository names.
    The GitHub organization is set via var.github_org.

    Available settings:
      environments        : list of GitHub environments to allow access from.
      branches            : list of branches to allow access from.
      tags                : list of tags to allow access from.
      pull_request_events : if true, allow access from pull request events.

    RECOMMENDATION — prefer 'environments' over 'branches' or 'tags':
      Standard FICs match the OIDC token's 'subject' claim EXACTLY (no wildcards).
      Tag/branch patterns like 'v*' or 'main' that depend on wildcard matching
      do NOT work without a flexible FIC + claimsMatchingExpression (preview, not
      supported by azurerm provider yet).

      Use a GitHub environment FIC and let GitHub enforce the deployment rules:
        1. Configure 'environments = ["dev"]' (or "production", etc.)
        2. In the app repo: Settings > Environments > <env>
           - Add required reviewers (optional)
           - Add deployment branch/tag policy (e.g. only tags 'app-v*')
        3. Workflow declares 'environment: <env>' in its deploy job

      This gives standard FIC reliability + GitHub-enforced wildcard restrictions.

      The 'tags' field has a built-in name-sanitization for wildcards (* → 'wildcard')
      to avoid Azure's FIC name validation rejecting the resource, but a wildcard
      subject still won't actually match any tag push without claimsMatchingExpression.
  EOF
  type = map(object({
    pull_request_events = optional(bool, false)
    environments        = optional(list(string), [])
    branches            = optional(list(string), [])
    tags                = optional(list(string), [])
  }))
  default = {}

  validation {
    error_message = "deploy_github_actions_from.environments: All configured environments are required to have length!"
    condition = alltrue(flatten(
      [for repo_name, repo_cfg in var.deploy_github_actions_from :
        try(length(repo_cfg.environments) > 0, false) ?
        alltrue([for env in repo_cfg.environments :
          length(env) > 0
        ]) : true
    ]))
  }
  validation {
    error_message = "deploy_github_actions_from.branches: All configured branches are required to have length!"
    condition = alltrue(flatten(
      [for repo_name, repo_cfg in var.deploy_github_actions_from :
        try(length(repo_cfg.branches) > 0, false) ?
        alltrue([for branch in repo_cfg.branches :
          length(branch) > 0
        ]) : true
    ]))
  }
  validation {
    error_message = "deploy_github_actions_from.tags: All configured tags are required to have length!"
    condition = alltrue(flatten(
      [for repo_name, repo_cfg in var.deploy_github_actions_from :
        try(length(repo_cfg.tags) > 0, false) ?
        alltrue([for tag in repo_cfg.tags :
          length(tag) > 0
        ]) : true
    ]))
  }
}

variable "existing_bot_uami_id" {
  description = <<-EOT
    Full resource ID of a pre-created user-assigned managed identity for the bot.
    When set, the module skips UAMI creation and uses the provided identity.
    The identity must already exist and be accessible to the deploying principal.

    Example:
      /subscriptions/.../resourceGroups/.../providers/Microsoft.ManagedIdentity/userAssignedIdentities/uai-my-bot
  EOT
  type        = string
  default     = ""

  validation {
    condition = (
      var.existing_bot_uami_id == ""
      || can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft\\.ManagedIdentity/userAssignedIdentities/[^/]+$", var.existing_bot_uami_id))
    )
    error_message = "existing_bot_uami_id must be a valid Azure resource ID for a user-assigned managed identity, or empty string to create a new one."
  }
}

variable "github_org" {
  description = "GitHub organization name for OIDC subject claims in deploy UAMI federated identity credentials."
  type        = string
  default     = ""

  validation {
    condition     = var.github_org == "" || can(regex("^[a-zA-Z0-9-]+$", var.github_org))
    error_message = "github_org must be a valid GitHub organization name (alphanumeric and hyphens)."
  }
}

variable "location" {
  description = "Azure region for all resources."
  type        = string
  default     = "norwayeast"

  validation {
    condition     = length(var.location) > 0
    error_message = "The 'location' cannot be empty string."
  }
}

variable "network_config" {
  description = <<-EOT
    Network configuration for the module. Two modes:

    Mode 1 — Module-managed (default):
      Leave network_config as default or set create_network = true.
      Module creates VNet, subnets, private DNS zones, and VNet links.

    Mode 2 — Bring your own network:
      Set create_network = false and provide existing subnet IDs.
      Module skips VNet/subnet/DNS zone creation entirely.
      Set manage_private_dns_zone_groups = false if central infrastructure
      (e.g. Azure Policy) handles private DNS registration.

    private_dns_zone_group_name controls the name used for the zone group
    created on each private endpoint. Projects that coexist with CAF ALZ
    Azure Policy should set this to "deployedByPolicy" so the policy's
    group-creation step finds a matching group and skips.
  EOT
  type = object({
    create_network = optional(bool, true)

    # Mode 1 only (ignored when create_network = false):
    vnet_address_space              = optional(list(string), ["10.0.0.0/16"])
    subnet_function_app_prefix      = optional(string, "10.0.0.0/24")
    subnet_private_endpoints_prefix = optional(string, "10.0.1.0/24")

    # Mode 2 only (required when create_network = false):
    existing_subnet_function_app_id      = optional(string, "")
    existing_subnet_private_endpoints_id = optional(string, "")

    # PE DNS behavior (both modes):
    manage_private_dns_zone_groups = optional(bool, true)
    private_dns_zone_resource_ids  = optional(map(string), {})
    private_dns_zone_group_name    = optional(string, "default")
  })
  default = {}

  validation {
    condition = (
      var.network_config.create_network
      || (
        var.network_config.existing_subnet_function_app_id != ""
        && var.network_config.existing_subnet_private_endpoints_id != ""
      )
    )
    error_message = "When create_network is false, both existing_subnet_function_app_id and existing_subnet_private_endpoints_id must be provided."
  }

  validation {
    condition = !(
      !var.network_config.create_network
      && var.network_config.manage_private_dns_zone_groups
      && length(var.network_config.private_dns_zone_resource_ids) == 0
    )
    error_message = "When create_network is false and manage_private_dns_zone_groups is true, private_dns_zone_resource_ids must be provided (the module cannot create DNS zones without a VNet to link them to)."
  }

  validation {
    condition = (
      !var.network_config.create_network
      || can(cidrhost(var.network_config.subnet_function_app_prefix, 0))
    )
    error_message = "subnet_function_app_prefix must be a valid CIDR block."
  }

  validation {
    condition = (
      !var.network_config.create_network
      || (
        can(tonumber(split("/", var.network_config.subnet_function_app_prefix)[1]))
        && tonumber(split("/", var.network_config.subnet_function_app_prefix)[1]) <= 27
      )
    )
    error_message = "subnet_function_app_prefix must be at least /27 (recommended size for Flex Consumption)."
  }

  validation {
    condition = (
      !var.network_config.create_network
      || can(cidrhost(var.network_config.subnet_private_endpoints_prefix, 0))
    )
    error_message = "subnet_private_endpoints_prefix must be a valid CIDR block."
  }

  validation {
    condition = (
      !var.network_config.create_network
      || (
        can(tonumber(split("/", var.network_config.subnet_private_endpoints_prefix)[1]))
        && tonumber(split("/", var.network_config.subnet_private_endpoints_prefix)[1]) <= 28
      )
    )
    error_message = "subnet_private_endpoints_prefix must be at least /28."
  }
}

variable "tags" {
  description = "Additional tags to apply to all resources. Caller tags take precedence over module defaults on conflict."
  type        = map(string)
  default     = {}
}

