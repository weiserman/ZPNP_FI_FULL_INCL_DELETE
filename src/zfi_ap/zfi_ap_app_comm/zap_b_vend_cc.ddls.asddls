@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Vendor Company Code Data Basic View'
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #BASIC
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #M,
    dataClass: #MIXED
}
define view entity ZAP_B_VEND_CC
  as select from zap_a_vend_cc
{
  key vendor_number           as VendorNumber,
  key po_ccode                as PoCcode,
      process_clerk           as ProcessClerk,
      proc_clerk_btp_uname    as ProcClerkBtpUname,
      supvsor_clerk           as SupvsorClerk,
      supvsor_clerk_btp_uname as SupvsorClerkBtpUname
}
