@EndUserText.label: 'Rejection Abstract Entity'
define root abstract entity ZAP_D_POPUP_REJECTION
{
@Consumption.valueHelpDefinition: [{ entity: { name: 'ZAP_I_MSG_REJECTION_CODE_VH', element: 'MessageNumber' } } ]
 RejectionMessageCode : zap_de_message_num;
}
