@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'OCR Invoice Header Interface View'
@VDM.viewType: #COMPOSITE
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #L,
    dataClass: #MIXED
}
define view entity ZAP_I_OCR_HEAD
  as select from ZAP_B_OCR_HEAD
{
  key OcrUuid,
      ParentUuid,
      Status,
      OcrLogId,
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
      @Semantics.user.createdBy: true
      LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      LocalCreatedAt,
      @Semantics.user.lastChangedBy: true
      LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      LocalLastChangedAt,
      LastChangedAt
      
}
