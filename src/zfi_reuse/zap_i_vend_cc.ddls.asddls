@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Vendor Company Code Data Interface View'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #M,
    dataClass: #MIXED
}
define view entity ZAP_I_VEND_CC
  as select from ZAP_B_VEND_CC 
  association [1..1] to ZAP_I_PCLRK_VH as _Proc_ClrkVH on $projection.ProcessClerk = _Proc_ClrkVH.ProcessClerk
  association [1..1] to ZAP_I_SCLRK_VH as _Supv_ClrkVH on $projection.SupvsorClerk = _Supv_ClrkVH.SupvsorClerk  
{
  key VendorNumber,
  key PoCcode,
  @Consumption.valueHelpDefinition: [{ entity: { name: 'ZAP_I_PCLRK_VH', element: 'ProcessClerk' } } ]
  @ObjectModel.text.element: ['ProcessClerk_Description']
//@UI:{ lineItem: [{ criticality: 'CurrentStepStatus_Criticality' }]}
      ProcessClerk,
      ProcClerkBtpUname,
    
      /* Technical */
      _Proc_ClrkVH.Description as ProcessClerk_Description,        
      
  @Consumption.valueHelpDefinition: [{ entity: { name: 'ZAP_I_SCLRK_VH', element: 'SupvsorClerk' } } ]
  @ObjectModel.text.element: ['SupervisorClerk_Description']
//@UI:{ lineItem: [{ criticality: 'CurrentStepStatus_Criticality' }]}      
      SupvsorClerk,
      SupvsorClerkBtpUname,

      /* Technical */      
      _Supv_ClrkVH.Description as SupervisorClerk_Description,        
      _Proc_ClrkVH, // Make association public
      _Supv_ClrkVH 

}
