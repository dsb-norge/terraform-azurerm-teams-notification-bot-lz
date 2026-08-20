#
# user-assigned managed identities
#

locals {
  create_bot_uami = var.existing_bot_uami_id == ""

  # Unified references — all consumers use these instead of the resource/data directly.
  # When BYO is in use, we read the existing UAMI via azapi (cross-subscription friendly,
  # since enterprise patterns often place identities in a separate subscription).
  bot_uami_id           = local.create_bot_uami ? azurerm_user_assigned_identity.bot[0].id : var.existing_bot_uami_id
  bot_uami_client_id    = local.create_bot_uami ? azurerm_user_assigned_identity.bot[0].client_id : data.azapi_resource.existing_bot[0].output.properties.clientId
  bot_uami_principal_id = local.create_bot_uami ? azurerm_user_assigned_identity.bot[0].principal_id : data.azapi_resource.existing_bot[0].output.properties.principalId
}

# Bot UAMI — created by the module when no existing identity is provided
resource "azurerm_user_assigned_identity" "bot" {
  count = local.create_bot_uami ? 1 : 0

  location            = var.location
  name                = local.names.user_assigned_identity
  resource_group_name = var.resource_group_name
  tags                = local.common_tags
}

# Bot UAMI — read existing identity when provided by the caller.
# Uses azapi (not azurerm_user_assigned_identity data source) because the latter
# is restricted to the provider's configured subscription. Enterprise identity
# teams often place UAMIs in a dedicated identity subscription, separate from
# where the bot infrastructure is deployed. azapi reads by full resource ID and
# works cross-subscription.
data "azapi_resource" "existing_bot" {
  count = local.create_bot_uami ? 0 : 1

  type                   = "Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31"
  resource_id            = var.existing_bot_uami_id
  response_export_values = ["properties.clientId", "properties.principalId"]
}

# Deploy UAMI — created when GitHub Actions CI/CD is configured
resource "azurerm_user_assigned_identity" "deploy" {
  count = length(var.deploy_github_actions_from) > 0 ? 1 : 0

  location            = var.location
  name                = "${local.names.user_assigned_identity}-deploy"
  resource_group_name = var.resource_group_name
  tags                = local.common_tags

  lifecycle {
    precondition {
      condition     = var.github_org != ""
      error_message = "The 'github_org' must be set when 'deploy_github_actions_from' is non-empty."
    }
    precondition {
      condition = (
        var.github_org_id != ""
        || alltrue([for repo_cfg in var.deploy_github_actions_from : repo_cfg.repository_id == null])
      )
      error_message = "The 'github_org_id' must be set when any repository in 'deploy_github_actions_from' sets 'repository_id'."
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
      # FIC name must match Azure's rules (letters, numbers, hyphens). Tag patterns
      # may contain '*' for wildcard matching — replace it with 'wildcard' in the
      # name. The subject keeps the raw tag pattern.
      #
      # NOTE: A standard FIC matches the subject EXACTLY. A subject containing
      # '*' (e.g. 'refs/tags/v*') will not match any real tag push without an
      # additional claimsMatchingExpression / flexible FIC. For wildcard tag
      # support, either list explicit tags here or switch to the flexible FIC
      # resource. See:
      # https://learn.microsoft.com/en-us/entra/workload-id/workload-identity-federation-claims-claim-matching-rules
      { for tag in repo_cfg.tags :
        "tag-${replace(tag, "*", "wildcard")}-in-${local.gh_org}__${repo_name}" => "repo:${local.gh_org}/${repo_name}:ref:refs/tags/${tag}"
      },
    )
  ]...)

  # Since 2026-07-15 GitHub issues two OIDC subject-claim formats for Actions tokens:
  #   classic:   repo:<org>/<repo>:<trigger>                        — repos created before 2026-07-15
  #   immutable: repo:<org>@<org-id>/<repo>@<repo-id>:<trigger>     — repos created, renamed or
  #              transferred after the cutoff, and repos opted in to immutable subjects
  # A standard FIC matches its subject exactly, so a classic-format FIC silently stops
  # matching the moment its repo starts issuing immutable-format subjects. Flexible FICs
  # (claimsMatchingExpression) are not available on user-assigned managed identities
  # (app registrations only), so for every repo that provides its permanent numeric
  # 'repository_id' we mirror each classic FIC with an immutable-format twin. Classic
  # FICs are kept: pre-cutoff repos keep issuing classic subjects until renamed,
  # transferred or opted in. Numeric org/repo IDs are permanent and never reused.
  # The wildcard caveat above applies unchanged: a '*' inside a subject does not
  # wildcard-match in a standard FIC, classic or immutable.
  # https://github.blog/changelog/2026-04-23-immutable-subject-claims-for-github-actions-oidc-tokens/
  github_oidc_immutable_subject_claims = merge([for repo_name, repo_cfg in var.deploy_github_actions_from :
    repo_cfg.repository_id == null ? {} : merge(
      repo_cfg.pull_request_events ? {
        "pull-requests-in-${local.gh_org}__${repo_name}-immutable-sub" = "repo:${local.gh_org}@${var.github_org_id}/${repo_name}@${repo_cfg.repository_id}:pull_request"
      } : {},
      { for env in repo_cfg.environments :
        "env-${env}-in-${local.gh_org}__${repo_name}-immutable-sub" => "repo:${local.gh_org}@${var.github_org_id}/${repo_name}@${repo_cfg.repository_id}:environment:${env}"
      },
      { for branch in repo_cfg.branches :
        "branch-${branch}-in-${local.gh_org}__${repo_name}-immutable-sub" => "repo:${local.gh_org}@${var.github_org_id}/${repo_name}@${repo_cfg.repository_id}:ref:refs/heads/${branch}"
      },
      { for tag in repo_cfg.tags :
        "tag-${replace(tag, "*", "wildcard")}-in-${local.gh_org}__${repo_name}-immutable-sub" => "repo:${local.gh_org}@${var.github_org_id}/${repo_name}@${repo_cfg.repository_id}:ref:refs/tags/${tag}"
      },
    )
  ]...)
}

# Wait for MS Graph to register the deploy UAMI's service principal.
# ARM returns success before Graph propagation completes, causing FIC
# creation to fail with "MS Graph resource not found".
resource "time_sleep" "deploy_uami_propagation" {
  count = length(var.deploy_github_actions_from) > 0 ? 1 : 0

  create_duration = "30s"

  depends_on = [azurerm_user_assigned_identity.deploy]
}

resource "azurerm_federated_identity_credential" "deploy_github" {
  for_each = merge(
    local.github_oidc_subject_claims,
    local.github_oidc_immutable_subject_claims,
  )

  audience                  = ["api://AzureADTokenExchange"]
  issuer                    = "https://token.actions.githubusercontent.com"
  name                      = each.key
  subject                   = each.value
  user_assigned_identity_id = azurerm_user_assigned_identity.deploy[0].id

  depends_on = [time_sleep.deploy_uami_propagation]

  lifecycle {
    # Azure FIC names: 3-120 chars, letters/digits/hyphens/underscores, must start
    # with a letter or digit. Generated keys embed caller-supplied org/repo/env/
    # branch/tag names, so fail at plan time with a readable message instead of a
    # cryptic ARM error at apply time.
    precondition {
      condition = (
        length(each.key) >= 3 && length(each.key) <= 120
        && length(regexall("^[A-Za-z0-9][A-Za-z0-9_-]*$", each.key)) == 1
      )
      error_message = "Generated FIC name '${each.key}' violates Azure naming rules (3-120 chars; letters, digits, hyphens and underscores only). Shorten or rename the offending repository/environment/branch/tag."
    }
  }
}
