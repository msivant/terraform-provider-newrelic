locals {
  home_region = [
    for region in data.oci_identity_region_subscriptions.subscriptions.region_subscriptions : region.region_name
    if region.is_home_region
  ][0]
  home_region_key = [
    for region in data.oci_identity_region_subscriptions.subscriptions.region_subscriptions : region.region_key
    if region.is_home_region
  ][0]
  is_home_region = var.region == local.home_region || lower(var.region) == lower(local.home_region_key)

  freeform_tags = {
    newrelic-terraform = "true"
  }

  terraform_suffix               = "terraform"
  newrelic_metrics_access_policy = contains(split(",", var.policy_stack), "METRICS")
  newrelic_logs_access_policy    = contains(split(",", var.policy_stack), "LOGS")
  newrelic_logs_policy           = "${var.nr_prefix}-logs-policy-${local.terraform_suffix}"
  newrelic_metrics_policy        = "${var.nr_prefix}-metrics-policy-${local.terraform_suffix}"
  newrelic_common_policy         = "${var.nr_prefix}-common-policy-${local.terraform_suffix}"
  dynamic_group_name             = "${var.nr_prefix}-dynamic-group-${local.terraform_suffix}"
  linked_account_name            = "${var.nr_prefix}-oci-${local.terraform_suffix}"
}
