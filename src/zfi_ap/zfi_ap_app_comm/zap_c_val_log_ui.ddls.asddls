@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Validation Log Projection'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZAP_C_VAL_LOG_UI
  as projection on ZAP_I_VAL_LOG
{
  key LogUuid,
      ValUuid,
      LogId,
      MessageClass,
      MessageType,
      MessageNumber,
      MessageVar1,
      MessageVar2,
      MessageVar3,
      MessageVar4,
      DetailedMessage,
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,

      /* Associations */
      _Val : redirected to parent ZAP_C_VAL_UI
}
