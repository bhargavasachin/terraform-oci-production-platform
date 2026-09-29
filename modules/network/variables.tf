variable "compartment_id" {
  description = "Compartment that owns the VCN and networking resources."
  type        = string
}

variable "name" {
  description = "Base name used for network resources."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]{1,24}$", var.name))
    error_message = "name must be 1-24 lowercase alphanumeric characters or hyphens, so derived DNS labels stay within OCI limits."
  }
}

variable "vcn_cidr" {
  description = "Primary IPv4 CIDR for the VCN."
  type        = string

  validation {
    condition     = can(cidrhost(var.vcn_cidr, 0))
    error_message = "vcn_cidr must be a valid IPv4 CIDR."
  }
}

variable "public_subnet_cidr" {
  description = "CIDR for the public subnet."
  type        = string

  validation {
    condition     = can(cidrhost(var.public_subnet_cidr, 0))
    error_message = "public_subnet_cidr must be a valid IPv4 CIDR."
  }
}

variable "private_subnet_cidr" {
  description = "CIDR for the private subnet."
  type        = string

  validation {
    condition     = can(cidrhost(var.private_subnet_cidr, 0))
    error_message = "private_subnet_cidr must be a valid IPv4 CIDR."
  }
}

variable "freeform_tags" {
  description = "Freeform tags applied to created resources."
  type        = map(string)
  default     = {}
}
