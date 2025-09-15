locals {
  home_region = [
    for region in data.oci_identity_region_subscriptions.subscriptions.region_subscriptions : region.region_name
    if region.is_home_region
  ][0]
  is_home_region = var.region == local.home_region

  freeform_tags = {
    newrelic-terraform = "true"
  }
  newrelic_metrics_access_policy   = contains(split(",", var.policy_stack), "METRICS")
  newrelic_logs_access_policy      = contains(split(",", var.policy_stack), "LOGS")
  newRelic_core_integration_policy = contains(split(",", var.policy_stack), "COMMON")
  newrelic_logs_policy             = "${var.nr_prefix}-logs-policy"
  newrelic_metrics_policy          = "${var.nr_prefix}-metrics-policy"
  newrelic_common_policy           = "${var.nr_prefix}-common-policy"
  dynamic_group_name               = "${var.nr_prefix}-dynamic-group"
  linked_account_name              = "${var.nr_prefix}-oci"
}
