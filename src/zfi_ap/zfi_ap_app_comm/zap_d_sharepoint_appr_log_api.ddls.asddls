@EndUserText.label: 'Sharepoint Approval Log API'
define abstract entity ZAP_D_SHAREPOINT_APPR_LOG_API
{
  key log_number       : abap.char(3);
      approval_uuid    : sysuuid_x16;
      message_number   : zap_de_message_num;
      detailed_message : zap_de_detailed_message;

      _Approval        : association to parent ZAP_D_SHAREPOINT_APPR_API on $projection.approval_uuid = _Approval.approval_uuid;
}
