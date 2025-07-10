package newrelic

import (
	"context"
	"fmt"
	"strconv"
	"strings"

	"github.com/hashicorp/terraform-plugin-sdk/v2/helper/retry"

	"github.com/hashicorp/terraform-plugin-sdk/v2/diag"
	"github.com/hashicorp/terraform-plugin-sdk/v2/helper/schema"
	"github.com/newrelic/newrelic-client-go/v2/pkg/cloud"
)

func resourceNewRelicCloudOciAccountLinkAccount() *schema.Resource {
	return &schema.Resource{
		CreateContext: resourceNewRelicCloudOciAccountLinkCreate,
		ReadContext:   resourceNewRelicCloudOciAccountLinkRead,
		UpdateContext: resourceNewRelicCloudOciAccountLinkUpdate,
		DeleteContext: resourceNewRelicCloudOciAccountLinkDelete,
		Importer: &schema.ResourceImporter{
			StateContext: schema.ImportStatePassthroughContext,
		},
		Schema: map[string]*schema.Schema{
			"account_id": {
				Type:        schema.TypeInt,
				Optional:    true,
				Computed:    true,
				Description: "The New Relic account ID where you want to link the OCI account.",
				ForceNew:    true,
			},
			"tenant_id": {
				Type:        schema.TypeString,
				Description: "The OCI tenant identifier.",
				Required:    true,
				ForceNew:    true,
			},
			"name": {
				Type:        schema.TypeString,
				Description: "The name of the linked account.",
				Required:    true,
			},
		},
	}
}

func resourceNewRelicCloudOciAccountLinkCreate(ctx context.Context, d *schema.ResourceData, meta interface{}) diag.Diagnostics {
	providerConfig := meta.(*ProviderConfig)
	client := providerConfig.NewClient

	accountID := selectAccountID(providerConfig, d)

	linkAccountInput := expandOciCloudLinkAccountInput(d)

	var diags diag.Diagnostics

	retryErr := retry.RetryContext(ctx, d.Timeout(schema.TimeoutCreate), func() *retry.RetryError {
		cloudLinkAccountPayload, err := client.Cloud.CloudLinkAccountWithContext(ctx, accountID, linkAccountInput)
		if err != nil {
			return retry.NonRetryableError(err)
		}

		if len(cloudLinkAccountPayload.Errors) > 0 {
			for _, err := range cloudLinkAccountPayload.Errors {
				if strings.Contains(err.Message, "OCI Tenant name already exists. Please enter a new OCI tenant name") {
					return retry.RetryableError(fmt.Errorf("%s : %s", err.Type, err.Message))
				}
				diags = append(diags, diag.Diagnostic{
					Severity: diag.Error,
					Summary:  err.Type + " " + err.Message,
				})
			}
		}

		if len(cloudLinkAccountPayload.LinkedAccounts) > 0 {
			d.SetId(strconv.Itoa(cloudLinkAccountPayload.LinkedAccounts[0].ID))
		}

		return nil
	})

	if retryErr != nil {
		return diag.FromErr(retryErr)
	}

	if len(diags) > 0 {
		return diags
	}

	return nil
}

func expandOciCloudLinkAccountInput(d *schema.ResourceData) cloud.CloudLinkCloudAccountsInput {
	ociAccount := cloud.CloudOciLinkAccountInput{}

	if tenantID, ok := d.GetOk("tenant_id"); ok {
		ociAccount.TenantId = tenantID.(string)
	}

	if name, ok := d.GetOk("name"); ok {
		ociAccount.Name = name.(string)
	}

	input := cloud.CloudLinkCloudAccountsInput{
		Oci: []cloud.CloudOciLinkAccountInput{ociAccount},
	}
	return input
}

func resourceNewRelicCloudOciAccountLinkRead(ctx context.Context, d *schema.ResourceData, meta interface{}) diag.Diagnostics {
	providerConfig := meta.(*ProviderConfig)
	client := providerConfig.NewClient

	accountID := selectAccountID(providerConfig, d)

	linkedAccountID, convErr := strconv.Atoi(d.Id())

	if convErr != nil {
		return diag.FromErr(convErr)
	}

	linkedAccount, err := client.Cloud.GetLinkedAccountWithContext(ctx, accountID, linkedAccountID)

	if err != nil {
		if strings.Contains(err.Error(), "not found") {
			d.SetId("")
			return nil
		}
		return diag.FromErr(err)
	}

	readOciLinkedAccount(d, linkedAccount)

	return nil
}

func readOciLinkedAccount(d *schema.ResourceData, result *cloud.CloudLinkedAccount) {
	_ = d.Set("account_id", result.NrAccountId)
	_ = d.Set("tenant_id", result.ExternalId)
	_ = d.Set("name", result.Name)
}

func resourceNewRelicCloudOciAccountLinkUpdate(ctx context.Context, d *schema.ResourceData, meta interface{}) diag.Diagnostics {
	return nil
}

func resourceNewRelicCloudOciAccountLinkDelete(ctx context.Context, d *schema.ResourceData, meta interface{}) diag.Diagnostics {
	d.SetId("")
	return nil
}
