module "network" {
  source = "../../modules/network"

  compartment_id       = var.compartment_id
  name                 = var.name
  vcn_cidr             = var.vcn_cidr
  public_subnet_cidr   = var.public_subnet_cidr
  private_subnet_cidr  = var.private_subnet_cidr
  freeform_tags        = var.freeform_tags
}
