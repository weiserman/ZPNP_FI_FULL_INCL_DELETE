@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BFPF Log Root View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZAP_R_BGPFL
  as select from zap_a_bgpfl

{
  key log_uuid              as LogUuid,
      comm_uuid             as CommUuid,
      current_step          as CurrentStep,
      current_step_status   as CurrentStepStatus,
      ocr_uuid              as OcrUuid,
      @Semantics.user.createdBy: true
      local_created_by      as LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      local_created_at      as LocalCreatedAt,
      @Semantics.user.lastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt
}
