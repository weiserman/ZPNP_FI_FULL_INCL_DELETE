@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'OCR Invoice Item Basic Interface View'
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #BASIC
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZAP_B_OCR_ITEM
  as select from zap_a_ocr_item
{
  key item_uuid             as ItemUuid,
      ocr_uuid              as OcrUuid,
      item_description      as ItemDescription,
      item_quantity         as ItemQuantity,
      item_nett_value       as ItemNettValue,
      local_created_by      as LocalCreatedBy,
      local_created_at      as LocalCreatedAt,
      local_last_changed_by as LocalLastChangedBy,
      local_last_changed_at as LocalLastChangedAt,
      last_changed_at       as LastChangedAt
}
