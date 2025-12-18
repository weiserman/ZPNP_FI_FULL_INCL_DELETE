@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Communication Header Interface View'
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #COMPOSITE
@ObjectModel.usageType:{
    serviceQuality: #A,
    sizeCategory: #L,
    dataClass: #MIXED
}
define view entity ZAP_I_COMM
  as select from ZAP_B_COMM

  association [0..1] to I_User as _CreatedUser on $projection.LocalCreatedBy = _CreatedUser.UserID
  association [0..1] to I_User as _ChangedUser on $projection.LocalCreatedBy = _ChangedUser.UserID
{
  key CommUuid,
      ExternalId,
      Channel,
      ChannelType,
      CountryCode,
      IntegrationCorrelationId,
      CommStatus,
      CommLogId,
      CurrentStep,
      CurrentStepStatus,
      CurrentStepProccessedAt,
      EmailId,
      EmailSenderAddr,
      EmailSubject,
      EmailSentAt,
      EmailReceivedAt,
      VendorNumber,
      InvoiceReference,
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,

      _CreatedUser.UserDescription as LocalCreatedByUserName,
      _ChangedUser.UserDescription as LocalLastChangedByUserName

}
