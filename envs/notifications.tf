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