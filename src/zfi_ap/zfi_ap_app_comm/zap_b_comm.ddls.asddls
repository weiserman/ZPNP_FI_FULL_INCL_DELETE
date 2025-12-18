@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Communication Header Basic View'
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #BASIC
@ObjectModel.usageType:{
    serviceQuality: #A,
    sizeCategory: #L,
    dataClass: #MIXED
}
define view entity ZAP_B_COMM
  as select from zap_a_comm
{
  key comm_uuid                  as CommUuid,
      external_id                as ExternalId,
      channel                    as Channel,
      channel_type               as ChannelType,
      country_code               as CountryCode,
      integration_correlation_id as IntegrationCorrelationId,
      comm_status                as CommStatus,
      comm_log_id                as CommLogId,
      current_step               as CurrentStep,
      current_step_status        as CurrentStepStatus,
      current_step_proccessed_at as CurrentStepProccessedAt,
      email_id                   as EmailId,
      email_sender_addr          as EmailSenderAddr,
      email_subject              as EmailSubject,
      email_sent_at              as EmailSentAt,
      email_received_at          as EmailReceivedAt,
      vendor_number              as VendorNumber,
      invoice_reference          as InvoiceReference,
      local_created_by           as LocalCreatedBy,
      local_created_at           as LocalCreatedAt,
      local_last_changed_by      as LocalLastChangedBy,
      local_last_changed_at      as LocalLastChangedAt,
      last_changed_at            as LastChangedAt
}
