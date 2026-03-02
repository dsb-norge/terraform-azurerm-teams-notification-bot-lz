variable "api_app_id" {
  description = "Client ID of the Entra ID app registration for API authentication (EasyAuth). Must be a valid UUID."
  type        = string

  validation {
    condition     = can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", var.api_app_id))
    error_message = "api_app_id must be a valid UUID."
  }
}

variable "api_app_object_id" {
  description = "Object ID of the Entra ID app registration for API authentication. Used by Azure Monitor action group AAD auth."
  type        = string

  validation {
    condition     = can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", var.api_app_object_id))
    error_message = "api_app_object_id must be a valid UUID."
  }
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

variable "app_namespace" {
  description = "Root .NET namespace of the deployed function app. Used in Log Analytics KQL queries to filter by logger category."
  type        = string
  default     = "TeamsNotificationBot"

  validation {
    condition     = length(var.app_namespace) > 0
    error_message = "The 'app_namespace' cannot be empty string."
  }
}

variable "deploy_github_actions_from" {
  description = <<-EOF
    Map of GitHub repositories that should get federated identity credentials for CI/CD deployment.
    Creates a deploy UAMI with FICs when non-empty. Keys are repository names. The GitHub organization is set via var.github_org.

    Available settings:
      pull_request_events: if true, allow access from pull request events.
      environments: list of GitHub environments to allow access from.
      branches: list of branches to allow access from.
      tags: list of tags to allow access from.
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

variable "management_ip_rules" {
  description = "IP addresses/ranges allowed for management access (terraform apply, deployment, testing). Used by function app and storage network rules."
  type = list(object({
    name        = string
    description = string
    cidr        = string
  }))
  default = []

  validation {
    condition     = alltrue([for rule in var.management_ip_rules : can(cidrhost(rule.cidr, 0))])
    error_message = "Each management_ip_rules entry must have a valid CIDR (e.g. '10.0.0.0/24' or '1.2.3.4/32')."
  }
}

variable "subnet_function_app_prefix" {
  description = "Address prefix for the Function App VNet integration subnet. Must be at least /24."
  type        = string
  default     = "10.0.0.0/24"

  validation {
    condition     = can(cidrhost(var.subnet_function_app_prefix, 0))
    error_message = "The 'subnet_function_app_prefix' must be a valid CIDR block."
  }

  validation {
    condition     = can(tonumber(split("/", var.subnet_function_app_prefix)[1])) && tonumber(split("/", var.subnet_function_app_prefix)[1]) <= 24
    error_message = "The 'subnet_function_app_prefix' must be at least /24 (prefix length <= 24)."
  }
}

variable "subnet_private_endpoints_prefix" {
  description = "Address prefix for the private endpoints subnet."
  type        = string
  default     = "10.0.1.0/24"

  validation {
    condition     = can(cidrhost(var.subnet_private_endpoints_prefix, 0))
    error_message = "The 'subnet_private_endpoints_prefix' must be a valid CIDR block."
  }
}

variable "tags" {
  description = "Additional tags to apply to all resources. Caller tags take precedence over module defaults on conflict."
  type        = map(string)
  default     = {}
}

variable "vnet_address_space" {
  description = "Address space for the virtual network."
  type        = list(string)
  default     = ["10.0.0.0/16"]

  validation {
    condition     = length(var.vnet_address_space) > 0
    error_message = "The 'vnet_address_space' must contain at least one CIDR block."
  }
}
