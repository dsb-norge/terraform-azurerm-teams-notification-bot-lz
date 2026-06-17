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
}

# Apply example directory as a module
run "apply" {
  command = apply

  module {
    source = "./examples/01-basic"
  }

  variables {
    name              = "itbot01"
    bot_app_id        = run.setup.bot_app_id
    api_app_id        = run.setup.api_app_id
    api_app_object_id = run.setup.api_app_object_id
  }

  assert {
    condition     = startswith(output.resource_group_name, "rg-itbot01")
    error_message = "Resource group name should start with 'rg-itbot01'."
  }

  assert {
    condition     = output.function_app_name == "func-itbot01"
    error_message = "Function app name should be 'func-itbot01'."
  }

  assert {
    condition     = output.bot_service_name == "bot-itbot01"
    error_message = "Bot service name should be 'bot-itbot01'."
  }

  assert {
    condition     = output.storage_account_name == "stitbot01"
    error_message = "Storage account name should be 'stitbot01'."
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
