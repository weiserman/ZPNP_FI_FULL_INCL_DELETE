@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Approvals'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZAP_R_APPR
  as select from ZAP_I_APPR
  composition [0..*] of ZAP_I_APPR_LOG as _Logs
{
  key ApprovalUuid,
      ParentUuid,
      ExternalId,
      Status,
      SharepointApprovalStatus,
      SharepointApprovalId,
      SharepointApproverName,
      SharepointApproverEmail,
      ApprLogId,
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

      _Logs
}
