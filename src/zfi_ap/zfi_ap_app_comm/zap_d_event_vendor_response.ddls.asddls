@EndUserText.label: 'Email Ingestion Event Abstract Entity'
define abstract entity ZAP_D_EVENT_VENDOR_RESPONSE
  //  with parameters parameter_name : parameter_type
{
  comm_uuid           : sysuuid_x16;
  current_step        : zap_de_current_step;
  current_step_status : zap_de_current_step_status;
  email_sender_addr   : zap_de_email_sender_addr;
}
