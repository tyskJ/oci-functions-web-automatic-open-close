import io
import json
import logging
import oci

from fdk import response
    
"""
EntryPoint
"""
def handler(ctx, data: io.BytesIO = None):
    logger = logging.getLogger()
    logger.info("LogAnalytics Storage Purge Started")
    # ----- 1. Resource Principal Signer -----
    try:
        signer = oci.auth.signers.get_resource_principals_signer()
        logger.info("Resource Principal Signer acquired successfully")
    except Exception as e:
        logger.error(f"Failed to get Resource Principal Signer: {e}")
        return error_response(ctx, str(e), 500)
    # ----- 2. WAF Client -----
    try:
        waf_client = oci.waf.WafClient(
            config={},
            signer=signer
        )
        logger.info("WafClient initialized")
    except Exception as e:
        logger.error(f"Failed to initialize WafClient: {e}")
        return error_response(ctx, str(e), 500)
    # ----- 3. WAF Policy ID 取得 -----
    try:
        identity_client = oci.identity.IdentityClient(
            config={},
            signer=signer
        )
        tenancy_id = signer.tenancy_id
        resp = identity_client.list_compartments(
            compartment_id=tenancy_id,
            compartment_id_in_subtree=True,
            lifecycle_state="ACTIVE",
            name="oci-functions-web-automatic-open-close"
        )
        compartment_id = resp.data[0].id
        resp = waf_client.list_web_app_firewall_policies(
            compartment_id=compartment_id,
            display_name="regional-waf-policy"
        )
        waf_policy_id = resp.data.items[0].id
    except oci.exceptions.ServiceError as e:
        logger.error(
            "Get Waf Policy ID failed: "
            f"status={e.status}, code={e.code}, message={e.message}"
        )
        return error_response(ctx, e.message, e.status)
    except Exception as e:
        logger.error(f"Unexpected error during get waf policy id: {e}")
        return error_response(ctx, str(e), 500)
    # ----- 4. 固定レスポンス設定 -----
    try:
        before_waf_policy_details = waf_client.get_web_app_firewall_policy(
            web_app_firewall_policy_id=waf_policy_id
        ).data
        if before_waf_policy_details.request_access_control.default_action_name == "Custom-configured-503-sorry-page":
            return success_response(
                ctx,
                {
                    "message": "Already default action is Sorry page."
                },
                202
            )
        else:
            update_waf_policy_details = oci.waf.models.UpdateWebAppFirewallPolicyDetails(
                request_access_control=oci.waf.models.RequestAccessControl(
                    default_action_name="Custom-configured-503-sorry-page",
                    rules=before_waf_policy_details.request_access_control.rules
                )
            )
            resp = waf_client.update_web_app_firewall_policy(
                web_app_firewall_policy_id=waf_policy_id,
                update_web_app_firewall_policy_details=update_waf_policy_details
            )
            work_request_id = resp.headers.get("opc-work-request-id")
            logger.info(
                "WAF Policy Default Action Update to Sorry Page. "
                f"workRequestId={work_request_id}"
            )
            return success_response(
                ctx,
                {
                    "message": "WAF Policy Default Action Update to Sorry Page.",
                    "work_request_id": work_request_id
                },
                202
            )
    except oci.exceptions.ServiceError as e:
        logger.error(
            "Update WAF Policy add SorryPage failed: "
            f"status={e.status}, code={e.code}, message={e.message}"
        )
        return error_response(ctx, e.message, e.status)
    except Exception as e:
        logger.error(f"Unexpected error during update waf policy add sorry page: {e}")
        return error_response(ctx, str(e), 500)

"""
Common Func
"""
def success_response(ctx, data: dict, status_code: int=200):
    """成功レスポンスを返す"""
    return response.Response(
        ctx,
        response_data=json.dumps(
            data, 
            ensure_ascii=False, 
            indent=2
        ),
        headers={"Content-Type": "application/json"},
        status_code=status_code
    )

def error_response(ctx, error_message: str, status_code: int=500):
    """エラーレスポンスを返す"""
    return response.Response(
        ctx,
        response_data=json.dumps(
            {"error": error_message}, 
            ensure_ascii=False
        ),
        headers={"Content-Type": "application/json"},
        status_code=status_code
    )