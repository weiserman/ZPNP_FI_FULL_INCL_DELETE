@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'OCR Invoice Header Root View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZAP_R_OCR
  as select from ZAP_I_OCR_HEAD
  composition [0..*] of ZAP_I_OCR_ITEM as _Items
  composition [0..*] of ZAP_I_OCR_LOG  as _Logs

  association [1..1] to ZAP_C_COMM_UI  as _Comm            on $projection.ParentUuid = _Comm.CommUuid

  association [0..1] to ZAP_I_MSG_CFG  as _StatusMsgConfig on $projection.Status = _StatusMsgConfig.MessageNumber

  association [0..1] to I_User         as _CreatedUser     on $projection.LocalCreatedBy = _CreatedUser.UserID
  association [0..1] to I_User         as _ChangedUser     on $projection.LocalCreatedBy = _ChangedUser.UserID

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
      @Semantics.user.createdBy: true
      LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      LocalCreatedAt,
      @Semantics.user.lastChangedBy: true
      LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      LocalLastChangedAt,
      LastChangedAt,

      // Make association public
      _Items,
      _Logs,
      _Comm,
      _CreatedUser,
      _ChangedUser,
      _StatusMsgConfig
}
