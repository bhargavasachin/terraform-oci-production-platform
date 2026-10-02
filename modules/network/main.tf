locals {
  # cidrcontains() only exists in OpenTofu, not Terraform, so containment is
  # checked numerically instead: each CIDR is reduced to its first/last IPv4
  # address as integers, turning containment and overlap into plain range
  # comparisons. Each CIDR is validated as IPv4 in variables.tf.
  vcn_pl    = tonumber(split("/", var.vcn_cidr)[1])
  vcn_first = sum([for i, octet in split(".", cidrhost(var.vcn_cidr, 0)) : tonumber(octet) * pow(256, 3 - i)])
  vcn_last  = local.vcn_first + pow(2, 32 - local.vcn_pl) - 1

  public_pl    = tonumber(split("/", var.public_subnet_cidr)[1])
  public_first = sum([for i, octet in split(".", cidrhost(var.public_subnet_cidr, 0)) : tonumber(octet) * pow(256, 3 - i)])
  public_last  = local.public_first + pow(2, 32 - local.public_pl) - 1

  private_pl    = tonumber(split("/", var.private_subnet_cidr)[1])
  private_first = sum([for i, octet in split(".", cidrhost(var.private_subnet_cidr, 0)) : tonumber(octet) * pow(256, 3 - i)])
  private_last  = local.private_first + pow(2, 32 - local.private_pl) - 1
}

resource "oci_core_vcn" "this" {
  compartment_id = var.compartment_id
  cidr_block     = var.vcn_cidr
  display_name   = "${var.name}-vcn"
  dns_label      = "${replace(var.name, "-", "")}vcn"
  freeform_tags  = var.freeform_tags
}

resource "oci_core_internet_gateway" "this" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.name}-igw"
  enabled        = true
  freeform_tags  = var.freeform_tags
}

resource "oci_core_nat_gateway" "this" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.name}-nat"
  freeform_tags  = var.freeform_tags
}

data "oci_core_services" "all" {}

resource "oci_core_service_gateway" "this" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.name}-service-gw"

  dynamic "services" {
    for_each = {
      for service in data.oci_core_services.all.services : service.id => service
    }

    content {
      service_id = services.value.id
    }
  }

  freeform_tags = var.freeform_tags
}

resource "oci_core_route_table" "public" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.name}-public-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.this.id
  }

  freeform_tags = var.freeform_tags
}

resource "oci_core_route_table" "private" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.name}-private-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.this.id
  }

  dynamic "route_rules" {
    for_each = {
      for service in data.oci_core_services.all.services : service.cidr_block => service
    }

    content {
      destination       = route_rules.value.cidr_block
      destination_type  = "SERVICE_CIDR_BLOCK"
      network_entity_id = oci_core_service_gateway.this.id
    }
  }

  freeform_tags = var.freeform_tags
}

resource "oci_core_subnet" "public" {
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.this.id
  cidr_block                 = var.public_subnet_cidr
  display_name               = "${var.name}-public"
  route_table_id             = oci_core_route_table.public.id
  prohibit_public_ip_on_vnic = false
  dns_label                  = "public"
  freeform_tags              = var.freeform_tags

  lifecycle {
    precondition {
      condition     = local.public_pl >= local.vcn_pl && local.public_first >= local.vcn_first && local.public_last <= local.vcn_last
      error_message = "public_subnet_cidr must be contained within vcn_cidr."
    }
  }
}

resource "oci_core_subnet" "private" {
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.this.id
  cidr_block                 = var.private_subnet_cidr
  display_name               = "${var.name}-private"
  route_table_id             = oci_core_route_table.private.id
  prohibit_public_ip_on_vnic = true
  dns_label                  = "private"
  freeform_tags              = var.freeform_tags

  lifecycle {
    precondition {
      condition     = local.private_pl >= local.vcn_pl && local.private_first >= local.vcn_first && local.private_last <= local.vcn_last
      error_message = "private_subnet_cidr must be contained within vcn_cidr."
    }
    precondition {
      condition     = local.public_last < local.private_first || local.private_last < local.public_first
      error_message = "public_subnet_cidr and private_subnet_cidr must not overlap."
    }
  }
}
