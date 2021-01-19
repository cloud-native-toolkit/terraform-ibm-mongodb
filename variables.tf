variable "resource_group_name" {
  type        = string
  description = "Resource group where the cluster has been provisioned."
}

variable "resource_location" {
  type        = string
  description = "Geographic location of the resource (e.g. us-south, us-east)"
}

variable "tags" {
  type        = list(string)
  description = "Tags that should be applied to the service"
  default     = []
}

variable "name_prefix" {
  type        = string
  description = "The prefix name for the service. If not provided it will default to the resource group name"
  default     = ""
}

variable "plan" {
  type        = string
  description = "The type of plan the service instance should run under (standard)"
  default     = "standard"
}

variable "role" {
  type        = string
  description = "The role of the generated credential (Viewer, Administrator, Operator, Editor)"
  default     = "Editor"
}

variable "key-protect-region" {
  type        = string
  description = "The region where the Key Protect instance has been provisioned. If not provided defaults to the same region as the MongoDB instance"
  default     = ""
}

variable "key-protect-resource-group" {
  type        = string
  description = "The resource group where the Key Protect instance has been provisioned. If not provided defaults to the same resource group as the MongoDB instance"
  default     = ""
}

variable "key-protect-name" {
  type        = string
  description = "The name of the Key Protect instance"
  default     = ""
}

variable "key-protect-key" {
  type        = string
  description = "The name of the key in the Key Protect instance"
  default     = ""
}

variable "authorize-kms" {
  type        = bool
  description = "Flag indicating that the authorization for MongoDB to read keys in the KMS should be created"
  default     = false
}
