@EndUserText.label: 'Sharepoint Approval API'
define root abstract entity ZAP_D_SHAREP_APPR_CREATE_RESP
{
  key approval_uuid    : sysuuid_x16;
      sharepoint_id    : zap_de_sharep_approval_id;
      status           : zap_de_sharep_approval_cre_sts;
      message_number   : zap_de_message_num;
      detailed_message : zap_de_detailed_message;
}
