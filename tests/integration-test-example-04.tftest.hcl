# Integration test for 04-byon-with-dns example
# Apply the example directory as a module and verify outputs.
# Mode 2b: BYON with caller-provided DNS zones.
# Validates that module uses externally-provided subnets and DNS zones,
# creating PEs with DNS zone group associations.

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
}

# Apply example directory as a module
run "apply" {
  command = apply

  module {
    source = "./examples/04-byon-with-dns"
  }

  variables {
    name              = "itbot04"
    bot_app_id        = run.setup.bot_app_id
    api_app_id        = run.setup.api_app_id
    api_app_object_id = run.setup.api_app_object_id
  }

  assert {
    condition     = startswith(output.resource_group_name, "rg-itbot04")
    error_message = "Resource group name should start with 'rg-itbot04'."
  }

  assert {
    condition     = output.function_app_name == "func-itbot04"
    error_message = "Function app name should be 'func-itbot04'."
  }

  assert {
    condition     = output.bot_service_name == "bot-itbot04"
    error_message = "Bot service name should be 'bot-itbot04'."
  }

  assert {
    condition     = output.storage_account_name == "stitbot04"
    error_message = "Storage account name should be 'stitbot04'."
  }

  # BYON: module should NOT create a VNet
  assert {
    condition     = output.vnet_id == null
    error_message = "BYON mode should not create a module VNet (vnet_id should be null)."
  }

  # BYON: subnet ID should reference the externally created 'vended' VNet
  assert {
    condition     = can(regex("vnet-.*-vended", output.subnet_function_app_id))
    error_message = "subnet_function_app_id should reference the externally created 'vended' VNet."
  }

  # PEs should be created with DNS zone groups (3 for blob, queue, table)
  assert {
    condition     = length(output.private_endpoint_ids) == 3
    error_message = "Should create 3 private endpoints."
  }

  assert {
    condition     = output.function_app_hostname != ""
    error_message = "Function app hostname must not be empty."
  }
}
