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
define view entity zap_b_appr
  as select from zap_a_appr
{
  key approval_uuid           as ApprovalUuid,
      parent_uuid             as ParentUuid,
      external_id             as ExternalId,
      status                  as Status,
      sharepoint_id           as SharepointId,
      response_status         as ResponseStatus,
      response_message_number as ResponseMessageNumber,
      response_message        as ResponseMessage,
      response_timestamp      as ResponseTimestamp,
      approver_name           as ApproverName,
      approver_email          as ApproverEmail,
      appr_log_id             as ApprLogId,
      local_created_by        as LocalCreatedBy,
      local_created_at        as LocalCreatedAt,
      local_last_changed_by   as LocalLastChangedBy,
      local_last_changed_at   as LocalLastChangedAt,
      last_changed_at         as LastChangedAt
}
