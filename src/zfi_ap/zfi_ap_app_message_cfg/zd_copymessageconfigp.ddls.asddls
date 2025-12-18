@EndUserText.label: 'Copy Message Config'
define abstract entity ZD_CopyMessageConfigP
{
  @EndUserText.label: 'New Step'
  @UI.defaultValue: #( 'ELEMENT_OF_REFERENCED_ENTITY: Step' )
  Step : ZAP_DE_STEP;
  @EndUserText.label: 'New Message Number'
  @UI.defaultValue: #( 'ELEMENT_OF_REFERENCED_ENTITY: MessageNumber' )
  MessageNumber : ZAP_DE_MESSAGE_NUM;
}
