class lsc_zap_r_comm definition inheriting from cl_abap_behavior_saver.

  protected section.

    methods save_modified redefinition.

endclass.

class lsc_zap_r_comm implementation.

  method save_modified.

*Validate that there is content to process
    if create-zap_r_comm is initial and
       update-zap_r_comm is initial and
       delete-zap_r_comm is initial.
      return.
    endif.

*Process CREATED modifications
    loop at create-zap_r_comm into data(ls_created_comm_hdr) where %control-commstatus eq cl_abap_behv=>flag_changed.

      try.

*.register background processing framework (bgPF) process to start the next step
          if ls_created_comm_hdr-commstatus eq zap_if_constants=>system_status-success.
            zap_cl_bgpf_utilities=>register_operation( is_register_parameters = value #( comm_uuid           = ls_created_comm_hdr-commuuid
                                                                                         current_step        = zap_if_constants=>step-ingestion
                                                                                         current_step_status = ls_created_comm_hdr-commstatus ) ).
          endif.

        catch zfi_cx into data(lr_zfi_cx).
*            message x204(zap_comm).
      endtry.

*.register event to trigger email response to vendor
*      if ls_created_comm_hdr-commstatus eq zap_if_constants=>system_status-rejected and ls_created_comm_hdr-%control-commstatus eq cl_abap_behv=>flag_changed.
*        raise entity event zap_r_comm~respond_to_vendor
*                from value #( for ls_r_comm in create-zap_r_comm (  %param = value #( comm_uuid           = ls_r_comm-CommUuid
*                                                                                      current_step        = ls_r_comm-CurrentStep
*                                                                                      current_step_status = ls_r_comm-CurrentStepStatus
*                                                                                      email_sender_addr   = ls_r_comm-EmailSenderAddr ) ) ).
*      endif.

    endloop.

*Process UPDATED modifications


  endmethod.

endclass.

class lhc_zap_i_comm_log definition inheriting from cl_abap_behavior_handler.

  private section.

    methods determine_onsave_status for determine on save
      importing keys for zap_i_comm_log~determine_onsave_status.

endclass.

class lhc_zap_i_comm_log implementation.

  method determine_onsave_status.

*Local Data
    data: ld_hdr_status type zap_de_comm_status.

*Read entities
    read entities of zap_r_comm in local mode entity zap_i_comm_log all fields with corresponding #( keys ) result data(lt_logs).
    read entities of zap_r_comm in local mode entity zap_r_comm all fields with corresponding #( lt_logs ) result data(lt_comm_headers).

*Determine if the log contains any errors
    ld_hdr_status = zap_cl_ap_log_utilities=>determine_log_hdr_status( lt_logs ).

*Update CommStatus based on log
    loop at lt_comm_headers assigning field-symbol(<ls_comm_header>).
      <ls_comm_header>-commstatus        = ld_hdr_status.
      <ls_comm_header>-currentstep       = zap_if_constants=>step-ingestion.
      <ls_comm_header>-currentstepstatus = ld_hdr_status.
      <ls_comm_header>-commlogid         = <ls_comm_header>-commlogid + 1.
      get time stamp field <ls_comm_header>-currentstepproccessedat.

      loop at lt_logs assigning field-symbol(<ls_log>) where %data-commuuid = <ls_comm_header>-commuuid.
        <ls_log>-logid = <ls_comm_header>-commlogid.
      endloop.
    endloop.

*Modify communication header entity with new data
    modify entities of zap_r_comm in local mode entity zap_r_comm update fields ( CommStatus CommLogId CurrentStep CurrentStepStatus CurrentStepProccessedAt ) with corresponding #( lt_comm_headers ).

*Modify communication log entity with new data
    modify entities of zap_r_comm in local mode entity zap_i_comm_log update fields ( LogId ) with corresponding #( lt_logs ).

  endmethod.

endclass.

class lhc_zap_i_attach definition inheriting from cl_abap_behavior_handler.

  private section.

    methods determine_onsave_validate for determine on save
      importing keys for zap_i_attach~determine_onsave_validate.

endclass.

class lhc_zap_i_attach implementation.

  method determine_onsave_validate.

*Local data
    data: lt_comm_log type table for create zap_r_comm\_Logs.
    data: ld_hdr_status             type zap_de_comm_status,
          ld_has_invoice_attachment type abap_bool,
          ld_msg_dum                type bapi_msg.

*Read entities
    read entities of zap_r_comm in local mode entity zap_i_attach all fields with corresponding #( keys ) result data(lt_attachments).
    read entities of zap_r_comm in local mode entity zap_i_attach by \_Comm all fields with corresponding #( lt_attachments ) result data(lt_comm_headers).
    read entities of zap_r_comm in local mode entity zap_r_comm by \_Logs all fields with corresponding #( lt_comm_headers ) result data(lt_comm_logs).

*Determine if the log contains any errors
    ld_hdr_status = zap_cl_ap_log_utilities=>determine_log_hdr_status( lt_comm_logs ).

    if ld_hdr_status = zap_if_constants=>system_status-success.

*Validate attachment type
      loop at lt_comm_headers into data(ls_comm_header).

        loop at lt_attachments into data(ls_attachment) where parentuuid = ls_comm_header-commuuid.

          if ls_attachment-attachmenttype <> zap_if_constants=>attachment-attachment_type_invoice and ls_attachment-attachmenttype <> space.
            message e502(zap) with ls_attachment-attachmenttype into ld_msg_dum. "Unknown Attachment Type &1.

            lt_comm_log = value #( ( commuuid = ls_comm_header-commuuid
                                      %target = value #( ( %cid     = |COMM_LOG_ATT_1{ sy-index }|
                                                           commuuid = ls_comm_header-commuuid
                                                      MessageNumber = sy-msgno
                                                    DetailedMessage = ld_msg_dum
                                                           %control = value #( MessageNumber   = if_abap_behv=>mk-on
                                                                               DetailedMessage = if_abap_behv=>mk-on ) ) ) ) ).
            append value #( %tky = ls_comm_header-%tky
                            %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                          text     = ld_msg_dum ) ) to reported-zap_r_comm.
          endif.

          if ls_attachment-attachmenttype = zap_if_constants=>attachment-attachment_type_invoice.
            ld_has_invoice_attachment = abap_true.
          endif.

        endloop.

*Validate that at least one invoice attachment exists
        if ld_has_invoice_attachment = abap_false.
          loop at lt_attachments into ls_attachment.
            message e503(zap) into ld_msg_dum. "No Invoice Attachment.

            lt_comm_log = value #( ( commuuid = ls_comm_header-commuuid
                                      %target = value #( ( %cid     = |COMM_LOG_ATT_2{ sy-index }|
                                                           commuuid = ls_comm_header-commuuid
                                                      MessageNumber = sy-msgno
                                                    DetailedMessage = ld_msg_dum
                                                           %control = value #( MessageNumber   = if_abap_behv=>mk-on
                                                                               DetailedMessage = if_abap_behv=>mk-on ) ) ) ) ).
            append value #( %tky = ls_comm_header-%tky
                            %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                          text     = ld_msg_dum ) ) to reported-zap_r_comm.
          endloop.
        endif.

      endloop.

    endif.

*Save log entries
    if lt_comm_log is not initial.
      modify entities of zap_r_comm in local mode entity zap_r_comm create by \_Logs from corresponding #( lt_comm_log ).
    endif.

  endmethod.

endclass.

class lhc_ZAP_R_COMM definition inheriting from cl_abap_behavior_handler.
  private section.

    methods get_instance_authorizations for instance authorization
      importing keys request requested_authorizations for zap_r_comm result result.

    methods get_global_authorizations for global authorization
      importing request requested_authorizations for zap_r_comm result result.

    methods determine_onsave_externalid for determine on save
      importing keys for zap_r_comm~determine_onsave_externalid.
    methods determine_onmodify_vendornum for determine on modify
      importing keys for zap_r_comm~determine_onmodify_vendornum.
    methods determine_onsave_validate for determine on save
      importing keys for zap_r_comm~determine_onsave_validate.
    methods rejectionpopup for modify
      importing keys for action zap_r_comm~rejectionpopup.
    methods determine_onmodify_invoiceref for determine on modify
      importing keys for zap_r_comm~determine_onmodify_invoiceref.

endclass.

class lhc_ZAP_R_COMM implementation.

  method get_instance_authorizations.
  endmethod.

  method get_global_authorizations.
  endmethod.

  method determine_onsave_externalid.

*Local data
    data: ld_number     type cl_numberrange_runtime=>nr_number,
          ld_returncode type cl_numberrange_runtime=>nr_returncode.

*Read communication header entity
    read entities of zap_r_comm in local mode entity zap_r_comm all fields with corresponding #( keys ) result data(lt_comm_headers).

*Iterate through entity and assign ExternalId
    loop at lt_comm_headers assigning field-symbol(<ls_comm_header>).
      clear: ld_number, ld_returncode.

      try.
          cl_numberrange_runtime=>number_get( exporting nr_range_nr = zap_if_constants=>number_range-comm_external_nr_range_nr
                                                        object      = zap_if_constants=>number_range-comm_external_id_object
                                              importing number     = ld_number
                                                        returncode = ld_returncode ).

          if ld_returncode = space.
            <ls_comm_header>-externalid = |{ ld_number alpha = out }|.
          endif.

        catch cx_number_ranges.
      endtry.

    endloop.

*Modify communication header entity with new ExternalId
    modify entities of zap_r_comm in local mode entity zap_r_comm update fields ( ExternalId ) with corresponding #( lt_comm_headers ).

  endmethod.

  method determine_onmodify_vendornum.

*Local data
    data: lr_abap_regex   type ref to cl_abap_regex,
          lr_abap_matcher type ref to cl_abap_matcher.
    data: ld_domain_pattern  type string value '2\d{9}'.

*Read communication header entity
    read entities of zap_r_comm in local mode entity zap_r_comm all fields with corresponding #( keys ) result data(lt_comm_headers).

*Iterate through entity and assign VendorNumber
    loop at lt_comm_headers assigning field-symbol(<ls_comm_header>).
      clear: lr_abap_regex, lr_abap_matcher.

      lr_abap_regex = cl_abap_regex=>create_pcre( exporting pattern = ld_domain_pattern ).
      lr_abap_matcher = lr_abap_regex->create_matcher( text = <ls_comm_header>-emailsubject ).

      if lr_abap_matcher->find_next( ) = abap_true.
        <ls_comm_header>-vendornumber = lr_abap_matcher->get_submatch( index = 0 ).
      endif.

    endloop.

*Modify communication header entity with new VendorNumber
    modify entities of zap_r_comm in local mode entity zap_r_comm update fields ( VendorNumber ) with corresponding #( lt_comm_headers ).

  endmethod.

  method determine_onsave_validate.

*Local data
    data: lt_comm_log type table for create zap_r_comm\_Logs.
    data: ld_msg_dum type bapi_msg.

*Read communication header entity
    read entities of zap_r_comm in local mode entity zap_r_comm all fields with corresponding #( keys ) result data(lt_comm_headers).

*Iterate through entity and validate elements
    loop at lt_comm_headers into data(ls_comm_header).

*.channel validation
      if ls_comm_header-channel <> zap_if_constants=>comm_channel-email.
        message e511(zap) with ls_comm_header-channel into ld_msg_dum. "Unknown Channel &1.

        lt_comm_log = value #( base lt_comm_log ( commuuid = ls_comm_header-commuuid
                                                   %target = value #( ( %cid     = |COMM_LOG_HDR_1{ sy-index }|
                                                                        commuuid = ls_comm_header-commuuid
                                                                   MessageNumber = sy-msgno
                                                                 DetailedMessage = ld_msg_dum
                                                                        %control = value #( MessageNumber   = if_abap_behv=>mk-on
                                                                                            DetailedMessage = if_abap_behv=>mk-on ) ) ) ) ).
        append value #( %tky = ls_comm_header-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text     = ld_msg_dum ) ) to reported-zap_r_comm.
      endif.

*.external id validation
      if ls_comm_header-externalid is initial.
        message e501(zap) into ld_msg_dum. "External Id Failed To Generate.

        lt_comm_log = value #( base lt_comm_log ( commuuid = ls_comm_header-commuuid
                                                   %target = value #( ( %cid     = |COMM_LOG_HDR_2{ sy-index }|
                                                                        commuuid = ls_comm_header-commuuid
                                                                   MessageNumber = sy-msgno
                                                                 DetailedMessage = ld_msg_dum
                                                                        %control = value #( MessageNumber   = if_abap_behv=>mk-on
                                                                                            DetailedMessage = if_abap_behv=>mk-on ) ) ) ) ).
        append value #( %tky = ls_comm_header-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text     = ld_msg_dum ) ) to reported-zap_r_comm.
      endif.

    endloop.

*Save log entries
    if lt_comm_log is not initial.
      modify entities of zap_r_comm in local mode entity zap_r_comm create by \_Logs from corresponding #( lt_comm_log ).
    endif.

  endmethod.

  method RejectionPopup.

*Local data
    data: lt_comm_log type table for create zap_r_comm\_Logs.

*Read communication header entity
    read entities of zap_r_comm in local mode entity zap_r_comm all fields with corresponding #( keys ) result data(lt_comm_headers).

*Iterate through entity
    loop at lt_comm_headers into data(ls_comm_header).

      loop at keys into data(ls_key).
        clear: lt_comm_log.
        lt_comm_log = value #( base lt_comm_log ( commuuid = ls_comm_header-commuuid
                                                   %target = value #( ( %cid     = |COMM_LOG_HDR_1{ sy-index }|
                                                                        commuuid = ls_comm_header-commuuid
                                                                   MessageNumber = ls_key-%param-rejectionmessagecode
                                                                        %control = value #( MessageNumber   = if_abap_behv=>mk-on ) ) ) ) ).

        modify entities of zap_r_comm in local mode entity zap_r_comm create by \_Logs from corresponding #( lt_comm_log ).
      endloop.

    endloop.
  endmethod.

  method determine_onmodify_invoiceref.

**Local data
*    data: lr_abap_regex   type ref to cl_abap_regex,
*          lr_abap_matcher type ref to cl_abap_matcher.
*    data: ld_domain_pattern  type string value '(?!invoice)(INV[^|()\s]{1,13}|\bINV \d{6})'.
*
**Read communication header entity
*    read entities of zap_r_comm in local mode entity zap_r_comm all fields with corresponding #( keys ) result data(lt_comm_headers).
*
**Iterate through entity and assign VendorNumber
*    loop at lt_comm_headers assigning field-symbol(<ls_comm_header>).
*      clear: lr_abap_regex, lr_abap_matcher.
*
*      lr_abap_regex = cl_abap_regex=>create_pcre( exporting pattern = ld_domain_pattern ).
*      lr_abap_matcher = lr_abap_regex->create_matcher( text = <ls_comm_header>-emailsubject ).
*
*      if lr_abap_matcher->find_next( ) = abap_true.
*        <ls_comm_header>-invoicereference = lr_abap_matcher->get_submatch( index = 0 ).
*      endif.
*
*    endloop.
*
**Modify communication header entity with new VendorNumber
*    modify entities of zap_r_comm in local mode entity zap_r_comm update fields ( InvoiceReference ) with corresponding #( lt_comm_headers ).

  endmethod.

endclass.
