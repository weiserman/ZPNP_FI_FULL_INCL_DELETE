@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Approvals'
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #BASIC
@ObjectModel.usageType:{
    serviceQuality: #A,
    sizeCategory: #L,
    dataClass: #MIXED
}
define view entity zap_B_appr
  as select from zap_a_appr
{
  key approval_uuid              as ApprovalUuid,
      parent_uuid                as ParentUuid,
      external_id                as ExternalId,
      status                     as Status,
      sharepoint_approval_status as SharepointApprovalStatus,
      sharepoint_approval_id     as SharepointApprovalId,
      sharepoint_approver_name   as SharepointApproverName,
      sharepoint_approver_email  as SharepointApproverEmail,
      appr_log_id                as ApprLogId,
      local_created_by           as LocalCreatedBy,
      local_created_at           as LocalCreatedAt,
      local_last_changed_by      as LocalLastChangedBy,
      local_last_changed_at      as LocalLastChangedAt,
      last_changed_at            as LastChangedAt
}
