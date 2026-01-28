@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Communication UI Projection View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZAP_C_COMM_UI
  provider contract transactional_query
  as projection on ZAP_R_COMM

{
  key CommUuid,
      ExternalId,
      Channel,
      ChannelType,
      CountryCode,
      IntegrationCorrelationId,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZAP_I_STATUS_VH', element: 'Status' } } ]
      @ObjectModel.text.element: ['CommStatus_Description']
      CommStatus,
      CommLogId,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZAP_I_STEP_VH', element: 'Step' } } ]
      @ObjectModel.text.element: ['CurrentStep_Description']
      CurrentStep,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZAP_I_STATUS_VH', element: 'Status' } } ]
      @ObjectModel.text.element: ['CurrentStepStatus_Description']
      CurrentStepStatus,
      CurrentStepProccessedAt,
      EmailId,
      EmailSenderAddr,
      EmailSubject,
      EmailSentAt,
      EmailReceivedAt,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZFI_I_VEND_VH', element: 'VendorNumber' } } ]
      VendorNumber,
      InvoiceReference,
      @ObjectModel.text.element: [ 'LocalCreatedByUserName' ]
      LocalCreatedBy,
      @Consumption.filter: { selectionType: #INTERVAL, multipleSelections: false }
      LocalCreatedAt,
      @ObjectModel.text.element: [ 'LocalLastChangedByUserName' ]
      LocalLastChangedBy,
      @Consumption.filter: { selectionType: #INTERVAL, multipleSelections: false }
      LocalLastChangedAt,

      /* Technical */
      @UI.hidden: true
      _CreatedUser.UserDescription            as LocalCreatedByUserName,
      @UI.hidden: true
      _ChangedUser.UserDescription            as LocalLastChangedByUserName,
      @UI.hidden: true
      LastChangedAt,

      _CommStatusMsgConfig.Message            as CommStatus_Description,
      _CommStatusMsgConfig.Criticality        as CommStatus_Criticality,
      _CurrentStepStatusMsgConfig.Message     as CurrentStepStatus_Description,
      _CurrentStepStatusMsgConfig.Criticality as CurrentStepStatus_Criticality,
      _CurrentStepVH.Description              as CurrentStep_Description,


      /* Associations */
      _Attachments : redirected to composition child ZAP_C_COMM_ATTACH_UI,
      _Logs        : redirected to composition child ZAP_C_COMM_LOG_UI,
      _OCR,
      _Val,
      _Appr
}
