@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Validation Log  Interface View'
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #COMPOSITE
@ObjectModel.usageType:{
    serviceQuality: #A,
    sizeCategory: #L,
    dataClass: #MIXED
    }
define view entity ZAP_I_PARK_LOG
  as select from ZAP_B_PARK_LOG
  association to parent ZAP_R_PARK as _Park on $projection.ParkUuid = _Park.ParkUuid
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
      _Park // Make association public
}
