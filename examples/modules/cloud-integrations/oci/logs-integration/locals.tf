locals {
  freeform_tags = {
    newrelic-terraform = "true"
  }

  # VCN Constants
  vcn_name          = "newrelic-${var.newrelic_logging_prefix}-${var.region}-vcn"
  nat_gateway       = "newrelic-${var.newrelic_logging_prefix}-${var.region}-natgateway"
  service_gateway   = "newrelic-${var.newrelic_logging_prefix}-${var.region}-servicegateway"
  internet_gateway  = "newrelic-${var.newrelic_logging_prefix}-${var.region}-internetgateway"
  vcn_dns_label     = "nrlogging"
  vcn_cidr_block    = "10.0.0.0/16"

  # Subnet Constants
  subnet               = "newrelic-${var.newrelic_logging_prefix}-${var.region}-private-subnet"
  subnet_cidr_block    = "10.0.0.0/16"
  subnet_type          = "private"

  # Route Table Constants
  internet_destination = "0.0.0.0/0"

  # Function App Constants
  function_app_name  = "newrelic-${var.newrelic_logging_prefix}-${var.region}-logs-function-app"
  function_app_shape = "GENERIC_X86"
  client_ttl         = 30

  # Function Constants
  function_name        = "newrelic-${var.newrelic_logging_prefix}-${var.region}-logs-function"
  memory_in_mbs        = "128"

  # Connector Hub Constants
  batch_size_in_kbs = 6000
  batch_time_in_sec = 60
}