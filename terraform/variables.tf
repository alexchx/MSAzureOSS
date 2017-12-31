variable "location" {
  description = "The location where resources are created"
  default     = ""
}

variable "resource_group_name" {
  description = "The name of the resource group in which the resources are created"
  default     = ""
}

variable "ssh_pub" {
  description = "SSH key data"
  default     = ""
}

variable "application_port" {
  description = "The port that you want to expose to the external load balancer"
  default     = 80
}

variable "admin_password" {
  description = "Default password for admin"
  default     = "Passw@rd"
}
