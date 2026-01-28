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
      @ObjectModel.text.element: [ 'LocalCreatedByUserName' ]      
      LocalCreatedBy,
      LocalCreatedAt,
      @ObjectModel.text.element: [ 'LocalLastChangedByUserName' ]      
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,
      /* Technical */
      @UI.hidden: true
      _CreatedUser.UserDescription as LocalCreatedByUserName,
      @UI.hidden: true
      _ChangedUser.UserDescription as LocalLastChangedByUserName,

      _MsgConfig.Criticality,
      /* Associations */
      _Val : redirected to parent ZAP_C_VAL_UI
}
