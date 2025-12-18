@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Validation Item Interface View'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZAP_I_VAL_ITEM
  as select from ZAP_B_VAL_ITEM
     association to parent ZAP_R_VAL as _Val on $projection.ValUuid = _Val.ValUuid
{
  key ItemUuid,
      valUuid,
      ItemDescription,
      ItemQuantity,
      ItemNettValue,
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
