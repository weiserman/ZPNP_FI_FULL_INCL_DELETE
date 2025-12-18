class zap_cl_load_search_help_data definition
  public
  final
  create public .

  public section.
    interfaces if_oo_adt_classrun.
  protected section.
  private section.
endclass.



class zap_cl_load_search_help_data implementation.

  method if_oo_adt_classrun~main.

**Local data
*    data: lt_status_vh  type standard table of zap_a_status,
*          lt_step_vh    type standard table of zap_a_step,
*          lt_channel_vh type standard table of zap_a_channel.
*
**Clear out tables
*    delete from zap_a_status.
*    delete from zap_a_step.
*    delete from zap_a_channel.
*
**Load search help values
**.status
*    lt_status_vh = value #( ( status = zap_if_constants=>system_status-success     description = 'Success'     local_created_by = sy-uname local_created_at = zca_cl_abap_utilities=>get_utc_timestamplong( ) )
*                            ( status = zap_if_constants=>system_status-in_progress description = 'In Progress' local_created_by = sy-uname local_created_at = zca_cl_abap_utilities=>get_utc_timestamplong( ) )
*                            ( status = zap_if_constants=>system_status-warning     description = 'Warning'     local_created_by = sy-uname local_created_at = zca_cl_abap_utilities=>get_utc_timestamplong( ) )
*                            ( status = zap_if_constants=>system_status-error       description = 'Error'       local_created_by = sy-uname local_created_at = zca_cl_abap_utilities=>get_utc_timestamplong( ) )
*                            ( status = zap_if_constants=>system_status-rejected    description = 'Rejected'    local_created_by = sy-uname local_created_at = zca_cl_abap_utilities=>get_utc_timestamplong( ) )
*                            ( status = zap_if_constants=>system_status-completed   description = 'Completed'   local_created_by = sy-uname local_created_at = zca_cl_abap_utilities=>get_utc_timestamplong( ) ) ).
*
*    insert zap_a_status from table @lt_status_vh.
*
**.step
*    lt_step_vh = value #( ( step = zap_if_constants=>step-email_ingestion description = 'Email Ingestion' local_created_by = sy-uname local_created_at = zca_cl_abap_utilities=>get_utc_timestamplong( ) )
*                          ( step = zap_if_constants=>step-ocr_invoice     description = 'OCR Invoice'     local_created_by = sy-uname local_created_at = zca_cl_abap_utilities=>get_utc_timestamplong( ) )
*                          ( step = zap_if_constants=>step-validation      description = 'Validation'      local_created_by = sy-uname local_created_at = zca_cl_abap_utilities=>get_utc_timestamplong( ) ) ).
*
*    insert zap_a_step from table @lt_step_vh.
*
**.channel
*    lt_channel_vh = value #( ( channel = zap_if_constants=>comm_channel-email description = 'Email' local_created_by = sy-uname local_created_at = zca_cl_abap_utilities=>get_utc_timestamplong( ) ) ).
*
*    insert zap_a_channel from table @lt_channel_vh.
*
*    commit work and wait.

  endmethod.
endclass.
