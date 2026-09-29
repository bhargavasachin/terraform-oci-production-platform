variable "compartment_id" {
  description = "Compartment OCID for the dev environment."
  type        = string
}

variable "region" {
  description = "OCI region for the dev environment."
  type        = string
}

variable "name" {
  description = "Environment name prefix."
  type        = string
  default     = "dev-platform"
}

variable "vcn_cidr" {
  description = "VCN CIDR."
  type        = string
  default     = "10.20.0.0/16"
}

variable "public_subnet_cidr" {
  description = "Public subnet CIDR."
  type        = string
  default     = "10.20.10.0/24"
}

variable "private_subnet_cidr" {
  description = "Private subnet CIDR."
  type        = string
  default     = "10.20.20.0/24"
}

variable "freeform_tags" {
  description = "Environment tags."
  type        = map(string)
  default = {
    managed_by  = "terraform"
    environment = "dev"
  }
}
