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

/************************************************************
Notifications
************************************************************/
locals {
  topics = {
    email = {
      name = "email-topic"
    }
    waf_open = {
      name = "fn-waf-open-topic"
    }
    com_stop = {
      name = "fn-compute-stop-topic"
    }
  }
  fn_subscriptions = {
    waf_open = {
      fn_ocid = var.fn_open_ocid
    }
    com_stop = {
      fn_ocid = var.fn_stop_ocid
    }
  }
}

/************************************************************
Schedulers
************************************************************/
### 実行時間の翌日0時(JST)のUTCを取得
resource "time_static" "base" {}

locals {
  now_jst_hour = tonumber(formatdate("H", timeadd(time_static.base.rfc3339, "9h")))
  now_jst_min  = tonumber(formatdate("m", timeadd(time_static.base.rfc3339, "9h")))
  now_jst_sec  = tonumber(formatdate("s", timeadd(time_static.base.rfc3339, "9h")))
  remain_seconds = (
    (23 - local.now_jst_hour) * 3600 +
    (59 - local.now_jst_min) * 60 +
    (60 - local.now_jst_sec)
  )

  waf_close_offset       = -1
  next_jst_waf_close_utc = timeadd(time_static.base.rfc3339, "${local.remain_seconds + local.waf_close_offset * 3600}s")
  com_start_offset       = 6
  next_jst_com_start_utc = timeadd(time_static.base.rfc3339, "${local.remain_seconds + local.com_start_offset * 3600}s")
}

locals {
  schedulers = {
    waf_close = {
      name        = "web-application-closing"
      description = "Start WAF Closing Functions"
      action      = "START_RESOURCE"
      fn_ocid     = var.fn_close_ocid
      time_start  = local.next_jst_waf_close_utc
    }
    com_start = {
      name        = "web-application-opening"
      description = "Start Compute Start Functions"
      action      = "START_RESOURCE"
      fn_ocid     = var.fn_start_ocid
      time_start  = local.next_jst_com_start_utc
    }
  }
}