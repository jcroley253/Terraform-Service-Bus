variable "iam_ssh_server_host_keys" {
  description = "ssh host key"
  type        = string
}

variable "iam_ssh_server_name" {
  description = "ssh server name"
  type        = string
}

variable "default_computer_account_ou" {
  description = "ou"
  type        = string
}

variable "tenant_id" {
  description = "tenant id"
  type        = string
  default     = "tenant ID goes HERE"
}

variable "subscription_id" {
  description = "subscription id"
  type        = string
  default     = "subscriptionID goes HERE"
}

variable "environment" {
  description = "environment (proto,np,prod,etc)"
  type        = string
  default     = "np"
}

variable "location" {
  description = "region location"
  type        = string
  default     = "westus2"
}

variable "virtual_network_resource_group" {
  description = "resource group that the virtual network belongs to"
  type        = string
  default     = "Resource Group Name HERE"
}

variable "virtual_network_name" {
  description = "name of the virtual network"
  type        = string
  default     = "VNET Name HERE"
}

variable "virtual_subnet_name" {
  description = "name of the virtual subnet"
  type        = string
  default     = "VSUBNET Name HERE"
}

variable "virtual_subnet_address" {
  description = "CIDR block for subnet"
  type        = string
  default     = "192.168.1.1/26"
}

variable "creator" {
  description = "creator name"
  type        = string
  default     = "John Croley"
}

variable "email" {
  description = "support group email address"
  type        = string
  default     = "john123@domain.com"
}

variable "project" {
  description = "associated project"
  type        = string
  default     = "Project Name HERE"
}

