#
# user-assigned managed identities
#

# Bot UAMI — used by function app for Azure resource access (storage)
resource "azurerm_user_assigned_identity" "bot" {
  location            = var.location
  name                = module.naming.user_assigned_identity.name
  resource_group_name = var.resource_group_name
  tags                = local.common_tags
}

# Deploy UAMI — created when GitHub Actions CI/CD is configured
resource "azurerm_user_assigned_identity" "deploy" {
  count = length(var.deploy_github_actions_from) > 0 ? 1 : 0

  location            = var.location
  name                = "${module.naming.user_assigned_identity.name}-deploy"
  resource_group_name = var.resource_group_name
  tags                = local.common_tags

  lifecycle {
    precondition {
      condition     = var.github_org != ""
      error_message = "The 'github_org' must be set when 'deploy_github_actions_from' is non-empty."
    }
  }
}

#
# Federated identity credentials for GitHub Actions OIDC authentication
#

locals {
  gh_org = var.github_org
  github_oidc_subject_claims = merge([for repo_name, repo_cfg in var.deploy_github_actions_from :
    merge(
      repo_cfg.pull_request_events ? {
        "pull-requests-in-${local.gh_org}__${repo_name}" = "repo:${local.gh_org}/${repo_name}:pull_request"
      } : {},
      { for env in repo_cfg.environments :
        "env-${env}-in-${local.gh_org}__${repo_name}" => "repo:${local.gh_org}/${repo_name}:environment:${env}"
      },
      { for branch in repo_cfg.branches :
        "branch-${branch}-in-${local.gh_org}__${repo_name}" => "repo:${local.gh_org}/${repo_name}:ref:refs/heads/${branch}"
      },
      { for tag in repo_cfg.tags :
        "tag-${tag}-in-${local.gh_org}__${repo_name}" => "repo:${local.gh_org}/${repo_name}:ref:refs/tags/${tag}"
      },
    )
  ]...)
}

resource "azurerm_federated_identity_credential" "deploy_github" {
  for_each = local.github_oidc_subject_claims

  audience  = ["api://AzureADTokenExchange"]
  issuer    = "https://token.actions.githubusercontent.com"
  name      = each.key
  parent_id = azurerm_user_assigned_identity.deploy[0].id
  subject   = each.value
}
