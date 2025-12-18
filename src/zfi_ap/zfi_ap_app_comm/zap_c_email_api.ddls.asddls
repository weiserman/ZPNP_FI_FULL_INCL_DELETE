@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Email'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZAP_C_EMAIL_API
  provider contract transactional_query
  as projection on ZAP_R_COMM
{
  key CommUuid,
      Channel,
      ChannelType,
      CountryCode,
      IntegrationCorrelationId,
      EmailId,
      EmailSenderAddr,
      EmailSubject,
      EmailSentAt,
      EmailReceivedAt,

      /* Associations */
      _Attachments : redirected to composition child ZAP_C_EMAIL_ATTACH_API,
      _Logs        : redirected to composition child ZAP_C_EMAIL_LOG_API
}
