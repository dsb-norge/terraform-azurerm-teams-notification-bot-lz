variable "name" {
  description = "Base name used for test resources."
  type        = string
}

variable "location" {
  description = "Azure region for test resources."
  type        = string
  default     = "norwayeast"
}
