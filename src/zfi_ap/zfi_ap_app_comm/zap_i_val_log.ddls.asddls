@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Validation Log  Interface View'
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #COMPOSITE
@ObjectModel.usageType:{
    serviceQuality: #A,
    sizeCategory: #L,
    dataClass: #MIXED
    }
define view entity ZAP_I_VAL_LOG
  as select from ZAP_B_VAL_log
    association to parent ZAP_R_VAL as _Val on $projection.ValUuid = _Val.ValUuid
{
  key LogUuid,
      ValUuid,
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
      _Val // Make association public
}
