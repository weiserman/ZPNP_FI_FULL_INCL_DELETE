@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Vendor Details Value Help'
@Search.searchable: true
define view entity ZFI_I_VEND_VH
  as select from ZFI_I_VEND
{
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 1.0
      @EndUserText.label: 'Vendor'
      @ObjectModel.text.element: ['VendorName']
  key VendorNumber,
      @Semantics.text: true
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      VendorName,
      @Semantics.text: true
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      EmailAddress,
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt
}
