@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Message Config'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZAP_I_MSG_CFG
  as select from zap_a_msg_cfg
{
  key step                  as Step,
  key message_number        as MessageNumber,
      message               as Message,
      criticality           as Criticality,
      local_created_by      as LocalCreatedBy,
      local_created_at      as LocalCreatedAt,
      local_last_changed_by as LocalLastChangedBy,
      local_last_changed_at as LocalLastChangedAt,
      last_changed_at       as LastChangedAt
}
