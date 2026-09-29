variable "compartment_id" {
  description = "OCID of the compartment where the network will be created."
  type        = string

  validation {
    condition     = can(regex("^ocid1\\.compartment\\.", var.compartment_id))
    error_message = "compartment_id must be an OCI compartment OCID."
  }
}

variable "region" {
  description = "OCI region used by the provider."
  type        = string
}
