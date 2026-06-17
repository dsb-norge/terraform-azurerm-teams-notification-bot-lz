variable "api_app_id" {
  description = "Client ID of the Entra ID app registration for API authentication."
  type        = string
}

variable "api_app_object_id" {
  description = "Object ID of the Entra ID app registration for API authentication."
  type        = string
}

variable "bot_app_id" {
  description = "Client ID of the Entra ID app registration for Bot Framework auth."
  type        = string
}

variable "name" {
  description = "Base name for all resources."
  type        = string
}

variable "alert_target_alias" {
  description = "Alias for the Azure Monitor action group alert target. Set to empty string to skip alert configuration."
  type        = string
  default     = "ops-alerts"
}

variable "existing_bot_uami_id" {
  description = "Full resource ID of a pre-created UAMI for the bot. Empty string creates a new one."
  type        = string
  default     = ""
}
