<!--
  Scaffolded by https://github.com/dsb-infra/.github-private — customize freely.
  This file is NOT overwritten by the auto-generate script. It is yours to maintain.

  Read by: Claude Code, VS Code Copilot, GitHub.com Coding Agent.
  Purpose: Project-specific instructions that complement the auto-generated .claude/CLAUDE.md.
  Only add content here that is NOT already covered by README.md.
-->

# Project-Specific Instructions

## Why azapi instead of azurerm for the Function App

The Function App (`azapi_resource.bot` in `main.compute.tf`) uses `azapi_resource` instead of `azurerm_function_app_flex_consumption` because the azurerm provider auto-injects `AzureWebJobsStorage` and `DEPLOYMENT_STORAGE_CONNECTION_STRING` with empty values on every apply. The empty `AzureWebJobsStorage` blocks the Flex Consumption scale controller from using identity-based storage settings, silently preventing queue/blob trigger scaling. Auth settings are managed via a child `azapi_update_resource`. Always use `ignore_casing = true` on azapi resources — Azure normalizes enum values and resource ID casing.

## Identity model

The module supports two identity modes for the bot UAMI:

1. **Module-managed** (default): `existing_bot_uami_id = ""` — the module creates a UAMI in the target resource group.
2. **Bring your own**: `existing_bot_uami_id = "<full-resource-id>"` — the module reads an existing UAMI via data source, skips creation. Used in enterprise environments where an identity team pre-creates UAMIs.

All internal code references the UAMI through `local.bot_uami_id`, `local.bot_uami_client_id`, and `local.bot_uami_principal_id` (defined in `main.identity.tf`). Never reference `azurerm_user_assigned_identity.bot` directly — it has `count` and may not exist.

A separate deploy UAMI (for GitHub Actions CI/CD) is always module-managed and controlled by `deploy_github_actions_from`.

## Network modes

Two network modes, mirroring the identity pattern:

1. **Module-managed** (default): `network_config.create_network = true` — creates VNet, subnets, DNS zones, VNet links.
2. **BYON**: `network_config.create_network = false` + existing subnet IDs — skips all network creation. BYON subnets are validated via `data "azapi_resource"` postconditions (delegation, sizing).

Private endpoints come in two flavors: `managed` (with DNS zone groups) and `unmanaged` (with `ignore_changes` on DNS zone groups, for Azure Policy/DINE environments). Controlled by `manage_private_dns_zone_groups`.

## Bot Framework constraints

- Bot service `microsoft_app_type` is **immutable** — cannot be changed after creation. Delete and recreate if it needs to change.
- TLS version must be `1.2` — Bot Framework Connector uses TLS 1.2. Setting `1.3` silently blocks all inbound Teams traffic (as of February 2026).
- The messaging endpoint (`/api/messages`) is excluded from EasyAuth in `bot_auth_settings` — Bot Framework sends its own JWT tokens that EasyAuth cannot validate.
- `AzureBotService` service tag does NOT cover Teams channel delivery IPs. The module adds `52.112.0.0/14` and `52.122.0.0/15` explicitly.

## App Service ipSecurityRestrictions service tags

Confirmed empirically (April 2026): App Service `ipSecurityRestrictions` accepts a narrower set of service tags than NSG rules. MS docs claim "all publicly available service tags are supported" but regional variants of `AzureCloud` (e.g. `AzureCloud.NorwayEast`) are rejected by ARM with `'AzureCloud.NorwayEast' is an invalid ServiceTag!`. Known working: `AzureCloud`, `ActionGroup`, `AzureBotService`. The `allowed_caller_rules` variable does not pre-validate tags against a known list — trust ARM's error at apply time.

## Testing

- **Unit tests** (`tests/unit-tests.tftest.hcl`): 57 tests using `mock_provider`. Cover variable validation, conditional resources, BYON network, BYON identity, naming, outputs.
- **Integration tests** (`tests/integration-test-*.tftest.hcl`): Run against real Azure. Each uses `tests/setup/` for random UUIDs and may use additional setup helpers (e.g. `tests/setup-byon-identity/` for BYON identity scenarios).
- Integration tests use the **ss13-IKT-IAC-CICD** subscription. Set it before running: `az account set --subscription ss13-IKT-IAC-CICD`.
- The `prevent_deletion_if_contains_resources = false` flag is set on test resource groups because Azure auto-creates a Smart Detection action group.
- Test names prefixed `integration-test-example-*` match the CI workflow glob pattern.

## Query pack label limit

Azure `log_analytics_query_pack_query` resources allow a maximum of 5 labels (NOT the same as resource tags). The module uses `local.query_labels` (3 labels) instead of `local.common_tags` to stay within this limit.

## app_requirements contract

The `app_requirements` variable accepts fields from the function app's `app-requirements.json` release artifact. Extra keys (e.g. `teams_app_configuration`) are silently discarded by the Terraform `object()` type. Only infrastructure-relevant fields are consumed. The `infrastructure_requirements_unique_hash` output lets consumers detect when a new app release requires `terraform apply`.
