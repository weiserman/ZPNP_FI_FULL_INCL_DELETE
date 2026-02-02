@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Approvals'
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #COMPOSITE
@ObjectModel.usageType:{
    serviceQuality: #A,
    sizeCategory: #L,
    dataClass: #MIXED
}
define view entity ZAP_I_APPR
  as select from zap_B_appr
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
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt

}
