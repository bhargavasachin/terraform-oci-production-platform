output "vcn_id" {
  value       = module.network.vcn_id
  description = "VCN OCID."
}

output "public_subnet_id" {
  value       = module.network.public_subnet_id
  description = "Public subnet OCID."
}

output "private_subnet_id" {
  value       = module.network.private_subnet_id
  description = "Private subnet OCID."
}
