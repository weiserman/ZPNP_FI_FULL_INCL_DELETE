@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Approval Log'
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #BASIC
@ObjectModel.usageType:{
    serviceQuality: #A,
    sizeCategory: #L,
    dataClass: #MIXED
}
define view entity ZAP_B_APPR_LOG
  as select from zap_a_appr_log
{
  key log_uuid              as LogUuid,
      approval_uuid         as ApprovalUuid,
      log_id                as LogId,
      message_class         as MessageClass,
      message_type          as MessageType,
      message_number        as MessageNumber,
      message_var1          as MessageVar1,
      message_var2          as MessageVar2,
      message_var3          as MessageVar3,
      message_var4          as MessageVar4,
      detailed_message      as DetailedMessage,
      local_created_by      as LocalCreatedBy,
      local_created_at      as LocalCreatedAt,
      local_last_changed_by as LocalLastChangedBy,
      local_last_changed_at as LocalLastChangedAt,
      last_changed_at       as LastChangedAt
}
