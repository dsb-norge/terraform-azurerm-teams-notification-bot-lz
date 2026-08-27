# Integration test for 01-basic example
# Apply the example directory as a module and verify outputs.
# Mode 1 (default): module creates VNet, subnets, DNS zones, PEs.

provider "azurerm" {
  features {}
  storage_use_azuread = true
}

# Generate random UUIDs for app registration placeholders to avoid
# MsaAppId collisions when integration tests run in parallel.
run "setup" {
  command = apply

  module {
    source = "./tests/setup"
  }

  variables {
    name_prefix = "itbot01"
  }
}

# Apply example directory as a module
run "apply" {
  command = apply

  module {
    source = "./examples/01-basic"
  }

  variables {
    name              = run.setup.name
    bot_app_id        = run.setup.bot_app_id
    api_app_id        = run.setup.api_app_id
    api_app_object_id = run.setup.api_app_object_id
  }

  assert {
    condition     = startswith(output.resource_group_name, "rg-${run.setup.name}")
    error_message = "Resource group name should start with 'rg-<name>'."
  }

  assert {
    condition     = output.function_app_name == "func-${run.setup.name}"
    error_message = "Function app name should be 'func-<name>'."
  }

  assert {
    condition     = output.bot_service_name == "bot-${run.setup.name}"
    error_message = "Bot service name should be 'bot-<name>'."
  }

  assert {
    condition     = output.storage_account_name == "st${run.setup.name}"
    error_message = "Storage account name should be 'st<name>'."
  }

  assert {
    condition     = output.function_app_hostname != ""
    error_message = "Function app hostname must not be empty."
  }

  assert {
    condition     = output.log_analytics_workspace_id != ""
    error_message = "Log Analytics workspace ID must not be empty."
  }

  # Mode 1 network outputs: module creates its own VNet and subnets
  assert {
    condition     = output.vnet_id != null
    error_message = "Mode 1 should create a VNet (vnet_id should be non-null)."
  }

  assert {
    condition     = output.subnet_function_app_id != ""
    error_message = "Mode 1 should output a non-empty subnet_function_app_id."
  }

  assert {
    condition     = output.subnet_private_endpoints_id != ""
    error_message = "Mode 1 should output a non-empty subnet_private_endpoints_id."
  }

  assert {
    condition     = length(output.private_endpoint_ids) == 3
    error_message = "Mode 1 should create 3 private endpoints."
  }
}

# --- Idempotency ---
#
# Everything below re-runs the SAME module source as run "apply" above. Run
# blocks that share a module source share one state file, so these are genuine
# repeat operations against the resources that run "apply" created — not fresh
# deployments. See docs/Development.md ("Idempotency testing") for the full
# rationale, including why this asserts on outputs rather than on the plan.

# A second apply must succeed. This is the part that catches a resource which
# creates cleanly but fails on the update path — an ARM property that is
# accepted at PUT-on-create but rejected when the resource already exists.
run "second_apply" {
  command = apply

  module {
    source = "./examples/01-basic"
  }

  variables {
    name              = run.setup.name
    bot_app_id        = run.setup.bot_app_id
    api_app_id        = run.setup.api_app_id
    api_app_object_id = run.setup.api_app_object_id
  }

  # Remote-derived values only. Config-derived outputs (names, and anything
  # computed from var inputs) are trivially equal on a re-apply and would prove
  # nothing; these come back from Azure, so an inequality means the resource
  # was actually rebuilt.
  assert {
    condition     = output.function_app_hostname == run.apply.function_app_hostname
    error_message = "Function app was replaced by a second apply — the site should be stable across applies."
  }

  assert {
    condition     = output.log_analytics_workspace_id == run.apply.log_analytics_workspace_id
    error_message = "Log Analytics workspace was replaced by a second apply."
  }

  assert {
    condition     = output.vnet_id == run.apply.vnet_id
    error_message = "VNet was replaced by a second apply."
  }

  assert {
    condition     = output.private_endpoint_ids == run.apply.private_endpoint_ids
    error_message = "Private endpoints were replaced by a second apply."
  }
}

# A plan taken after the applies must show these resources settling. Terraform
# has no "assert the plan is empty" primitive (see docs/Development.md), so the
# check is indirect: if the plan intends to change a resource, the outputs it
# feeds go unknown, and the comparison below fails with "Unknown condition
# value" instead of the error_message. A failure here means the module does not
# converge — Azure is returning something different from what we submitted, and
# every consumer would see a permanent diff.
run "plan_after_apply_converges" {
  command = plan

  module {
    source = "./examples/01-basic"
  }

  variables {
    name              = run.setup.name
    bot_app_id        = run.setup.bot_app_id
    api_app_id        = run.setup.api_app_id
    api_app_object_id = run.setup.api_app_object_id
  }

  assert {
    condition     = output.function_app_hostname == run.apply.function_app_hostname
    error_message = "Function app does not converge: a follow-up plan still intends to change it."
  }

  assert {
    condition     = output.log_analytics_workspace_id == run.apply.log_analytics_workspace_id
    error_message = "Log Analytics workspace does not converge across applies."
  }

  assert {
    condition     = output.vnet_id == run.apply.vnet_id
    error_message = "VNet does not converge across applies."
  }

  assert {
    condition     = output.private_endpoint_ids == run.apply.private_endpoint_ids
    error_message = "Private endpoints do not converge across applies."
  }
}
