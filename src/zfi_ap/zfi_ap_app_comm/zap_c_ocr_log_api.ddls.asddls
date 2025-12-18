@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'OCR Log'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZAP_C_OCR_LOG_API
  as projection on ZAP_I_OCR_LOG
{
  key LogUuid,
      OcrUuid,
//      CorrelationUuid,
 //     Messageclass,
      MessageType,
      MessageNumber,
//      Messagevar1,
//      Messagevar2,
//      Messagevar3,
//      Messagevar4,
      DetailedMessage,
//      Messagecriticality,
//      LocalLastChangedAt,
      /* Associations */
      _Ocr : redirected to parent ZAP_C_OCR_API

}
