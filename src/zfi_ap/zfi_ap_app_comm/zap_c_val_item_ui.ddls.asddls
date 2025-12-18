@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Validation Item Projection'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZAP_C_VAL_ITEM_UI
  as projection on ZAP_I_VAL_ITEM

{
  key ItemUuid,
      valUuid,
      ItemDescription,
      ItemQuantity,
      ItemNettValue,
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,
      /* Associations */
      _Val : redirected to parent ZAP_C_VAL_UI
}
