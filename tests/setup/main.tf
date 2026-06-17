# Test setup helper — generates random UUIDs for Entra ID app registration
# placeholders. Used by integration tests to avoid MsaAppId collisions when
# running in parallel.

resource "random_uuid" "bot_app_id" {}
resource "random_uuid" "api_app_id" {}
resource "random_uuid" "api_app_object_id" {}
