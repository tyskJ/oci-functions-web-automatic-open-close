/************************************************************
Region List
************************************************************/
locals {
  region_map = {
    for r in data.oci_identity_regions.regions.regions :
    r.key => r.name
  }
}

/************************************************************
Repository
************************************************************/
locals {
  repos = {
    waf_open = {
      prefix_name = "waf_open_mngt"
      fn_name     = "waf-open"
    }
    waf_close = {
      prefix_name = "waf_close_mngt"
      fn_name     = "waf-close"
    }
    com_start = {
      prefix_name = "com_start_mngt"
      fn_name     = "compute-start"
    }
    com_stop = {
      prefix_name = "com_stop_mngt"
      fn_name     = "compute-stop"
    }
  }
}

/************************************************************
Functions
************************************************************/
locals {
  apps = {
    waf_open = {
      name    = "waf-open"
      fn_ocid = var.fn_open_ocid
    }
    waf_close = {
      name    = "waf-close"
      fn_ocid = var.fn_close_ocid
    }
    com_start = {
      name    = "compute-start"
      fn_ocid = var.fn_start_ocid
    }
    com_stop = {
      name    = "compute-stop"
      fn_ocid = var.fn_stop_ocid
    }
  }
}