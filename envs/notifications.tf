/************************************************************
Topics
************************************************************/
resource "oci_ons_notification_topic" "this" {
  for_each = local.topics

  compartment_id = oci_identity_compartment.workload.id
  name           = each.value.name
}

/************************************************************
Subscriptions
************************************************************/
### EMAIL
# トピックと同一コンパートメントにする必要あり
resource "oci_ons_subscription" "email" {
  compartment_id = oci_identity_compartment.workload.id
  topic_id       = oci_ons_notification_topic.this["email"].topic_id
  protocol       = "EMAIL"
  endpoint       = var.subscription_email
}

### Functions
# トピックと同一コンパートメントにする必要あり
resource "oci_ons_subscription" "functions" {
  for_each = var.fn_subscriptions ? local.fn_subscriptions : {}

  compartment_id = oci_identity_compartment.workload.id
  topic_id       = oci_ons_notification_topic.this[each.key].id
  protocol       = "ORACLE_FUNCTIONS"
  endpoint       = each.value.fn_ocid
  delivery_policy = jsonencode({
    backoffRetryPolicy = {
      initialDelayInFailureRetry = 60000
      maxRetryDuration           = 7200000
      policyType                 = "EXPONENTIAL"
    }
    maxReceiveRatePerSecond = 0
  })
}