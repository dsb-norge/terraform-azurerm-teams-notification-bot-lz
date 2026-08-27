# Integration test for 02-full example with BYON identity
# Validates that the module correctly uses a pre-created UAMI from a
# separate resource group (simulating the enterprise identity team pattern).
# Mode 1 (default) network, no alerts, BYON identity.

provider "azurerm" {
  features {}
  storage_use_azuread = true
}

# Generate random UUIDs for app registration placeholders
run "setup" {
  command = apply

  module {
    source = "./tests/setup"
  }

  variables {
    name_prefix = "itbot02b"
  }
}

# Create the UAMI in a separate resource group (simulating identity team)
run "setup_identity" {
  command = apply

  module {
    source = "./tests/setup-byon-identity"
  }

  variables {
    name = run.setup.name
  }
}

# Apply example directory with existing UAMI
run "apply" {
  command = apply

  module {
    source = "./examples/02-full"
  }

  variables {
    name                 = run.setup.name
    bot_app_id           = run.setup.bot_app_id
    api_app_id           = run.setup.api_app_id
    api_app_object_id    = run.setup.api_app_object_id
    alert_target_alias   = ""
    existing_bot_uami_id = run.setup_identity.uami_id
  }

  # Core outputs
  assert {
    condition     = output.function_app_name == "func-${run.setup.name}"
    error_message = "Function app name should be 'func-<name>'."
  }

  assert {
    condition     = output.bot_service_name == "bot-${run.setup.name}"
    error_message = "Bot service name should be 'bot-<name>'."
  }

  # UAMI outputs should come from the pre-created identity
  assert {
    condition     = output.uami_client_id == run.setup_identity.uami_client_id
    error_message = "uami_client_id should match the pre-created UAMI."
  }

  assert {
    condition     = output.uami_principal_id == run.setup_identity.uami_principal_id
    error_message = "uami_principal_id should match the pre-created UAMI."
  }
}
