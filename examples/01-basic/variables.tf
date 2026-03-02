variable "name" {
  description = "Base name for all resources."
  type        = string
}

variable "bot_app_id" {
  description = "Client ID of the Entra ID app registration for Bot Framework auth."
  type        = string
}

variable "api_app_id" {
  description = "Client ID of the Entra ID app registration for API authentication."
  type        = string
}

variable "api_app_object_id" {
  description = "Object ID of the Entra ID app registration for API authentication."
  type        = string
}
