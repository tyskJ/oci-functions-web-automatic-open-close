/************************************************************
Schedules
************************************************************/
resource "oci_resource_scheduler_schedule" "functions" {
  count = var.fn_schedules ? 1 : 0

  compartment_id = oci_identity_compartment.workload.id
  state          = "ACTIVE"
  display_name   = "web-application-closing"
  description    = "Start WAF Closing Functions"
  action         = "START_RESOURCE"
  resources {
    id = var.fn_close_ocid
  }
  recurrence_details = "FREQ=DAILY;INTERVAL=1"
  recurrence_type    = "ICAL"
}