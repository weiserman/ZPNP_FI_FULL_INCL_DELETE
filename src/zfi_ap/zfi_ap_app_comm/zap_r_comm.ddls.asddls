@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Communication Header Root View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZAP_R_COMM
  as select from ZAP_I_COMM
  composition [0..*] of ZAP_I_ATTACH     as _Attachments
  composition [0..*] of ZAP_I_COMM_LOG   as _Logs

  association [0..*] to ZAP_R_OCR        as _OCR                 on  $projection.CommUuid = _OCR.ParentUuid
  association [0..*] to ZAP_R_VAL        as _Val                 on  $projection.CommUuid = _Val.ParentUuid
  association [0..*] to ZAP_R_APPR       as _Appr                on  $projection.CommUuid = _Appr.ParentUuid

  association [0..*] to ZAP_I_COMM_LOG   as _LatestLogs          on  $projection.CommUuid  = _LatestLogs.CommUuid
                                                                 and $projection.CommLogId = _LatestLogs.LogId

  association [1..1] to ZAP_I_STATUS_VH  as _CurrentStepStatusVH on  $projection.CurrentStepStatus = _CurrentStepStatusVH.Status
  association [1..1] to ZAP_I_STEP_VH    as _CurrentStepVH       on  $projection.CurrentStep = _CurrentStepVH.Step
  association [1..1] to ZAP_I_CHANNEL_VH as _ChannelVH           on  $projection.Channel = _ChannelVH.Channel

  association [0..1] to I_User           as _CreatedUser         on  $projection.LocalCreatedBy = _CreatedUser.UserID
  association [0..1] to I_User           as _ChangedUser         on  $projection.LocalCreatedBy = _ChangedUser.UserID

  association [0..1] to ZAP_I_MSG_CFG    as _CurrentMsgCfg       on  $projection.CurrentStep       = _CurrentMsgCfg.Step
                                                                 and $projection.CurrentStepStatus = _CurrentMsgCfg.MessageNumber

{
  key CommUuid,
      ExternalId,
      Channel,
      ChannelType,
      CountryCode,
      IntegrationCorrelationId,
      CommStatus,
      CommLogId,
      CurrentStep,
      CurrentStepStatus,
      CurrentStepProccessedAt,
      EmailId,
      EmailSenderAddr,
      EmailSubject,
      EmailSentAt,
      EmailReceivedAt,
      VendorNumber,
      InvoiceReference,
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

      //Associations
      _Attachments,
      _Logs,
      _OCR,
      _Val,
      _Appr,
      _LatestLogs,
      _CurrentStepStatusVH,
      _CurrentStepVH,
      _ChannelVH,
      _CreatedUser,
      _ChangedUser,
      _CurrentMsgCfg

}
