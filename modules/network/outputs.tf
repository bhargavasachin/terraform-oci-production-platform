output "vcn_id" {
  description = "OCID of the VCN."
  value       = oci_core_vcn.this.id
}

output "public_subnet_id" {
  description = "OCID of the public subnet."
  value       = oci_core_subnet.public.id
}

output "private_subnet_id" {
  description = "OCID of the private subnet."
  value       = oci_core_subnet.private.id
}

output "nat_gateway_id" {
  description = "OCID of the NAT gateway."
  value       = oci_core_nat_gateway.this.id
}

output "service_gateway_id" {
  description = "OCID of the service gateway."
  value       = oci_core_service_gateway.this.id
}
