@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Document Status Value Help'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZAP_I_DOC_STS_VH
  as select from    DDCDS_CUSTOMER_DOMAIN_VALUE(
                      p_domain_name : 'ZAP_DM_PARK_DOC_STATUS') as Values
    left outer join DDCDS_CUSTOMER_DOMAIN_VALUE_T(
                      p_domain_name : 'ZAP_DM_PARK_DOC_STATUS') as Texts on  Texts.domain_name = Values.domain_name
                                                              and Texts.value_position = Values.value_position
                                                              and Texts.language       = $session.system_language
{
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 1.0
      @ObjectModel.text.element: ['Description']
  key Values.value_low as ParkDocStatus,
      @Semantics.text: true
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      Texts.text       as Description
}
