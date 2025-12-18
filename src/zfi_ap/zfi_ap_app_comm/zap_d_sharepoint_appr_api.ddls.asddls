@EndUserText.label: 'Sharepoint Approval API'
define root abstract entity ZAP_D_SHAREPOINT_APPR_API
{
  key approval_uuid    : sysuuid_x16;
      approval_status  : zap_de_sharep_approval_status;
      sharepoint_id    : zap_de_sharep_approval_id;
      approver_name    : zap_de_sharep_approver_name;
      approver_email   : zap_de_sharep_approver_email;
      createdtimestamp : zap_de_sharep_createdtimestamp;

      _Log             : composition [1..*] of ZAP_D_SHAREPOINT_APPR_LOG_API;
}

