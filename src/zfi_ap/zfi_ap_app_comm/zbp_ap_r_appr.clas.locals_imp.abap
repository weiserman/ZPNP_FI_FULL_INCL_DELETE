class lhc_zap_i_appr_log definition inheriting from cl_abap_behavior_handler.

  private section.

    methods determine_onsave_status for determine on save
      importing keys for zap_i_appr_log~determine_onsave_status.

endclass.

class lhc_zap_i_appr_log implementation.

  method determine_onsave_status.

*Local Data
    data: lt_comm_update type table for update zap_r_comm.
    data: ld_hdr_status type zap_de_comm_status.

*Read entities
    read entities of zap_r_appr in local mode entity zap_i_appr_log all fields with corresponding #( keys ) result data(lt_logs).
    read entities of zap_r_appr in local mode entity zap_r_appr all fields with corresponding #( lt_logs ) result data(lt_approvals).

*Determine if the log contains any errors
    ld_hdr_status = zap_cl_ap_log_utilities=>determine_log_hdr_status( lt_logs ).

*Update Status based on log
    loop at lt_approvals assigning field-symbol(<ls_approval>).
      clear: lt_comm_update.

      <ls_approval>-Status = ld_hdr_status.

*update COMM_HEADER with progress
      lt_comm_update = value #( ( CommUuid          = <ls_approval>-parentuuid
                                  CurrentStepStatus = ld_hdr_status
                                  CurrentStep       = zap_if_constants=>step-approval
                                  %control = value #( CurrentStepStatus = if_abap_behv=>mk-on
                                                      CurrentStep       = if_abap_behv=>mk-on ) ) ).

      modify entities of zap_r_comm entity zap_r_comm
        update from lt_comm_update
        failed data(ls_failed)
        reported data(ls_reported).

    endloop.

*Modify communication header entity with new ExternalId
    modify entities of zap_r_appr in local mode entity zap_r_appr update fields ( Status ) with corresponding #( lt_approvals ).

  endmethod.

endclass.

class lhc_ZAP_R_APPR definition inheriting from cl_abap_behavior_handler.
  private section.

    methods get_instance_authorizations for instance authorization
      importing keys request requested_authorizations for zap_r_appr result result.

    methods get_global_authorizations for global authorization
      importing request requested_authorizations for zap_r_appr result result.
    methods determine_onsave_externalid for determine on save
      importing keys for zap_r_appr~determine_onsave_externalid.
    methods determine_onsave_validate for determine on save
      importing keys for zap_r_appr~determine_onsave_validate.
    methods sharepointapprcreateresp for modify
      importing keys for action zap_r_appr~sharepointapprcreateresp result result.

endclass.

class lhc_ZAP_R_APPR implementation.

  method get_instance_authorizations.
  endmethod.

  method get_global_authorizations.
  endmethod.



  method determine_onsave_externalid.

*Local data
    data: ld_number     type cl_numberrange_runtime=>nr_number,
          ld_returncode type cl_numberrange_runtime=>nr_returncode.

*Read communication header entity
    read entities of zap_r_appr in local mode entity zap_r_appr all fields with corresponding #( keys ) result data(lt_approvals).

*Iterate through entity and assign ExternalId
    loop at lt_approvals assigning field-symbol(<ls_approval>).
      clear: ld_number, ld_returncode.

      try.
          cl_numberrange_runtime=>number_get( exporting nr_range_nr = zap_if_constants=>number_range-approval_external_nr_range_nr
                                                        object      = zap_if_constants=>number_range-approval_external_id_object
                                              importing number     = ld_number
                                                        returncode = ld_returncode ).

          if ld_returncode = space.
            <ls_approval>-externalid = |{ ld_number alpha = out }|.
          endif.

        catch cx_number_ranges.
      endtry.

    endloop.

*Modify communication header entity with new ExternalId
    modify entities of zap_r_appr in local mode entity zap_r_appr update fields ( ExternalId ) with corresponding #( lt_approvals ).

  endmethod.

  method determine_onsave_validate.

*Local data
    data: lt_appr_log type table for create zap_r_appr\_Logs.
    data: ld_msg_dum type bapi_msg.

*Read communication header entity
    read entities of zap_r_appr in local mode entity zap_r_appr all fields with corresponding #( keys ) result data(lt_approvals).

*Iterate through entity and validate elements
    loop at lt_approvals into data(ls_approval).

*.external id validation
      if ls_approval-externalid is initial.
        message e501(zap) into ld_msg_dum. "External Id Failed To Generate.

        lt_appr_log = value #( base lt_appr_log ( approvaluuid = ls_approval-approvaluuid
                                                   %target = value #( ( %cid     = |COMM_LOG_HDR_2{ sy-index }|
                                                                    approvaluuid = ls_approval-approvaluuid
                                                                   MessageNumber = sy-msgno
                                                                 DetailedMessage = ld_msg_dum
                                                                        %control = value #( MessageNumber   = if_abap_behv=>mk-on
                                                                                            DetailedMessage = if_abap_behv=>mk-on ) ) ) ) ).
      endif.

    endloop.

*Save log entries
    if lt_appr_log is not initial.
      modify entities of zap_r_appr in local mode entity zap_r_appr create by \_Logs from corresponding #( lt_appr_log ).
    endif.

  endmethod.

  METHOD SharepointApprCreateResp.
  ENDMETHOD.

endclass.

class lsc_ZAP_R_APPR definition inheriting from cl_abap_behavior_saver.
  protected section.

    methods save_modified redefinition.

    methods cleanup_finalize redefinition.

endclass.

class lsc_ZAP_R_APPR implementation.

  method save_modified.

*Local data
    data: lt_appr_hist type standard table of zap_a_appr_hist.
    data: ls_appr_hist type zap_a_appr_hist.

*Check for any changes, if there are then write it to a logging table
    loop at create-zap_r_appr into data(ls_create_appr).
      clear: ls_appr_hist.

      move-corresponding ls_create_appr to ls_appr_hist.
      ls_appr_hist-approval_hist_uuid = zca_cl_abap_utilities=>get_uuid_x16( ).

      append ls_appr_hist to lt_appr_hist.
    endloop.

    loop at update-zap_r_appr into data(ls_update_appr).
      clear: ls_appr_hist.

      move-corresponding ls_update_appr to ls_appr_hist.
      ls_appr_hist-approval_hist_uuid = zca_cl_abap_utilities=>get_uuid_x16( ).

      append ls_appr_hist to lt_appr_hist.
    endloop.

*Save the changes
    if lt_appr_hist is not initial.
      insert zap_a_appr_hist from table @lt_appr_hist.
    endif.

  endmethod.

  method cleanup_finalize.
  endmethod.

endclass.
