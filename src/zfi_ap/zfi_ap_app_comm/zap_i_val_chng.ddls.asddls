@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Validation Changes Interface View'
@VDM.viewType: #COMPOSITE
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #A,
    sizeCategory: #L,
    dataClass: #MIXED
}
define view entity zap_i_val_chng as select from zap_a_val_chng
  association [0..1] to I_User as _CreatedUser on $projection.CreatedBy = _CreatedUser.UserID
{
    key log_uuid as LogUuid,
    val_uuid as ValUuid,
    changing_operation as ChangingOperation,
    changed_field_name as ChangedFieldName,
    changed_field_descr as ChangedFieldDescr,
    changed_value as ChangedValue,
    created_at as CreatedAt,
    @ObjectModel.text.element: [ 'CreatedByUserName' ]   
    created_by as CreatedBy,
    _CreatedUser.UserDescription as CreatedByUserName
}
