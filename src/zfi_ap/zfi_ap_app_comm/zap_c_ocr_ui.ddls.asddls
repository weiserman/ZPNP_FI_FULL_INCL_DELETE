@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Communication UI Projection View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZAP_C_OCR_UI
  provider contract transactional_query
  as projection on ZAP_R_OCR
{
  key OcrUuid,
      ParentUuid,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZAP_I_STATUS_VH', element: 'Status' } } ]
      @ObjectModel.text.element: ['Status_Description']
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
      @ObjectModel.text.element: [ 'LocalCreatedByUserName' ]
      LocalCreatedBy,
      @Consumption.filter: { selectionType: #INTERVAL, multipleSelections: false }
      LocalCreatedAt,
      @ObjectModel.text.element: [ 'LocalLastChangedByUserName' ]
      LocalLastChangedBy,
      @Consumption.filter: { selectionType: #INTERVAL, multipleSelections: false }
      LocalLastChangedAt,

      /* Technical */
      @UI.hidden: true
      _CreatedUser.UserDescription as LocalCreatedByUserName,
      @UI.hidden: true
      _ChangedUser.UserDescription as LocalLastChangedByUserName,
      @UI.hidden: true
      LastChangedAt,

      _StatusMsgConfig.Message     as Status_Description,
      _StatusMsgConfig.Criticality as Status_Criticality,

      /* Associations */
      _Items : redirected to composition child ZAP_C_OCR_ITEM_UI,
      _Logs  : redirected to composition child ZAP_C_OCR_LOG_UI,
      _Comm
}
