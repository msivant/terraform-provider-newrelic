---
layout: "newrelic"
page_title: "New Relic: newrelic_cloud_oci_link_account"
sidebar_current: "docs-newrelic-cloud-resource-oci-link-account"
description: |-
  Link an Oracle Cloud Infrastructure (OCI) account to New Relic.
---
# Resource: newrelic_cloud_oci_link_account

Use this resource to link an Oracle Cloud Infrastructure (OCI) account to New Relic.

## Prerequisites

You need an Oracle Cloud Infrastructure tenancy with IAM permissions to create and manage the identity artifacts (client/application, secrets, compartments, and service user) referenced below. OCI provides enterprise-grade cloud services across multiple global regions.

> **NOTE:** This resource assumes you've already configured both the OCI and New Relic providers with valid credentials:
> - [OCI provider setup](https://registry.terraform.io/providers/oracle/oci/latest/docs)
> - [New Relic provider getting started](https://registry.terraform.io/providers/newrelic/newrelic/latest/docs/guides/getting_started)

If you encounter issues or bugs, please [open an issue in the GitHub repository](https://github.com/newrelic/terraform-provider-newrelic/issues/new/choose).

### Workload Identity Federation (WIF) Attributes

The following arguments rely on an OCI Identity Domain OAuth2 client set up for workload identity federation (identity propagation): `oci_client_id`, `oci_client_secret`, `oci_domain_url`, and `oci_svc_user_name`.

To create and retrieve these values, follow Oracle's guidance for configuring identity propagation / JWT token exchange:

[Oracle documentation: Create an identity propagation trust (JWT token exchange)](https://docs.oracle.com/en-us/iaas/Content/Identity/api-getstarted/json_web_token_exchange.htm#jwt_token_exchange__create-identity-propagation-trust)

WIF configuration steps:
1. Create (or identify) an Identity Domain and register an OAuth2 confidential application (client) to represent New Relic ingestion.
2. Generate / record the client ID (`oci_client_id`) and client secret (`oci_client_secret`). Store the secret securely (e.g., in OCI Vault; reference its OCID via `ingest_vault_ocid` / `user_vault_ocid` if desired).
3. Use the Identity Domain base URL as `oci_domain_url` (format: `https://idcs-<hash>.identity.oraclecloud.com`).
4. Provide / map a service user (or principal) used for workload identity federation as `oci_svc_user_name`.
5. Ensure the client has the required scopes and the tenancy policies allow the token exchange.

> TIP: Rotating the OAuth2 client secret only requires updating `oci_client_secret`; it does not force resource replacement.

## Example Usage

Minimal example (required arguments for creation):

```hcl
resource "newrelic_cloud_oci_link_account" "example" {
  # Optional if set via the provider block or NEW_RELIC_ACCOUNT_ID environment variable
  account_id        = 1234567

  # Changing this forces replacement (ForceNew)
  tenant_id         = "ocid1.tenancy.oc1..aaaaaaaaexample"

  name              = "my-oci-link"
  compartment_ocid  = "ocid1.compartment.oc1..bbbbbbbbexample"
  oci_client_id     = "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"                     # OCI Identity Domain OAuth2 client (WIF)
  oci_client_secret = var.oci_client_secret                                        # Sensitive
  oci_domain_url    = "https://idcs-1234567890abcdef.identity.oraclecloud.com"    # Identity domain base URL
  oci_home_region   = "us-ashburn-1"
  oci_svc_user_name = "svc-newrelic-collector"
}
```

Example including optional secret references and update-only fields:

```hcl
resource "newrelic_cloud_oci_link_account" "full" {
  name              = "my-oci-link-full"
  tenant_id         = "ocid1.tenancy.oc1..aaaaaaaaexample"
  compartment_ocid  = "ocid1.compartment.oc1..bbbbbbbbexample"
  oci_client_id     = "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
  oci_client_secret = var.oci_client_secret
  oci_domain_url    = "https://idcs-1234567890abcdef.identity.oraclecloud.com"
  oci_home_region   = "us-ashburn-1"
  oci_svc_user_name = "svc-newrelic-collector"

  # Optional vault secret OCIDs (these may point to secrets that store rotated values)
  ingest_vault_ocid = "ocid1.vaultsecret.oc1..ccccccccexample"
  user_vault_ocid   = "ocid1.vaultsecret.oc1..ddddddddexample"

  # Update-only fields (ignored during initial create, applied on update)
  oci_region        = "us-phoenix-1"
  metric_stack_ocid = "ocid1.stack.oc1..eeeeeeeeexample"
}
```

## Argument Reference

The following arguments are supported (current provider schema):

- `account_id` - (Optional, ForceNew) New Relic account to operate on. Overrides the provider-level `account_id`. If omitted, uses the provider default or `NEW_RELIC_ACCOUNT_ID`.
- `tenant_id` - (Required, ForceNew) OCI tenancy OCID (root tenancy). Changing forces a new linked account.
- `name` - (Required) Display name for the linked account.
- `compartment_ocid` - (Required) OCI compartment OCID representing (or containing) the monitored resources/newrelic compartment.
- `oci_client_id` - (Required) OCI Identity Domain (IDCS) OAuth2 client ID used for workload identity federation.
- `oci_client_secret` - (Required, Sensitive) OAuth2 client secret. Not displayed in plans or state outputs.
- `oci_domain_url` - (Required) Base URL of the OCI Identity Domain (e.g. `https://idcs-<hash>.identity.oraclecloud.com`).
- `oci_home_region` - (Required) Home region of the tenancy (e.g. `us-ashburn-1`).
- `oci_svc_user_name` - (Required) Service user name associated with the WIF configuration.
- `ingest_vault_ocid` - (Optional) Vault secret OCID containing an ingest secret.
- `user_vault_ocid` - (Optional) Vault secret OCID containing a user or auxiliary secret.
- `oci_region` - (Optional, Update-only) OCI region for the linkage (ignored on create, applied on update).
- `metric_stack_ocid` - (Optional, Update-only) Metric stack OCID (ignored on create, applied on update).

### ForceNew & Update-only Behavior

- Changing `account_id` or `tenant_id` forces resource replacement.
- Update-only fields (`oci_region`, `metric_stack_ocid`) are ignored at initial creation and only sent on update operations.

### Sensitive Data Handling

- `oci_client_secret` is stored as a sensitive value in state and excluded from plan/apply output. Rotate as needed and re-apply to update; this performs an in-place update (no replacement) unless another ForceNew attribute changed.

## Attributes Reference

In addition to all arguments above, the following attributes are exported:

- `id` - The ID of the OCI linked account.

> NOTE: Only a subset of arguments may currently be returned by the read operation (`account_id`, `tenant_id`, `name`). Other write-only, sensitive, or create-time fields may not round-trip during `terraform refresh` or `terraform plan` until backend API read support is expanded. This is expected.

## Import

Linked OCI accounts can be imported using the `id`, e.g.

```bash
$ terraform import newrelic_cloud_oci_link_account.foo <id>
```
