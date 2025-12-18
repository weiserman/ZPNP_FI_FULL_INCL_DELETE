@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Logs'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZAP_C_APPR_LOG_API
  as projection on ZAP_I_APPR_LOG
{
  key LogUuid,
      ApprovalUuid,
      MessageType,
      MessageNumber,
      DetailedMessage,

      /* Associations */
      _Appr : redirected to parent ZAP_C_APPR_API
}
