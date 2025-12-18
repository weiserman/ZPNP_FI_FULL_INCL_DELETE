@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'OCR Invoice Log Interface View'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZAP_I_OCR_LOG
  as select from ZAP_B_OCR_LOG
  association to parent ZAP_R_OCR as _Ocr on $projection.OcrUuid = _Ocr.OcrUuid
{
  key LogUuid,
      OcrUuid,
      LogId,
      MessageClass,
      MessageType,
      MessageNumber,
      MessageVar1,
      MessageVar2,
      MessageVar3,
      MessageVar4,
      DetailedMessage,
      @Semantics.user.createdBy: true
      LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      LocalCreatedAt,
      @Semantics.user.lastChangedBy: true
      LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      LocalLastChangedAt,
      LastChangedAt,
      
      //Association
      _Ocr 
}
