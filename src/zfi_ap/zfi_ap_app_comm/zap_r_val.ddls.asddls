@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Validation Header Root View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZAP_R_VAL
  as select from ZAP_I_VAL_HEAD
  composition [0..*] of ZAP_I_VAL_ITEM  as _Items
  composition [0..*] of ZAP_I_VAL_LOG   as _Logs

  association [1..*] to ZAP_R_OCR       as _OCR          on  $projection.ParentUuid = _OCR.ParentUuid
  association [1..1] to ZAP_R_COMM      as _Comm         on  $projection.ParentUuid = _Comm.CommUuid
  association [1..*] to ZAP_I_ATTACH    as _Attachments  on  $projection.ParentUuid = _Attachments.ParentUuid
  association [0..1] to ZAP_I_VEND_CC   as _Vend_CCode   on  $projection.VendorNumber = _Vend_CCode.VendorNumber
                                                         and $projection.PoCcode      = _Vend_CCode.PoCcode

  association [1..1] to ZAP_I_STATUS_VH  as _StepStatusVH on  $projection.Status = _StepStatusVH.Status  
  association [1..1] to ZAP_I_PO_TYPE_VH as _POTypeVH     on  $projection.PoType = _POTypeVH.PoType  
//  association [1..1] to ZAP_I_STEP_VH    as _CurrentStepVH       on  $projection.CurrentStep = _CurrentStepVH.Step  

{
  key ValUuid,
      ParentUuid,
      Status,
      AcknowledgeWarning,
      ValLogId,
      InvoiceReference,
      InvoiceDate,
      VendorName,
      VendorVatNumber,
      PnpVatNumber,
      TotalVatInclusive,
      VatValue,
      PurchaseOrderNumber,
      CountryCode,
      VendorNumber,
      PoCcode,
      PoType,
      @Semantics.user.createdBy: true
      LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      LocalCreatedAt,
      @Semantics.user.lastChangedBy: true
      LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      LastChangedAt,
      _Items, // Make association public
      _Logs,
      _OCR,
      _Comm,
      _Attachments,
      _Vend_CCode,
      _StepStatusVH,
      _POTypeVH
//      _Proc_ClrkVH
      
}
