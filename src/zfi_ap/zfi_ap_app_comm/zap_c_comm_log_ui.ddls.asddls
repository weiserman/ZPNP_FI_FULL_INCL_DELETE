@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Communication Log Projection View'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZAP_C_COMM_LOG_UI
  as projection on ZAP_I_COMM_LOG
{
  key LogUuid,
      CommUuid,
      MessageType,
      MessageNumber,
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
      _Comm : redirected to parent ZAP_C_COMM_UI
}
