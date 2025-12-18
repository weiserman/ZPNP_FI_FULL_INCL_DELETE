@EndUserText.label: 'OCR Invoice Event Abstract Entity'
define abstract entity ZAP_D_EVENT_OCR_INVOICE
//  with parameters parameter_name : parameter_type
{
    comm_uuid              : sysuuid_x16;
    current_step           : zap_de_current_step;
    current_step_status    : zap_de_current_step_status;
}
