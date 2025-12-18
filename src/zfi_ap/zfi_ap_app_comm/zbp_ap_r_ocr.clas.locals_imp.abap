class lsc_zap_r_ocr definition inheriting from cl_abap_behavior_saver.

  protected section.

    methods save_modified redefinition.

endclass.

class lsc_zap_r_ocr implementation.

  method save_modified.

*Local Data
    data: lr_zfi_cx type ref to zfi_cx.

*Validate that there is content to process
    if create-zap_r_ocr is initial and
       update-zap_r_ocr is initial and
       delete-zap_r_ocr is initial.
      return.
    endif.

*Process CREATED modifications
*.register background processing framework (bgPF) operations
    loop at create-zap_r_ocr into data(ls_created_ocr) where %control-status eq cl_abap_behv=>flag_changed.

      try.

          if ls_created_ocr-status eq zap_if_constants=>system_status-in_progress.
            zap_cl_bgpf_utilities=>register_operation( is_register_parameters = value #( comm_uuid           = ls_created_ocr-parentuuid
                                                                                         current_step        = zap_if_constants=>step-ocr_invoice
                                                                                         current_step_status = ls_created_ocr-status
                                                                                         ocr_uuid            = ls_created_ocr-ocruuid ) ).
          endif.

        catch zfi_cx into lr_zfi_cx.
*            message x204(zap_comm).
      endtry.

    endloop.

*Process UPDATED modifications
*.register background processing framework (bgPF) operations
    loop at update-zap_r_ocr into data(ls_updated_ocr) where %control-status eq cl_abap_behv=>flag_changed.

      try.

          if ls_updated_ocr-status eq zap_if_constants=>system_status-success.
            zap_cl_bgpf_utilities=>register_operation( is_register_parameters = value #( comm_uuid           = ls_updated_ocr-parentuuid
                                                                                         current_step        = zap_if_constants=>step-ocr_invoice
                                                                                         current_step_status = ls_updated_ocr-status
                                                                                         ocr_uuid            = ls_updated_ocr-ocruuid ) ).
          endif.

        catch zfi_cx into lr_zfi_cx.
          append value #( %key = ls_updated_ocr-%key ) to reported-zap_r_ocr.
          append value #( %key = ls_updated_ocr-%key
                          %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                        text     = 'Error Registering bgPF Operation: ' && lr_zfi_cx->get_text(  )  ) ) to reported-zap_r_ocr.
      endtry.

    endloop.

  endmethod.

endclass.

class lhc_zap_i_ocr_log definition inheriting from cl_abap_behavior_handler.

  private section.

    methods determine_onsave_status for determine on save
      importing keys for zap_i_ocr_log~determine_onsave_status.

endclass.

class lhc_zap_i_ocr_log implementation.

  method determine_onsave_status.

*Local Data
    data: lt_comm_update type table for update zap_r_comm.
    data: ld_hdr_status type zap_de_comm_status.

*Read entities
    read entities of zap_r_ocr in local mode entity zap_i_ocr_log all fields with corresponding #( keys ) result data(lt_logs).
    read entities of zap_r_ocr in local mode entity zap_r_ocr all fields with corresponding #( lt_logs ) result data(lt_ocr).

*Determine if the log contains any errors
    ld_hdr_status = zap_cl_ap_log_utilities=>determine_log_hdr_status( lt_logs ).

*Update Status based on log
    loop at lt_ocr assigning field-symbol(<ls_ocr>).
      clear: lt_comm_update.

      <ls_ocr>-Status = ld_hdr_status.

*.update COMM_HEADER with progress
      lt_comm_update = value #( ( CommUuid          = <ls_ocr>-parentuuid
                                  CurrentStepStatus = ld_hdr_status
                                  CurrentStep       = zap_if_constants=>step-ocr_invoice
                                  %control = value #( CurrentStepStatus = if_abap_behv=>mk-on
                                                      CurrentStep       = if_abap_behv=>mk-on ) ) ).

      modify entities of zap_r_comm entity zap_r_comm
        update from lt_comm_update
        failed data(ls_failed)
        reported data(ls_reported).

    endloop.

*Modify communication header entity with new ExternalId
    modify entities of zap_r_ocr in local mode entity zap_r_ocr update fields ( Status ) with corresponding #( lt_ocr ).

  endmethod.

endclass.

class lhc_zap_r_ocr definition inheriting from cl_abap_behavior_handler.
  private section.

    methods get_instance_authorizations for instance authorization
      importing keys request requested_authorizations for zap_r_ocr result result.

    methods get_global_authorizations for global authorization
      importing request requested_authorizations for zap_r_ocr result result.

endclass.

class lhc_ZAP_R_OCR implementation.

  method get_instance_authorizations.
  endmethod.

  method get_global_authorizations.
  endmethod.

endclass.
