# Test setup helper — generates random UUIDs for Entra ID app registration
# placeholders. Used by integration tests to avoid MsaAppId collisions when
# running in parallel.

resource "random_uuid" "bot_app_id" {}
resource "random_uuid" "api_app_id" {}
resource "random_uuid" "api_app_object_id" {}

# Random suffix making every globally-scoped name in a test run unique.
#
# The module derives three names from var.name that live in GLOBAL namespaces:
# the storage account ("st<name>"), the function app ("func-<name>", which owns
# an azurewebsites.net hostname) and the bot service ("bot-<name>"). Fixed test
# names therefore collide whenever two CI runs overlap — which happens by
# construction, since merging to main opens a release PR whose CI races the
# next pull request's.
#
# Resource groups already avoid this via the naming module's name_unique, and
# everything else the module creates is scoped to the resource group, so a
# single suffix on var.name is enough to make a whole run self-contained.
resource "random_string" "suffix" {
  length  = 6
  lower   = true
  upper   = false
  numeric = true
  special = false # storage account names allow only lowercase alphanumerics
}
