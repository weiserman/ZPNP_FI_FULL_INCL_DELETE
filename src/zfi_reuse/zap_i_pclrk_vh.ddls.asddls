@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Processing ClerkValue Help'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
define view entity ZAP_I_PCLRK_VH

  as select distinct from  zap_a_vend_cc as Vend_Cc 
  left outer join I_User as User on User.UserID = Vend_Cc.proc_clerk_btp_uname
{
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 1.0
      @ObjectModel.text.element: ['Description']
  key Vend_Cc.process_clerk as ProcessClerk,
      @Semantics.text: true
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
//      User.UserDescription       as Description
      case
        when User.UserID is null then 'Unknown'
        when User.UserID = '' then 'Unknown'
        else User.UserDescription
      end as  Description 
}
