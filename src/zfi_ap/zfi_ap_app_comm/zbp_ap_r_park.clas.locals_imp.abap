class lhc_zap_i_park_log definition inheriting from cl_abap_behavior_handler.

  private section.

    methods determine_onsave_status for determine on save
      importing keys for zap_i_park_log~determine_onsave_status.

endclass.

class lhc_zap_i_park_log implementation.

  method determine_onsave_status.

    data: lt_comm_update type table for update zap_r_comm.
    data: ld_hdr_status type zap_de_comm_status.

*Read entities
    read entities of zap_r_park in local mode entity zap_i_park_log all fields with corresponding #( keys ) result data(lt_logs).
    read entities of zap_r_park in local mode entity zap_r_park all fields with corresponding #( lt_logs ) result data(lt_park).

*Determine if the log contains any errors
    ld_hdr_status = zap_cl_ap_log_utilities=>determine_log_hdr_status( lt_logs ).

*Update Status based on log
    loop at lt_park assigning field-symbol(<ls_park>).
      clear: lt_comm_update.

      <ls_park>-Status = ld_hdr_status.

*update COMM_HEADER with progress
      lt_comm_update = value #( ( CommUuid          = <ls_park>-parentuuid
                                  CurrentStepStatus = ld_hdr_status
                                  CurrentStep       = zap_if_constants=>step-parking
                                  %control = value #( CurrentStepStatus = if_abap_behv=>mk-on
                                                      CurrentStep       = if_abap_behv=>mk-on ) ) ).

      modify entities of zap_r_comm entity zap_r_comm
        update from lt_comm_update
        failed data(ls_failed)
        reported data(ls_reported).

    endloop.

*Modify communication header entity with new ExternalId
    modify entities of zap_r_park in local mode entity zap_r_park update fields ( Status ) with corresponding #( lt_park ).

  endmethod.


endclass.

class lhc_ZAP_R_PARK definition inheriting from cl_abap_behavior_handler.
  private section.

    methods get_instance_authorizations for instance authorization
      importing keys request requested_authorizations for zap_r_park result result.

    methods get_global_authorizations for global authorization
      importing request requested_authorizations for zap_r_park result result.
    methods checkstatus for modify
      importing keys for action zap_r_park~checkstatus result result.

endclass.

class lhc_ZAP_R_PARK implementation.

  method get_instance_authorizations.
  endmethod.

  method get_global_authorizations.
  endmethod.

  METHOD CheckStatus.

**Check the current status against the status in ECC
*
**Validate the Data
    data: ld_severity           type IF_ABAP_BEHV_MESSAGE=>T_SEVERITY,
*          ld_criticality        type zca_de_ui_criticality,
          lt_park_create_log     type table for create zap_r_park\_Logs,
          ls_ecc_status          type zap_cl_ap_park=>ty_ecc_status,
          lt_new_park_logs       type zap_cl_ap_park=>ty_tt_park_logs.
*
**Read entities required
    read entities of zap_r_park in local mode entity zap_r_park      all fields with corresponding #( keys )   result data(lt_park_headers).

*Do the ECC status
    zap_cl_ap_park=>ecc_check_status( exporting it_park_head  = lt_park_headers
                                       changing ct_park_logs  = lt_new_park_logs
                                                cs_ecc_status = ls_ecc_status ).
*
**Determine if the new logs would result in a successful or rejected status
*    data(ld_hdr_status) = zap_cl_ap_log_utilities=>determine_log_hdr_status( lt_new_val_logs ).
*
*
*
*  if ld_hdr_status = zap_if_constants=>system_status-rejected
*  or ld_hdr_status = zap_if_constants=>system_status-success.
*    loop at lt_val_headers assigning field-symbol(<ls_val_header>).   "Should be one only
*
**Update the header with the determined fields.
**      move-corresponding  ls_ecc_determinations to  <ls_val_header>.
*      <ls_val_header>-VendorNumber = ls_ecc_determinations-vendor_number.
*      <ls_val_header>-PoCcode      = ls_ecc_determinations-po_ccode.
*      <ls_val_header>-PoType       = ls_ecc_determinations-po_type.
*      <ls_val_header>-CountryCode  = ls_ecc_determinations-country_code.
*
**Add the new logs to the existing ones.
*      lt_val_create_log = value #( for <ls_new_val_log> in lt_new_val_logs index into ld_index
*                                    ( ValUuid = <ls_val_header>-ValUuid
*                                       %target = value #( ( %cid            = |LOG{ ld_index }|
*                                                            ValUuid         = <ls_val_header>-ValUuid
*                                                            MessageNumber   =  <ls_new_val_log>-MessageNumber
*                                                            DetailedMessage =  <ls_new_val_log>-DetailedMessage
*                                                            %control = value #( ValUuid         = if_abap_behv=>mk-on
*                                                                                MessageNumber   = if_abap_behv=>mk-on
*                                                                                DetailedMessage = if_abap_behv=>mk-on  ) ) ) ) ).
*    endloop.
*    if lt_val_create_log is not initial.
*      modify entities of zap_r_val in local mode
*          entity zap_r_val
*          create by \_Logs from lt_val_create_log .
*    endif.
*
**Not sure if this will add a field change????
*    modify entities of zap_r_val in local mode entity zap_r_val update fields ( PoCcode PoType VendorNumber CountryCode ) with corresponding #( lt_val_headers ).
**
*
*  else.
*
**Pop up the new messages to the user
*    loop at lt_val_headers into data(ls_val_header).
*      loop at lt_new_val_logs into data(ls_new_val_log).
*
**Determine the severity from the criticality - and just show the message
*        ld_severity     = if_abap_behv_message=>severity-error.
*        select single criticality
*          from zap_i_msg_cfg
*          where MessageNumber = @ls_new_val_log-MessageNumber into @ld_criticality.
*        if sy-subrc ne 0
*        or ld_criticality = zap_if_constants=>criticality-red.
*          ld_severity     = if_abap_behv_message=>severity-error.
*        elseif ld_criticality = zap_if_constants=>criticality-yellow.
*          ld_severity     = if_abap_behv_message=>severity-warning.
*        elseif ld_criticality = zap_if_constants=>criticality-green.
*          ld_severity     = if_abap_behv_message=>severity-success.
*        endif.
*        append value #( %tky = ls_val_header-%tky
*                        %msg = new_message_with_text( severity = ld_severity
*                                                      text     = ls_new_val_log-detailedmessage ) ) to reported-zap_r_val.
*      endloop.
*    endloop.
*  endif.

  ENDMETHOD.

endclass.

class lsc_ZAP_R_PARK definition inheriting from cl_abap_behavior_saver.
  protected section.

    methods save_modified redefinition.

    methods cleanup_finalize redefinition.

endclass.

class lsc_ZAP_R_PARK implementation.

  method save_modified.

    data: lr_zfi_cx type ref to zfi_cx.

*Validate that there is content to process
    if create-zap_r_park is initial and
       update-zap_r_park is initial and
       delete-zap_r_park is initial.
      return.
    endif.

*Process CREATED modifications
*.register background processing framework (bgPF) operations
    loop at create-zap_r_park into data(ls_created_park) where %control-status eq cl_abap_behv=>flag_changed.

      try.

          if ls_created_park-status eq zap_if_constants=>system_status-success.
            zap_cl_bgpf_utilities=>register_operation( is_register_parameters = value #( comm_uuid           = ls_created_park-parentuuid
                                                                                         current_step        = zap_if_constants=>step-parking
                                                                                         current_step_status = ls_created_park-status
                                                                                         park_uuid            = ls_created_park-ParkUuid ) ).
          endif.

        catch zfi_cx into lr_zfi_cx.
*            message x204(zap_comm).
      endtry.
    endloop.

*Process UPDATED modifications
*.register background processing framework (bgPF) operations
    loop at update-zap_r_park into data(ls_updated_park) where %control-status eq cl_abap_behv=>flag_changed.

      try.

          if ls_updated_park-status eq zap_if_constants=>system_status-success.
            zap_cl_bgpf_utilities=>register_operation( is_register_parameters = value #( comm_uuid           = ls_updated_park-parentuuid
                                                                                         current_step        = zap_if_constants=>step-parking
                                                                                         current_step_status = ls_updated_park-status
                                                                                         park_uuid            = ls_updated_park-parkuuid ) ).
          endif.

        catch zfi_cx into lr_zfi_cx.
          append value #( %key = ls_updated_park-%key ) to reported-zap_r_park.
          append value #( %key = ls_updated_park-%key
                          %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                        text     = 'Error Registering bgPF Operation: ' && lr_zfi_cx->get_text(  )  ) ) to reported-zap_r_park.
      endtry.
    endloop.

  endmethod.

  method cleanup_finalize.
  endmethod.

endclass.
