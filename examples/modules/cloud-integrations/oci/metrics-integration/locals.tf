locals {
  home_region = [
    for rs in data.oci_identity_region_subscriptions.subscriptions.region_subscriptions :
    rs.region_name if rs.region_key == data.oci_identity_tenancy.current_tenancy.home_region_key
  ][0]

  freeform_tags = {
    newrelic-terraform = "true"
  }

  terraform_suffix = "terraform"

  # Names for the network infra
  vcn_name        = "newrelic-${var.nr_prefix}-${var.region}-vcn"
  nat_gateway     = "${local.vcn_name}-natgateway-${local.terraform_suffix}"
  service_gateway = "${local.vcn_name}-servicegateway-${local.terraform_suffix}"
  subnet          = "${local.vcn_name}-private-subnet-${local.terraform_suffix}"
}

