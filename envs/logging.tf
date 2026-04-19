/************************************************************
Log Group
************************************************************/
### Regional WAF
resource "oci_logging_log_group" "waf" {
  compartment_id = oci_identity_compartment.workload.id
  display_name   = "regional-waf-log-group"
  description    = "For Regional WAF Log Group"
}

/************************************************************
Logs
************************************************************/
### Regional WAF
resource "oci_logging_log" "waf_flb" {
  display_name = "waf-all-log"
  is_enabled   = true
  log_type     = "SERVICE"
  configuration {
    compartment_id = oci_identity_compartment.workload.id
    source {
      source_type = "OCISERVICE"
      service     = "waf"
      category    = "all"
      resource    = oci_waf_web_app_firewall.waf_flb.id
      parameters  = {}
    }
  }
  log_group_id       = oci_logging_log_group.waf.id
  retention_duration = 30
}