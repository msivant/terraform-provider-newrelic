data "oci_identity_region_subscriptions" "subscriptions" {
  tenancy_id = var.tenancy_ocid
}

data "oci_identity_policies" "newrelic_metrics_policy" {
  compartment_id = var.tenancy_ocid
  filter {
    name   = "name"
    values = [local.newrelic_metrics_policy]
  }
}

data "oci_identity_policies" "newrelic_logs_policy" {
  compartment_id = var.tenancy_ocid
  filter {
    name   = "name"
    values = [local.newrelic_logs_policy]
  }
}

data "oci_identity_policies" "newrelic_common_policy" {
  compartment_id = var.tenancy_ocid
  filter {
    name   = "name"
    values = [local.newrelic_common_policy]
  }
}
