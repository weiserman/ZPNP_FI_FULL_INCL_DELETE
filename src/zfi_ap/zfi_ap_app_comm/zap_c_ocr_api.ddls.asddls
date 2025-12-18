@AccessControl.authorizationCheck: #NOT_ALLOWED
@EndUserText.label: 'OCR Invoice'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZAP_C_OCR_API
  provider contract transactional_query
  as projection on ZAP_R_OCR
{
  key OcrUuid,
      ParentUuid,
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

      /* Associations */
      _Items : redirected to composition child ZAP_C_OCR_ITEM_API,
      _Logs  : redirected to composition child ZAP_C_OCR_LOG_API
}
