output "api_app_id" {
  description = "Random UUID for API app registration (test placeholder)."
  value       = random_uuid.api_app_id.result
}

output "api_app_object_id" {
  description = "Random UUID for API app object ID (test placeholder)."
  value       = random_uuid.api_app_object_id.result
}

output "bot_app_id" {
  description = "Random UUID for bot app registration (test placeholder)."
  value       = random_uuid.bot_app_id.result
}
