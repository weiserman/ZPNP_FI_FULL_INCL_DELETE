@EndUserText.label: 'Message Config Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@ObjectModel.semanticKey: [ 'SingletonID' ]
@UI: {
  headerInfo: {
    typeName: 'MessageConfigAll'
  }
}
define root view entity ZI_MessageConfig_S
  as select from I_Language
    left outer join ZAP_A_MSG_CFG on 0 = 0
  association [0..*] to I_ABAPTransportRequestText as _ABAPTransportRequestText on $projection.TransportRequestID = _ABAPTransportRequestText.TransportRequestID
  composition [0..*] of ZI_MessageConfig as _MessageConfig
{
  @UI.facet: [ {
    id: 'ZI_MessageConfig', 
    purpose: #STANDARD, 
    type: #LINEITEM_REFERENCE, 
    label: 'Message Config', 
    position: 1 , 
    targetElement: '_MessageConfig'
  } ]
  @UI.lineItem: [ {
    position: 1 
  } ]
  key 1 as SingletonID,
  _MessageConfig,
  @UI.hidden: true
  max( ZAP_A_MSG_CFG.LAST_CHANGED_AT ) as LastChangedAtMax,
  @ObjectModel.text.association: '_ABAPTransportRequestText'
  @UI.identification: [ {
    position: 1 , 
    type: #WITH_INTENT_BASED_NAVIGATION, 
    semanticObjectAction: 'manage'
  } ]
  @Consumption.semanticObject: 'CustomizingTransport'
  cast( '' as SXCO_TRANSPORT) as TransportRequestID,
  _ABAPTransportRequestText
}
where I_Language.Language = $session.system_language
