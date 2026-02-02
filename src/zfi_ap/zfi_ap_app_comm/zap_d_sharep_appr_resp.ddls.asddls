@EndUserText.label: 'Sharepoint Approval Response'
define root abstract entity ZAP_D_SHAREP_APPR_RESP
{
  key ApprovalUuid     : sysuuid_x16;
      ExternalId       : zap_de_appr_external_id;
      SharepointId     : zap_de_sharep_approval_id;
      Status           : zap_de_sharep_appr_resp_sts;
      ApproverName     : zap_de_sharep_approver_name;
      ApproverEmail    : zap_de_sharep_approver_email;
      MessageCode      : zap_de_message_num;
      Message          : zap_de_detailed_message;
      CreatedTimestamp : zap_de_sharep_reponse_tstamp;
}
