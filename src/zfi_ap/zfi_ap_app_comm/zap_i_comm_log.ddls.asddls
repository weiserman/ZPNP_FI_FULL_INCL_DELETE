@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Communication Log Interface View'
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #COMPOSITE
@ObjectModel.usageType:{
    serviceQuality: #A,
    sizeCategory: #L,
    dataClass: #MIXED
}
define view entity ZAP_I_COMM_LOG
  as select from ZAP_B_COMM_LOG
  association        to parent ZAP_R_COMM as _Comm        on  $projection.CommUuid = _Comm.CommUuid

  association [0..1] to ZAP_I_MSG_CFG     as _MsgConfig   on  $projection.MessageNumber = _MsgConfig.MessageNumber

  association [0..1] to I_User            as _CreatedUser on  $projection.LocalCreatedBy = _CreatedUser.UserID
  association [0..1] to I_User            as _ChangedUser on  $projection.LocalCreatedBy = _ChangedUser.UserID
{
  key LogUuid,
      CommUuid,
      LogId,
      MessageClass,
      MessageType,
      MessageNumber,
      MessageVar1,
      MessageVar2,
      MessageVar3,
      MessageVar4,
      DetailedMessage,
      @Semantics.user.createdBy: true
      LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      LocalCreatedAt,
      @Semantics.user.lastChangedBy: true
      LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      LastChangedAt,

      //Association
      _Comm,
      _MsgConfig,
      _CreatedUser,
      _ChangedUser
}
