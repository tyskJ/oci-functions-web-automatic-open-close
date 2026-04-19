/************************************************************
Dynamic Group - Functions
************************************************************/
# 「oci_identity_dynamic_group」を使用する場合はルートコンパートメントのDefaultアイデンティティドメインにしか作成できない
# 「oci_identity_domains_dynamic_resource_group」を使用すれば、指定のアイデンティティドメインに作成可能
resource "oci_identity_dynamic_group" "functions" {
  compartment_id = var.tenancy_ocid
  name           = "Functions_Dynamic_Group"
  description    = "Functions Dynamic Group"
  matching_rule = format(
    "All {resource.type = 'fnfunc', resource.compartment.id = '%s'}",
    oci_identity_compartment.workload.id
  )
}

/************************************************************
Auth Token
************************************************************/
resource "oci_identity_auth_token" "this" {
  user_id     = var.work_user_ocid
  description = "For OCI Container Registry Login PW"
}

resource "local_sensitive_file" "auth_token" {
  filename = "./.key/work_user_auth_token.txt"
  content  = oci_identity_auth_token.this.token
}