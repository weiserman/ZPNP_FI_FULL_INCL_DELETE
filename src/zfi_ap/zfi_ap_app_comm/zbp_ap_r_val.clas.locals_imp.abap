
class lsc_zap_r_val definition inheriting from cl_abap_behavior_saver.

  protected section.
    methods save_modified redefinition.
*    methods CHECK_BEFORE_SAVE redefinition

endclass.

*class lhc_zap_i_val_item definition inheriting from cl_abap_behavior_handler.
*
*
*  private section.
*
**    methods determine_ecc_validation for determine on save
**      importing keys for zap_i_val_item~determine_ecc_validation.
*
*endclass.
class lsc_zap_r_val implementation.
  method save_modified.

    types ty_change type zap_a_val_chng.


    types: begin of ty_change_field,
             fieldname type zap_de_changed_field_name,
             descr     type zap_de_changed_field_descr,
           end of  ty_change_field.

    data: ls_change        type ty_change,
          lr_zfi_cx        type ref to zfi_cx,
          lt_change_fields type standard table of ty_change_field,
          lt_changes       type standard table of ty_change.

    get time stamp field ls_change-created_at.

*Determine the fields to add to the change logging.
*Headers
    if not ( update-zap_r_val is initial and create-zap_r_val is initial ).

*Build up the fields that we are wanting to add field changes to
      lt_change_fields = value #(  ( fieldname = 'ACKNOWLEDGEWARNING'  descr = text-001 )
                                   ( fieldname = 'INVOICEREFERENCE'    descr = text-002 )
                                   ( fieldname = 'INVOICEDATE'         descr = text-003 )
                                   ( fieldname = 'VENDORNAME'          descr = text-004 )
                                   ( fieldname = 'VENDORVATNUMBER'     descr = text-005 )
                                   ( fieldname = 'PNPVATNUMBER'        descr = text-006 )
                                   ( fieldname = 'TOTALVATINCLUSIVE'   descr = text-007 )
                                   ( fieldname = 'VATVALUE'            descr = text-008 )
                                   ( fieldname = 'PNPVATNUMBER'        descr = text-009 )
                                   ( fieldname = 'PURCHASEORDERNUMBER' descr = text-010 ) ).

      loop at create-zap_r_val into data(ls_zap_r_val).
        ls_change-changing_operation = 'I'.
        ls_change-created_by         = cl_abap_context_info=>get_user_technical_name( ).
        ls_change-val_uuid            = ls_zap_r_val-ValUuid.
        loop at lt_change_fields into data(ls_change_field).
          assign component ls_change_field-fieldname of structure ls_zap_r_val to field-symbol(<ld_val_field>).
          check sy-subrc eq 0.
          try.
              ls_change-log_uuid            = cl_system_uuid=>create_uuid_x16_static( ).
            catch cx_uuid_error.
              continue.
          endtry.
          ls_change-changed_value       = <ld_val_field>.
          ls_change-changed_field_name  = ls_change_field-fieldname.
          ls_change-changed_field_descr = ls_change_field-descr.
          append ls_change to  lt_changes.
        endloop.
      endloop.

      loop at update-zap_r_val into ls_zap_r_val.
        ls_change-changing_operation = 'U'.
        ls_change-created_by         = cl_abap_context_info=>get_user_technical_name( ).
        ls_change-val_uuid            = ls_zap_r_val-ValUuid.
        loop at lt_change_fields into ls_change_field.
          assign component ls_change_field-fieldname of structure ls_zap_r_val-%control to field-symbol(<ld_ctl_field>).
          check sy-subrc eq 0
          and <ld_ctl_field> = cl_abap_behv=>flag_changed.
          assign component ls_change_field-fieldname of structure ls_zap_r_val to <ld_val_field>.
          check sy-subrc eq 0.
          try.
              ls_change-log_uuid            = cl_system_uuid=>create_uuid_x16_static( ).
            catch cx_uuid_error.
              continue.
          endtry.
          ls_change-changed_value       = <ld_val_field>.
          ls_change-changed_field_name  = ls_change_field-fieldname.
          ls_change-changed_field_descr = ls_change_field-descr.
          append ls_change to  lt_changes.
        endloop.
      endloop.
    endif.

*Items
    if not ( update-zap_i_val_item is initial and  create-zap_i_val_item is initial ).
      clear lt_change_fields.
      lt_change_fields = value #(  ( fieldname = 'ITEMDESCRIPTION' descr = text-011 )
                                   ( fieldname = 'ITEMQUANTITY'    descr = text-012 )
                                   ( fieldname = 'ITEMNETTVALUE'   descr = text-013 ) ).
      loop at create-zap_i_val_item into data(ls_zap_i_val_item).
        ls_change-changing_operation = 'I'.
        ls_change-val_uuid            = ls_zap_i_val_item-ValUuid.
        data(ld_row) = sy-tabix.
        loop at lt_change_fields into ls_change_field.
          assign component ls_change_field-fieldname of structure ls_zap_i_val_item to <ld_val_field>.
          check sy-subrc eq 0.
          ls_change-changed_field_name  = |[{ ld_row }] { ls_change_field-fieldname }|.
          ls_change-changed_field_descr = ls_change_field-descr.
          try.
              ls_change-log_uuid            = cl_system_uuid=>create_uuid_x16_static( ).
            catch cx_uuid_error.
              continue.
          endtry.
          ls_change-changed_value       = <ld_val_field>.
          append ls_change to  lt_changes.
        endloop.
      endloop.

      loop at update-zap_i_val_item into ls_zap_i_val_item.
        ls_change-changing_operation = 'U'.
        ls_change-val_uuid            = ls_zap_i_val_item-ValUuid.
        ld_row = sy-tabix.
        loop at lt_change_fields into ls_change_field.
          assign component ls_change_field-fieldname of structure ls_zap_i_val_item-%control to <ld_ctl_field>.
          check sy-subrc eq 0
          and <ld_ctl_field> = cl_abap_behv=>flag_changed.
          ls_change-changed_field_name  = |[{ ld_row }] { ls_change_field-fieldname }|.
          ls_change-changed_field_descr = ls_change_field-descr.
          assign component ls_change_field-fieldname of structure ls_zap_i_val_item to <ld_val_field>.
          check sy-subrc eq 0.
          try.
              ls_change-log_uuid            = cl_system_uuid=>create_uuid_x16_static( ).
            catch cx_uuid_error.
              continue.
          endtry.
          ls_change-changed_value       = <ld_val_field>.

          append ls_change to  lt_changes.
        endloop.
      endloop.
    endif.

*Save the changes
    if lt_changes is not initial.
      insert zap_a_val_chng from table @lt_changes.
    endif.

*Trigger the next step on success

*.register background processing framework (bgPF) operations
    if create-zap_r_val is not initial.
      loop at create-zap_r_val into data(ls_created_val) where %control-status eq cl_abap_behv=>flag_changed.

        try.

            if ls_created_val-status eq zap_if_constants=>system_status-in_progress.
              zap_cl_bgpf_utilities=>register_operation( is_register_parameters = value #( comm_uuid           = ls_created_val-parentuuid
                                                                                           current_step        = zap_if_constants=>step-validation
                                                                                           current_step_status = ls_created_val-status
                                                                                           val_uuid            = ls_created_val-valuuid ) ).
            endif.

          catch zfi_cx into lr_zfi_cx.
*            message x204(zap_comm).
        endtry.

      endloop.
    endif.

*Move onto the new step if it is a create or change and the status is OK
    if update-zap_r_val is not initial.

      loop at update-zap_r_val into data(ls_updated_val) where %control-status eq cl_abap_behv=>flag_changed.

        try.

            if ls_updated_val-status eq zap_if_constants=>system_status-success.
              zap_cl_bgpf_utilities=>register_operation( is_register_parameters = value #( comm_uuid           = ls_updated_val-parentuuid
                                                                                           current_step        = zap_if_constants=>step-validation
                                                                                           current_step_status = ls_updated_val-status
                                                                                           val_uuid            = ls_updated_val-valuuid ) ).
            endif.

          catch zfi_cx into lr_zfi_cx.
            append value #( %key = ls_updated_val-%key ) to reported-zap_r_val.
            append value #( %key = ls_updated_val-%key
                            %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                          text     = 'Error Registering bgPF Operation: ' && lr_zfi_cx->get_text(  )  ) ) to reported-zap_r_val.
        endtry.
      endloop.

    elseif create-zap_r_val is not initial.

      loop at create-zap_r_val into data(ls_create_val) where %control-status eq cl_abap_behv=>flag_changed.

        try.

            if ls_create_val-status eq zap_if_constants=>system_status-success.
              zap_cl_bgpf_utilities=>register_operation( is_register_parameters = value #( comm_uuid           = ls_create_val-parentuuid
                                                                                           current_step        = zap_if_constants=>step-validation
                                                                                           current_step_status = ls_create_val-status
                                                                                           val_uuid            = ls_create_val-valuuid ) ).
            endif.

          catch zfi_cx into lr_zfi_cx.
            append value #( %key = ls_create_val-%key ) to reported-zap_r_val.
            append value #( %key = ls_create_val-%key
                            %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                          text     = 'Error Registering bgPF Operation: ' && lr_zfi_cx->get_text(  )  ) ) to reported-zap_r_val.
        endtry.
      endloop.
    endif.
    if create-zap_i_val_log is not initial.
      loop at create-zap_i_val_log into data(ls_created_log).
*
*********************New
        append value #( %key = ls_created_log-%key
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-information
                                                      text     = ls_created_log-DetailedMessage ) ) to reported-zap_i_val_log.
*
**************************
      endloop.
    endif.


  endmethod.
endclass.

class lhc_zap_i_val_log definition inheriting from cl_abap_behavior_handler.

  private section.

    methods determine_onsave_status for determine on save
      importing keys for zap_i_val_log~determine_onsave_status.

endclass.

class lhc_zap_i_val_log implementation.

  method determine_onsave_status.
    data: ld_hdr_status  type zap_de_comm_status,
          ld_ValLogId    type zap_de_log_id,
          lt_comm_update type table for update zap_r_comm.

*Read entities
    read entities of zap_r_val in local mode entity zap_i_val_log all fields with corresponding #( keys ) result data(lt_logs).
    read entities of zap_r_val in local mode entity zap_r_val     all fields with corresponding #( lt_logs ) result data(lt_val_headers).

*Determine if the log contains any errors
    ld_hdr_status = zap_cl_ap_log_utilities=>determine_log_hdr_status( lt_logs ).

*Update Status based on log
    loop at lt_val_headers assigning field-symbol(<ls_val_header>).
      <ls_val_header>-Status           = ld_hdr_status.
      <ls_val_header>-ValLogId       = <ls_val_header>-ValLogId  + 1.
      ld_ValLogId                    = <ls_val_header>-ValLogId.
      loop at lt_logs assigning field-symbol(<ls_log>) where %data-ValUuid = <ls_val_header>-ValUuid.
        <ls_log>-logid = <ls_val_header>-ValLogId.
      endloop.

      modify entities of zap_r_val in local mode
        entity zap_r_val
          update fields ( ValLogId Status )
             with value #( for head in lt_val_headers
                         ( %tky = head-%tky
                         ValLogId = ld_ValLogId
                         Status   = ld_hdr_status ) ).

*update COMM_HEADER with progress and vendor data
      lt_comm_update = value #( ( CommUuid          = <ls_val_header>-parentuuid
                                  CurrentStepStatus = ld_hdr_status
                                  CurrentStep       = zap_if_constants=>step-validation
                                  VendorNumber      = <ls_val_header>-VendorNumber
                                  PoCcode           = <ls_val_header>-PoCcode
                                  InvoiceReference  = <ls_val_header>-InvoiceReference
                                  %control = value #( CurrentStepStatus = if_abap_behv=>mk-on
                                                      VendorNumber      = if_abap_behv=>mk-on
                                                      PoCcode           = if_abap_behv=>mk-on
                                                      InvoiceReference  = if_abap_behv=>mk-on
                                                      CurrentStep       = if_abap_behv=>mk-on ) ) ).
      modify entities of zap_r_comm entity zap_r_comm
        update from lt_comm_update
        failed data(ls_failed)
        reported data(ls_reported).

    endloop.

*Modify communication log entity with new data
    modify entities of zap_r_val in local mode entity zap_i_val_log update fields ( LogId ) with corresponding #( lt_logs ).
  endmethod.

endclass.

class lhc_ZAP_R_VAL definition inheriting from cl_abap_behavior_handler.
  private section.

    methods get_instance_authorizations for instance authorization
      importing keys request requested_authorizations for zap_r_val result result.

    methods get_global_authorizations for global authorization
      importing request requested_authorizations for zap_r_val result result.
*    methods do_createdetermination for determine on modify
*      importing keys for zap_r_val~do_createdetermination.
*    methods do_updatedetermination for determine on modify
*      importing keys for zap_r_val~do_updatedetermination.
    methods do_savedetermination for determine on save
      importing keys for zap_r_val~do_savedetermination.
    methods get_instance_features for instance features
      importing keys request requested_features for zap_r_val result result.
    methods rejectionpopup for modify
      importing keys for action zap_r_val~rejectionpopup.
    methods reviewpopup for modify
      importing keys for action zap_r_val~reviewpopup.
    methods validatedata for modify
      importing keys for action zap_r_val~validatedata result result.
*    methods validatedata for modify
*      importing keys for action zap_r_val~validatedata result result.

endclass.

class lhc_ZAP_R_VAL implementation.

  method get_instance_authorizations.
  endmethod.

  method get_global_authorizations.
  endmethod.

*  method do_updatedetermination.
*    data: lt_val_create_log     type table for create zap_r_val\_Logs,
*          ls_ecc_determinations type zap_cl_ap_validation=>ty_ecc_determinations,
*          lt_new_val_logs       type zap_cl_ap_validation=>ty_tt_val_logs.
*
**Read entities up from from the logs
*    read entities of zap_r_val in local mode entity zap_r_val      all fields with corresponding #( keys )   result data(lt_val_headers).
**    read entities of zap_r_val in local mode entity zap_i_val_log  all fields with corresponding #( lt_val )  result data(lt_logs).
*    read entities of zap_r_val in local mode entity zap_r_val by \_Items all fields with corresponding #( lt_val_headers ) result data(lt_items).
*
*
*    zap_cl_ap_validation=>rap_validations( exporting it_val_head  = lt_val_headers
*                                                     it_val_items = lt_items
*                                           changing  ct_val_logs  = lt_new_val_logs ).
*
**Do the ECC Validations and determine the PO values that are needed in RAP
*    zap_cl_ap_validation=>ecc_validations( exporting it_val_head           = lt_val_headers
*                                                     it_val_items          = lt_items
*                                           changing  ct_val_logs           = lt_new_val_logs
*                                                     cs_ecc_determinations = ls_ecc_determinations ).
*
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
*      lt_val_create_log = value #( for ls_new_val_log in lt_new_val_logs index into ld_index
*                                    ( ValUuid = <ls_val_header>-ValUuid
*                                       %target = value #( ( %cid            = |LOG{ ld_index }|
*                                                            ValUuid         = <ls_val_header>-ValUuid
*                                                            MessageNumber   =  ls_new_val_log-MessageNumber
*                                                            DetailedMessage =  ls_new_val_log-DetailedMessage
*                                                            %control = value #( ValUuid         = if_abap_behv=>mk-on
*                                                                                MessageNumber   = if_abap_behv=>mk-on
*                                                                                DetailedMessage = if_abap_behv=>mk-on  ) ) ) ) ).
*    endloop.
*    if lt_val_create_log is not initial.
*      modify entities of zap_r_val in local mode
*          entity zap_r_val
*          create by \_Logs from lt_val_create_log .
*    endif.
*    modify entities of zap_r_val in local mode entity zap_r_val update fields ( PoCcode PoType VendorNumber CountryCode ) with corresponding #( lt_val_headers ).
*  endmethod.


  method do_savedetermination.

    data: lt_val_create_log     type table for create zap_r_val\_Logs,
          ls_ecc_determinations type zap_cl_ap_validation=>ty_ecc_determinations,
          lt_new_val_logs       type zap_cl_ap_validation=>ty_tt_val_logs.

*Read entities required
    read entities of zap_r_val in local mode entity zap_r_val      all fields with corresponding #( keys )   result data(lt_val_headers).
*    read entities of zap_r_val in local mode entity zap_i_val_log  all fields with corresponding #( lt_val )  result data(lt_logs).
    read entities of zap_r_val in local mode entity zap_r_val by \_Items all fields with corresponding #( lt_val_headers ) result data(lt_items).

    zap_cl_ap_validation=>rap_validations( exporting it_val_head  = lt_val_headers
                                                     it_val_items = lt_items
                                           changing  ct_val_logs  = lt_new_val_logs ).

*Do the ECC Validations and determine the PO values that are needed in RAP
    zap_cl_ap_validation=>ecc_validations( exporting it_val_head           = lt_val_headers
                                                     it_val_items          = lt_items
                                           changing  ct_val_logs           = lt_new_val_logs
                                                     cs_ecc_determinations = ls_ecc_determinations ).

    loop at lt_val_headers assigning field-symbol(<ls_val_header>).   "Should be one only

*Update the header with the determined fields.
*      move-corresponding  ls_ecc_determinations to  <ls_val_header>.
      <ls_val_header>-VendorNumber = ls_ecc_determinations-vendor_number.
      <ls_val_header>-PoCcode      = ls_ecc_determinations-po_ccode.
      <ls_val_header>-PoType       = ls_ecc_determinations-po_type.
      <ls_val_header>-CountryCode  = ls_ecc_determinations-country_code.

*Add the new logs to the existing ones.
      lt_val_create_log = value #( for ls_new_val_log in lt_new_val_logs index into ld_index
                                    ( ValUuid = <ls_val_header>-ValUuid
                                       %target = value #( ( %cid            = |LOG{ ld_index }|
                                                            ValUuid         = <ls_val_header>-ValUuid
                                                            MessageNumber   =  ls_new_val_log-MessageNumber
                                                            DetailedMessage =  ls_new_val_log-DetailedMessage
                                                            %control = value #( ValUuid         = if_abap_behv=>mk-on
                                                                                MessageNumber   = if_abap_behv=>mk-on
                                                                                DetailedMessage = if_abap_behv=>mk-on  ) ) ) ) ).
    endloop.
    if lt_val_create_log is not initial.
      modify entities of zap_r_val in local mode
          entity zap_r_val
          create by \_Logs from lt_val_create_log .
    endif.
    modify entities of zap_r_val in local mode entity zap_r_val update fields ( PoCcode PoType VendorNumber CountryCode ) with corresponding #( lt_val_headers ).

  endmethod.

  method get_instance_features.
    read entities of zap_r_val in local mode
      entity zap_r_val
      fields ( Status  )
      with corresponding #( keys )
      result data(lt_val).

    result = value #(  for ls_val in lt_val (  %key                             = ls_val-%key
                                               %features-%action-RejectionPopup = cond #( when ls_val-Status = zap_if_constants=>system_status-error then if_abap_behv=>fc-o-enabled else if_abap_behv=>fc-o-disabled )
                                               %features-%action-Edit           = cond #( when ls_val-Status = zap_if_constants=>system_status-error then if_abap_behv=>fc-o-enabled else if_abap_behv=>fc-o-disabled )
                                               %update                          = cond #( when ls_val-Status = zap_if_constants=>system_status-error then if_abap_behv=>fc-o-enabled else if_abap_behv=>fc-o-disabled )
                                               %features-%action-validateData   = cond #( when ls_val-Status = zap_if_constants=>system_status-error then if_abap_behv=>fc-o-enabled else if_abap_behv=>fc-o-disabled )
                                               ) ).


  endmethod.

  method RejectionPopup.
    data: ls_msg_config     type zap_i_msg_cfg,
          lt_val_create_log type table for create zap_r_val\_Logs.

*Red the validation header
   read entities of zap_r_val in local mode entity zap_r_val all fields with corresponding #( keys ) result data(lt_val_head).


*    loop at keys into data(ls_key).         "Should be only one
*      data(ld_index) = sy-tabix.
*
**   Determine the message description
*      if ls_key-%param-rejection_number is not initial.
*         select single *
*            from zap_i_msg_cfg
*            where MessageNumber = @ls_key-%param-rejection_number into @ls_msg_config.
*            if sy-subrc ne 0.
*              continue.
*            endif.
*      endif.
*
*      lt_val_create_log =  value #( base lt_val_create_log for ls_val_head in lt_val_head using key entity    " index into ld_index
*                                                                   where ( %key-ValUuid = ls_key-ValUuid )
*                                                                         ( ValUuid = ls_val_head-ValUuid
*                                                                           %target = value #( ( %cid            = |LOG{ ld_index }|
*                                                                                                ValUuid         = ls_val_head-ValUuid
*                                                                                                MessageNumber   =  ls_msg_config-MessageNumber
*                                                                                                DetailedMessage =  ls_msg_config-Message
*                                                                                                %control = value #( ValUuid         = if_abap_behv=>mk-on
*                                                                                                                    MessageNumber   = if_abap_behv=>mk-on
*                                                                                                                    DetailedMessage = if_abap_behv=>mk-on  ) ) ) ) ).
*    endloop.
*    modify entities of zap_r_val in local mode entity zap_r_val create by \_Logs from corresponding #( lt_val_create_log ).

  endmethod.

  METHOD ReviewPopup.
  if 1 = 2. endif.
  ENDMETHOD.

  METHOD validateData.

*Validate the Data
    data: ld_severity           type IF_ABAP_BEHV_MESSAGE=>T_SEVERITY,
          ld_criticality        type zca_de_ui_criticality,
          lt_val_create_log     type table for create zap_r_val\_Logs,
          ls_ecc_determinations type zap_cl_ap_validation=>ty_ecc_determinations,
          lt_new_val_logs       type zap_cl_ap_validation=>ty_tt_val_logs.

*Read entities required
    read entities of zap_r_val in local mode entity zap_r_val      all fields with corresponding #( keys )   result data(lt_val_headers).
    read entities of zap_r_val in local mode entity zap_r_val by \_Items all fields with corresponding #( lt_val_headers ) result data(lt_items).

    zap_cl_ap_validation=>rap_validations( exporting it_val_head  = lt_val_headers
                                                     it_val_items = lt_items
                                           changing  ct_val_logs  = lt_new_val_logs ).

*Do the ECC Validations and determine the PO values that are needed in RAP
    zap_cl_ap_validation=>ecc_validations( exporting it_val_head           = lt_val_headers
                                                     it_val_items          = lt_items
                                           changing  ct_val_logs           = lt_new_val_logs
                                                     cs_ecc_determinations = ls_ecc_determinations ).

*Determine if the new logs would result in a successful or rejected status
    data(ld_hdr_status) = zap_cl_ap_log_utilities=>determine_log_hdr_status( lt_new_val_logs ).



  if ld_hdr_status = zap_if_constants=>system_status-rejected
  or ld_hdr_status = zap_if_constants=>system_status-success.
    loop at lt_val_headers assigning field-symbol(<ls_val_header>).   "Should be one only

*Update the header with the determined fields.
*      move-corresponding  ls_ecc_determinations to  <ls_val_header>.
      <ls_val_header>-VendorNumber = ls_ecc_determinations-vendor_number.
      <ls_val_header>-PoCcode      = ls_ecc_determinations-po_ccode.
      <ls_val_header>-PoType       = ls_ecc_determinations-po_type.
      <ls_val_header>-CountryCode  = ls_ecc_determinations-country_code.

*Add the new logs to the existing ones.
      lt_val_create_log = value #( for <ls_new_val_log> in lt_new_val_logs index into ld_index
                                    ( ValUuid = <ls_val_header>-ValUuid
                                       %target = value #( ( %cid            = |LOG{ ld_index }|
                                                            ValUuid         = <ls_val_header>-ValUuid
                                                            MessageNumber   =  <ls_new_val_log>-MessageNumber
                                                            DetailedMessage =  <ls_new_val_log>-DetailedMessage
                                                            %control = value #( ValUuid         = if_abap_behv=>mk-on
                                                                                MessageNumber   = if_abap_behv=>mk-on
                                                                                DetailedMessage = if_abap_behv=>mk-on  ) ) ) ) ).
    endloop.
    if lt_val_create_log is not initial.
      modify entities of zap_r_val in local mode
          entity zap_r_val
          create by \_Logs from lt_val_create_log .
    endif.

*Not sure if this will add a field change????
    modify entities of zap_r_val in local mode entity zap_r_val update fields ( PoCcode PoType VendorNumber CountryCode ) with corresponding #( lt_val_headers ).
*

  else.

*Pop up the new messages to the user
    loop at lt_val_headers into data(ls_val_header).
      loop at lt_new_val_logs into data(ls_new_val_log).

*Determine the severity from the criticality - and just show the message
        ld_severity     = if_abap_behv_message=>severity-error.
        select single criticality
          from zap_i_msg_cfg
          where MessageNumber = @ls_new_val_log-MessageNumber into @ld_criticality.
        if sy-subrc ne 0
        or ld_criticality = zap_if_constants=>criticality-red.
          ld_severity     = if_abap_behv_message=>severity-error.
        elseif ld_criticality = zap_if_constants=>criticality-yellow.
          ld_severity     = if_abap_behv_message=>severity-warning.
        elseif ld_criticality = zap_if_constants=>criticality-green.
          ld_severity     = if_abap_behv_message=>severity-success.
        endif.
        append value #( %tky = ls_val_header-%tky
                        %msg = new_message_with_text( severity = ld_severity
                                                      text     = ls_new_val_log-detailedmessage ) ) to reported-zap_r_val.
      endloop.
    endloop.
  endif.

  ENDMETHOD.

endclass.
