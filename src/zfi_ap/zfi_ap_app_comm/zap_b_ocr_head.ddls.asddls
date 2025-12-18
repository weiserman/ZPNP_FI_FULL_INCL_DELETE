@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'OCR Invoice Header Basic Interface View'
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #BASIC
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZAP_B_OCR_HEAD
  as select from zap_a_ocr_head
{
  key ocr_uuid                   as OcrUuid,
      parent_uuid                as ParentUuid,
      status                     as Status,
      log_id                     as LogId,
      integration_correlation_id as IntegrationCorrelationId,
      invoice_reference          as InvoiceReference,
      invoice_date               as InvoiceDate,
      vendor_name                as VendorName,
      vendor_vat_number          as VendorVatNumber,
      pnp_vat_number             as PnpVatNumber,
      total_vat_inclusive        as TotalVatInclusive,
      vat_value                  as VatValue,
      purchase_order_number      as PurchaseOrderNumber,
      aws_execution_name         as AwsExecutionName,
      aws_s3_json_bucket         as AwsS3JsonBucket,
      aws_s3_json_object_key     as AwsS3JsonObjectKey,
      aws_s3_raw_llm_bucket      as AwsS3RawLlmBucket,
      aws_s3_raw_llm_object_key  as AwsS3RawLlmObjectKey,
      local_created_by           as LocalCreatedBy,
      local_created_at           as LocalCreatedAt,
      local_last_changed_by      as LocalLastChangedBy,
      local_last_changed_at      as LocalLastChangedAt,
      last_changed_at            as LastChangedAt

}
