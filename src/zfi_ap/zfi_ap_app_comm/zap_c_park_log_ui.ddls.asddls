@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Parking Log Projection'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZAP_C_PARK_LOG_UI as projection on ZAP_I_PARK_LOG
{
    key LogUuid,
    ParkUuid,
    LogId,
    MessageClass,
    MessageType, 
    MessageNumber,
    MessageVar1,
    MessageVar2,
    MessageVar3,
    MessageVar4,
    DetailedMessage,
    LocalCreatedBy,
    LocalCreatedAt,
    LocalLastChangedBy,
    LocalLastChangedAt,
    LastChangedAt,
    
    /* Associations */
    _Park : redirected to parent ZAP_C_PARK_UI
}
