@EndUserText.label: 'Message Config'
@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
define view entity ZI_MessageConfig
  as select from zap_a_msg_cfg
  association to parent ZI_MessageConfig_S as _MessageConfigAll on $projection.SingletonID = _MessageConfigAll.SingletonID
{
  key message_number        as MessageNumber,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZAP_I_STEP_VH', element: 'Step' } } ]
      step                  as Step,
      message               as Message,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZCA_I_CRITICALITY_VH', element: 'Criticality' } } ]
      criticality           as Criticality,
      @Semantics.user.createdBy: true
      local_created_by      as LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      local_created_at      as LocalCreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      @Consumption.hidden: true
      local_last_changed_by as LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      @Consumption.hidden: true
      local_last_changed_at as LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Consumption.hidden: true
      1                     as SingletonID,
      _MessageConfigAll
}
