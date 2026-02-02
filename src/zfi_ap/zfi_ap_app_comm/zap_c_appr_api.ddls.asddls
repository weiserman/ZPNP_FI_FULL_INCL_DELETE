@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Approvals'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZAP_C_APPR_API
  provider contract transactional_query
  as projection on ZAP_R_APPR
{
  key ApprovalUuid,
      ParentUuid,
      ExternalId,
      Status,
      SharepointId,
      ResponseStatus,
      ResponseMessageNumber,
      ResponseMessage,
      ResponseTimestamp,
      ApproverName,
      ApproverEmail,
      ApprLogId,
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,
      
      /* Associations */
      _Logs : redirected to composition child ZAP_C_APPR_LOG_API
}
