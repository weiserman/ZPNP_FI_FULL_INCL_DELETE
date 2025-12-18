@EndUserText.label: 'Rejection Abstract Entity'
define abstract entity ZAP_D_POPUP_REJECTION
{
@Consumption.valueHelpDefinition: [{ entity: { name: 'ZAP_I_MSG_REJECTION_CODE_VH', element: 'MessageNumber' } } ]
  rejection_number : zap_de_message_num;
}
