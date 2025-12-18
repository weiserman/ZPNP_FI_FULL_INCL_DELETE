@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Parking Header Basic Interface View'
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #BASIC
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #L,
    dataClass: #MIXED
}
define view entity ZAP_B_PARK_HEAD
  as select from zap_a_park_head
{
  key park_uuid             as ParkUuid,
      parent_uuid           as ParentUuid,
      status                as Status,
      park_log_id           as ParkLogId,
      park_doc              as ParkDoc,
      park_doc_year         as ParkDocYear,
      park_doc_status       as ParkDocStatus,
      local_created_by      as LocalCreatedBy,
      local_created_at      as LocalCreatedAt,
      local_last_changed_by as LocalLastChangedBy,
      local_last_changed_at as LocalLastChangedAt,
      last_changed_at       as LastChangedAt

}
