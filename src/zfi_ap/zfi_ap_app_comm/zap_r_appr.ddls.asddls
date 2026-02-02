@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Approvals'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZAP_R_APPR
  as select from ZAP_I_APPR
  composition [0..*] of ZAP_I_APPR_LOG as _Logs
  
  association [0..1] to ZAP_I_MSG_CFG  as _StatusMsgConfig on $projection.Status = _StatusMsgConfig.MessageNumber

  association [0..1] to I_User         as _CreatedUser     on $projection.LocalCreatedBy = _CreatedUser.UserID
  association [0..1] to I_User         as _ChangedUser     on $projection.LocalCreatedBy = _ChangedUser.UserID 
  
{
  key ApprovalUuid,
      ParentUuid,
      ExternalId,
      Status,
      SharepointId,
      ResponseStatus,
      ResponseMessageNumber,
      ResponseMessage,
      ResponseTimestamp,
      ApproverName,
      ApproverEmail,
      ApprLogId,
      @Semantics.user.createdBy: true
      LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      LocalCreatedAt,
      @Semantics.user.lastChangedBy: true
      LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      LocalLastChangedAt,
      LastChangedAt,

      //Associations
      _Logs

}
