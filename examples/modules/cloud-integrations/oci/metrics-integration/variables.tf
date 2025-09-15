variable "tenancy_ocid" {
  type        = string
  description = "OCI tenant OCID, more details can be found at https://docs.cloud.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#five.Do not modify."
}

variable "compartment_ocid" {
  type        = string
  description = "The OCID of the compartment where resources will be created. Do not modify."
}

variable "nr_prefix" {
  type        = string
  description = "The prefix for naming resources in this module."
  default     = "newrelic"
}

variable "region" {
  type        = string
  description = "The name of the OCI region where these resources will be deployed."
}

variable "newrelic_endpoint" {
  type        = string
  default     = "newrelic-staging-metric-api"
  description = "The endpoint to hit for sending the metrics. Varies by region [US|EU]"
  validation {
    condition     = contains(["newrelic-staging-metric-api", "newrelic-metric-api", "newrelic-eu-metric-api"], var.newrelic_endpoint)
    error_message = "Valid values for var: newrelic_endpoint are (newrelic-staging-metric-api, newrelic-staging-vortex-metric-api, newrelic-metric-api, newrelic-eu-metric-api)."
  }
}

variable "create_vcn" {
  type        = bool
  default     = true
  description = "Variable to create virtual network for the setup. True by default"
}

variable "function_subnet_id" {
  type        = string
  default     = ""
  description = "The OCID of the subnet to be used for the function app. If create_vcn is set to true, that will take precedence"
}

variable "payload_link" {
  type        = string
  description = "The link to the payload for the connector hubs."
}

variable "connector_hubs_data" {
  type        = list(map(any))
  description = "List of maps containing connector hub configuration data."
  default = [
    {
      "batch_size_in_kbs" = 100
      "batch_time_in_sec" = 60
      "compartments" = [
        {
          "compartment_id" = "ocid1.tenancy.oc1..aaaaaaaaslaq5synueyzouxaimk3szzf66iw6od7xyiam5myn4lqhcsfu5fq"
          "namespaces" = [
            "oci_faas",
          ]
        },
      ]
      "description" = "[DO NOT DELETE] New Relic Metrics Connector Hub to distribute metrics to New Relic"
      "name"        = "newrelic-metrics-connector-hub-us-ashburn-1-1"
      "region"      = "us-ashburn-1"
    },
  ]
}

variable "ingest_api_secret_ocid" {
  type        = string
  description = "The OCID of the vault storing the ingest key for secure access."
}

variable "user_api_secret_ocid" {
  type        = string
  description = "The OCID of the vault storing the user key for secure access."
}

variable "private_key" {
  type        = string
  sensitive   = true
  description = "The private key content for OCI API authentication (alternative to private_key_path). Use this if you want to pass the key content directly instead of a file path."
  default     = ""
}

variable "fingerprint" {
  type        = string
  description = "The fingerprint of the public key. Get this from OCI Console -> User Settings -> API Keys"
}
