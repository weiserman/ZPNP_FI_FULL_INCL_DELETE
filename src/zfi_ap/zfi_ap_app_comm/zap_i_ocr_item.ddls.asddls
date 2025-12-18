@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'OCR Invoice Item Interface View'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZAP_I_OCR_ITEM
  as select from ZAP_B_OCR_ITEM
  association to parent ZAP_R_OCR as _Ocr on $projection.OcrUuid = _Ocr.OcrUuid
{
  key ItemUuid,
      OcrUuid,
      ItemDescription,
      ItemQuantity,
      ItemNettValue,
      @Semantics.user.createdBy: true
      LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      LocalCreatedAt,
      @Semantics.user.lastChangedBy: true
      LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      LocalLastChangedAt,
      LastChangedAt,
 
      _Ocr // Make association public
}
