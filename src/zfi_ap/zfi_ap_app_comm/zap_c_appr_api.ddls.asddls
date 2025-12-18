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
      SharepointApprovalStatus,
      SharepointApprovalId,
      SharepointApproverName,
      SharepointApproverEmail,
      
      /* Associations */
      _Logs : redirected to composition child ZAP_C_APPR_LOG_API
}
