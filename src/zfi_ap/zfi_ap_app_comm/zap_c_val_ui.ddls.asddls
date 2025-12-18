@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Validation Head Projection'
@ObjectModel.modelingPattern: #ANALYTICAL_QUERY
@ObjectModel.supportedCapabilities: [#ANALYTICAL_QUERY]
define root view entity ZAP_C_VAL_UI
provider contract transactional_query
as projection on ZAP_R_VAL
{
    key ValUuid,
    ParentUuid,
@Consumption.valueHelpDefinition: [{ entity: { name: 'ZAP_I_STATUS_VH', element: 'Status' } } ]
@ObjectModel.text.element: ['StepStatus_Description']
//@UI:{ lineItem: [{ criticality: 'CurrentStepStatus_Criticality' }]}    
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
@Consumption.valueHelpDefinition: [{ entity: { name: 'ZAP_I_PO_TYPE_VH', element: 'PoType' } } ]
@ObjectModel.text.element: ['PoType_Desctription']    
    PoType,
    LocalCreatedBy,    
    LocalCreatedAt,
    LocalLastChangedBy,
    LocalLastChangedAt,
    LastChangedAt,
    
      /* Technical */
     _StepStatusVH.Description as StepStatus_Description,
     _POTypeVH.Description     as PoType_Desctription,
          
    /* Associations */
    _Items : redirected to composition child ZAP_C_VAL_ITEM_UI,
    _Logs  : redirected to composition child ZAP_C_VAL_LOG_UI,
    _Comm,
    _OCR,
    _Attachments,
    _Vend_CCode,
    
    _StepStatusVH,
    _POTypeVH
    
}
