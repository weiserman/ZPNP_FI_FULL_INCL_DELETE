@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'OCR Item'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZAP_C_OCR_ITEM_UI
  as projection on ZAP_I_OCR_ITEM
{
  key ItemUuid,
      OcrUuid,
      ItemDescription,
      ItemQuantity,
      ItemNettValue,
      
      /* Associations */
      _Ocr : redirected to parent ZAP_C_OCR_UI
}
