locals {
  freeform_tags = {
    newrelic-terraform = "true"
  }

  # VCN Constants
  vcn_name          = "newrelic-vcn"
  nat_gateway       = "newrelic-natgateway"
  service_gateway   = "newrelic-servicegateway"
  internet_gateway  = "newrelic-internetgateway"
  subnet            = "newrelic-private-subnet"

  # Function App Constants
  function_app_name  = "${var.newrelic_logging_prefix}-${var.region}-logs-function-app"
  function_app_shape = "GENERIC_X86"
  client_ttl         = 30

  # Function Constants
  function_name        = "${var.newrelic_logging_prefix}-${var.region}-logs-function"
  memory_in_mbs        = "128"
  image_version_latest = "latest" # todo: to modify post version decision
  image_url            = "${var.region}.ocir.io/idfmbxeaoavl/newrelic-log-container/log-forwarder:${local.image_version_latest}" #todo: change once prod ocir is ready

  # Connector Hub Constants
  batch_size_in_kbs = 100 # todo: change batch size
  batch_time_in_sec = 60
}