# Integration test for 03-enterprise-byon example
# Apply the example directory as a module and verify outputs.
# Mode 2a: BYON with unmanaged DNS (enterprise pattern).
# Validates that module uses externally-provided subnets and creates PEs
# without DNS zone groups.

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
    name_prefix = "itbot03"
  }
}

# Apply example directory as a module
run "apply" {
  command = apply

  module {
    source = "./examples/03-enterprise-byon"
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

  # BYON: module should NOT create a VNet
  assert {
    condition     = output.vnet_id == null
    error_message = "BYON mode should not create a module VNet (vnet_id should be null)."
  }

  # BYON: subnet IDs should be the externally created ones (contain 'vended' VNet name)
  assert {
    condition     = can(regex("vnet-.*-vended", output.subnet_function_app_id))
    error_message = "subnet_function_app_id should reference the externally created 'vended' VNet."
  }

  assert {
    condition     = can(regex("vnet-.*-vended", output.subnet_private_endpoints_id))
    error_message = "subnet_private_endpoints_id should reference the externally created 'vended' VNet."
  }

  # PEs should still be created (3 for blob, queue, table)
  assert {
    condition     = length(output.private_endpoint_ids) == 3
    error_message = "Should create 3 private endpoints."
  }

  assert {
    condition     = output.function_app_hostname != ""
    error_message = "Function app hostname must not be empty."
  }
}
