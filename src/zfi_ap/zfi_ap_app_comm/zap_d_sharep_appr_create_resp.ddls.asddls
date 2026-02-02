@EndUserText.label: 'Sharepoint Approval Create Response'
define root abstract entity ZAP_D_SHAREP_APPR_CREATE_RESP
{
  key ApprovalUuid : sysuuid_x16;
      SharepointId : zap_de_sharep_approval_id;
      Status       : zap_de_sharep_appr_resp_sts;
      MessageCode  : zap_de_message_num;
      Message      : zap_de_detailed_message;
}
