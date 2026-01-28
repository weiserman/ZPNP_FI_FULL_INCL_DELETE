@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Vendor Details'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZFI_I_VEND
  as select from zfi_a_vend
{
  key vendor_number         as VendorNumber,
      vendor_name           as VendorName,
      email_address         as EmailAddress,
      local_created_by      as LocalCreatedBy,
      local_created_at      as LocalCreatedAt,
      local_last_changed_by as LocalLastChangedBy,
      local_last_changed_at as LocalLastChangedAt
}
