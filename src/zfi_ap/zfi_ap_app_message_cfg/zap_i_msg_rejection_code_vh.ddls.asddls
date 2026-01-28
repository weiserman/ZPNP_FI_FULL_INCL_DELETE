@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Rejection Codes Value Help'
@Search.searchable: true
@ObjectModel.resultSet.sizeCategory: #XS
define view entity ZAP_I_MSG_REJECTION_CODE_VH
  as select from ZAP_I_MSG_CFG
{
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 1.0
      @EndUserText.label: 'Rejection Code'
      @ObjectModel.text.element: ['Message']
  key MessageNumber,
      @Semantics.text: true
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @EndUserText.label: 'Description'
      Message
}
where
  MessageNumber like '9%'
