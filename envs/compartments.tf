/************************************************************
Compartment - workload
************************************************************/
resource "oci_identity_compartment" "workload" {
  compartment_id = var.tenancy_ocid
  name           = "oci-functions-web-automatic-open-close"
  description    = "For OCI Functions Web Automatic Open and Close"
  enable_delete  = true
}