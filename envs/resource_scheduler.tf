/************************************************************
Schedules
************************************************************/
### For Functions
resource "oci_resource_scheduler_schedule" "functions" {
  for_each = var.fn_schedules ? local.schedulers : {}

  compartment_id = oci_identity_compartment.workload.id
  state          = "ACTIVE"
  display_name   = each.value.name
  description    = each.value.description
  action         = each.value.action
  resources {
    id = each.value.fn_ocid
  }
  recurrence_details = "FREQ=DAILY;INTERVAL=1"
  recurrence_type    = "ICAL"
  time_starts        = each.value.time_start
}