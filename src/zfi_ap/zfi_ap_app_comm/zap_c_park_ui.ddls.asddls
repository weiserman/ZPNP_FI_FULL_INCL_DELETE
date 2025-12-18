@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Parking Projection'
@ObjectModel.modelingPattern: #ANALYTICAL_QUERY
@ObjectModel.supportedCapabilities: [#ANALYTICAL_QUERY]
define root view entity ZAP_C_PARK_UI
provider contract transactional_query
as projection on ZAP_R_PARK
{
    key ParkUuid,
    ParentUuid,
@Consumption.valueHelpDefinition: [{ entity: { name: 'ZAP_I_STATUS_VH', element: 'Status' } } ]
@ObjectModel.text.element: ['StepStatus_Description']    
    Status,
    ParkDoc,
    ParkDocYear,
@Consumption.valueHelpDefinition: [{ entity: { name: 'ZAP_I_DOC_STS_VH', element: 'ParkDocStatus' } } ]
@ObjectModel.text.element: ['ParkDocStatus_Description']      
    ParkDocStatus,
    ParkLogId,
    LocalCreatedBy,
    LocalCreatedAt,
    LocalLastChangedBy,
    LocalLastChangedAt,
    LastChangedAt,
    
      /* Technical */
     _StepStatusVH.Description as StepStatus_Description, 
     _DocStatusVH.Description as ParkDocStatus_Description,      
    /* Associations */
    _Comm,
    _Logs : redirected to composition child ZAP_C_PARK_LOG_UI,
    _StepStatusVH,
    _DocStatusVH,    
    _Val
}
