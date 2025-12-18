@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Logs'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZAP_C_EMAIL_LOG_API
  as projection on ZAP_I_COMM_LOG
{
  key LogUuid,
      CommUuid,
      MessageType,
      MessageNumber,
      DetailedMessage,
      
      /* Associations */
      _Comm : redirected to parent ZAP_C_EMAIL_API
}
