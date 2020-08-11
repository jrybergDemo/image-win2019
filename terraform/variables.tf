variable "subscription_id" {
  description = "The Azure subscription ID"
}

variable "client_id" {
  description = "The Azure client ID of the service principal"
}

variable "client_secret" {
  description = "The Azure secret for the service principal"
}

variable "tenant_id" {
  description = "The Azure tenant ID for the service principal"
}

variable "location" {
  description = "The location to deploy the resources to"
}

variable "admin_username" {
  description = "The V3 environment admin username"
}

variable "admin_password" {
  description = "The V3 environment admin password"
}

variable "rg_prefix" {
  description = "A prefix designation for the Resource Group that contains the deployment"
}

variable "vm_name" {
  description = "The name of the VM to deploy"
}

variable "image_name" {
  description = "The name of the image deployment (e.g. 'win2019')"
}

variable "image_version" {
  description = "The name of the image, which is a combination of image_name and github PR number (e.g. 'win2019.pull-123-merge')"
}

variable "image_rg_name" {
  description = "The Resource Group that will store the images"
}

variable "dns_label_prefix" {
  description = "The Resource Group that will store the images"
}

variable "azure_tags" {
  type = map
}
