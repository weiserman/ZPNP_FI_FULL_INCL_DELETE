@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Communication UI Projection View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZAP_C_OCR_UI
  provider contract transactional_query
  as projection on ZAP_R_OCR
{
  key OcrUuid,
      ParentUuid,
      Status,
      LogId,
      IntegrationCorrelationId,
      InvoiceReference,
      InvoiceDate,
      VendorName,
      VendorVatNumber,
      PnpVatNumber,
      TotalVatInclusive,
      VatValue,
      PurchaseOrderNumber,
      AwsExecutionName,
      AwsS3JsonBucket,
      AwsS3JsonObjectKey,
      AwsS3RawLlmBucket,
      AwsS3RawLlmObjectKey,
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      @Consumption.filter: { selectionType: #INTERVAL, multipleSelections: false }
      LocalLastChangedAt,
      
      /* Associations */
      _Items,
      _Logs
}
