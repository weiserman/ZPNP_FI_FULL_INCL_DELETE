@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Validation Header Basic Interface View'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #L,
    dataClass: #MIXED
}
define view entity ZAP_B_VAL_HEAD
  as select from zap_a_val_head
{
  key val_uuid              as ValUuid,
      parent_uuid           as ParentUuid,
      status                as Status,
      acknowledge_warning   as AcknowledgeWarning,
      val_log_id            as ValLogId,
      invoice_reference     as InvoiceReference,
      invoice_date          as InvoiceDate,
      vendor_name           as VendorName,
      vendor_vat_number     as VendorVatNumber,
      pnp_vat_number        as PnpVatNumber,
      total_vat_inclusive   as TotalVatInclusive,
      vat_value             as VatValue,
      purchase_order_number as PurchaseOrderNumber,
      vendor_number         as VendorNumber,
      po_ccode              as PoCcode,
      country_code          as CountryCode,     
      po_type               as PoType, 
      local_created_by      as LocalCreatedBy,
      local_created_at      as LocalCreatedAt,
      local_last_changed_by as LocalLastChangedBy,
      local_last_changed_at as LocalLastChangedAt,
      last_changed_at       as LastChangedAt

}
