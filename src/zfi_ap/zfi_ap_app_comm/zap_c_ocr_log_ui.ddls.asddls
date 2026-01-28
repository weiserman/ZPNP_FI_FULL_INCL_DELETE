@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'OCR Log'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZAP_C_OCR_LOG_UI
  as projection on ZAP_I_OCR_LOG
{
  key LogUuid,
      OcrUuid,
      MessageType,
      MessageNumber,
      DetailedMessage,
      @ObjectModel.text.element: [ 'LocalCreatedByUserName' ]
      LocalCreatedBy,
      LocalCreatedAt,
      @ObjectModel.text.element: [ 'LocalLastChangedByUserName' ]
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,

      /* Technical */
      @UI.hidden: true
      _CreatedUser.UserDescription as LocalCreatedByUserName,
      @UI.hidden: true
      _ChangedUser.UserDescription as LocalLastChangedByUserName,

      _MsgConfig.Criticality,

      /* Associations */
      _Ocr : redirected to parent ZAP_C_OCR_UI

}
