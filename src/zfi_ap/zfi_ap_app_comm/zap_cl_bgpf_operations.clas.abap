class zap_cl_bgpf_operations definition
    public
    final
    create public.

  public section.

    interfaces if_bgmc_op_single_tx_uncontr.

    methods constructor
      importing
        is_register_parameters type zap_s_bgpf_register_parameters.

  private section.

    data: gs_register_parameters type zap_s_bgpf_register_parameters.
    data: gd_msg_dummy type bapi_msg.

    methods: next_step_ocr raising cx_bgmc_operation.
    methods: next_step_val raising cx_bgmc_operation.
    methods: next_step_park raising cx_bgmc_operation.
    methods: next_step_appr raising cx_bgmc_operation.
    methods: ocr_invoice_via_aws raising cx_bgmc_operation.

endclass.

class zap_cl_bgpf_operations implementation.


  method constructor.

    gs_register_parameters = is_register_parameters.

  endmethod.


  method next_step_val.

*Build the validation data from the OCR data
    zap_cl_ap_ocr_build_val=>build_validation_data( exporting id_comm_guid        = gs_register_parameters-comm_uuid
                                                    importing et_val_create       = data(lt_val_create)
                                                              et_val_create_items = data(lt_val_create_items)
                                                              et_val_create_log   = data(lt_val_create_log) ).

    modify entities of zap_r_val
        entity zap_r_val
        create from lt_val_create

        entity zap_r_val
        create by \_Items from lt_val_create_items

        entity zap_r_val
        create by \_Logs from lt_val_create_log
    failed data(ls_failed)
    reported data(ls_reported).
*Check for errors, if found fail the BGPF
    if ls_failed is not initial.
      loop at ls_reported-zap_r_val into data(ls_zap_r_val_reported).
        raise exception type cx_bgmc_operation
          exporting
            textid         = value #( msgid = sy-msgid
                                      msgno = sy-msgno
                                      attr1 = sy-msgv1 )
            retry_settings = value #( do_retry = abap_false ).
      endloop.
    endif.
  endmethod.


  method ocr_invoice_via_aws.

*Local Data
    data: lr_cota_ocr_invoice type ref to zap_cota_aws_ocr_inv.
    data: lt_ocr_create     type table for create zap_r_ocr,
          lt_ocr_create_log type table for create zap_r_ocr\_Logs.
    data: ls_ocr_invoice_srv_def type zap_s_cota_ocr_invoice_srv_def,
          ls_ocr_cfg             type zap_a_ocr_cfg.
    data: ld_json_message type string.

*Retrieve data needed for OCR processing
    try.
        select single *
         from zap_a_comm
         where comm_uuid = @gs_register_parameters-comm_uuid
          into @data(ls_comm_header).
        if sy-subrc <> 0.
          message e504(zap) with gs_register_parameters-comm_uuid into gd_msg_dummy. "Comm Header Entity Not Found, &1.
          zfi_cx=>raise_with_sysmsg(  ).
        endif.

        select single *
         from zap_a_attach
         where parent_uuid     = @gs_register_parameters-comm_uuid
           and attachment_type = @zap_if_constants=>attachment-attachment_type_invoice
          into @data(ls_attachment).
        if sy-subrc <> 0.
          message e510(zap) into gd_msg_dummy. "No Invoice Attachment Found.
          zfi_cx=>raise_with_sysmsg(  ).
        endif.

*        ls_ocr_cfg = zap_cl_ocr_inv_cfg_utilities=>determine_ocr_invoice_config( id_ocr_type  = zap_cl_ocr_inv_cfg_utilities=>gc_ocr_type_default
*                                                                                 id_comm_uuid = gs_register_parameters-comm_uuid ).

*.build message structure for OCR service
        ls_ocr_invoice_srv_def = value #( comm_uuid           = gs_register_parameters-comm_uuid
                                          ocr_uuid            = gs_register_parameters-ocr_uuid
                                          external_id         = ls_comm_header-external_id
                                          email_sender_addr   = ls_comm_header-email_sender_addr
                                          pdf_arn             = ls_attachment-aws_s3_file_arn
                                          prompt_s3_bucket    = 'ap-btp-prompt-dev-a319b344b3d0c5dd0df8'
                                          prompt_s3_key       = 'invoice-processing-prompt.txt'
                                          force_textract_redo = 'false'
                                          llm_only            = 'false'
*                                          bedrock_model_id    = 'eu.anthropic.claude-3-5-sonnet-20240620-v1:0'                                          "Old
                                          bedrock_model_id    = 'arn:aws:bedrock:eu-west-1:058264329173:application-inference-profile/v14o343nxapg'      "New
                                          country_code        = ls_comm_header-country_code ).

*        ls_ocr_invoice_srv_def = value #( comm_uuid           = gs_register_parameters-comm_uuid
*                                          ocr_uuid            = gs_register_parameters-ocr_uuid
*                                          external_id         = ls_comm_header-external_id
*                                          email_sender_addr   = ls_comm_header-email_sender_addr
*                                          pdf_arn             = ls_attachment-aws_s3_file_arn
*                                          prompt_s3_bucket    = ls_ocr_cfg-aws_s3_prompt_bucket
*                                          prompt_s3_key       = ls_ocr_cfg-aws_s3_prompt_object_key
*                                          force_textract_redo = ls_ocr_cfg-aws_opt_force_textract_redo
*                                          llm_only            = ls_ocr_cfg-aws_opt_llm_only
*                                          bedrock_model_id    = ls_ocr_cfg-aws_bedrock_model_id
*                                          country_code        = ls_comm_header-country_code ).

*.serialize message structure to JSON
        ld_json_message = /ui2/cl_json=>serialize( data        = ls_ocr_invoice_srv_def
                                                   pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).

        if ld_json_message is initial.
          message e506(zap) into gd_msg_dummy. "Failure To Create Message In JSON Format.
          zfi_cx=>raise_with_sysmsg(  ).
        endif.

*Call outbound service to perform OCR
        try.
            lr_cota_ocr_invoice = new zap_cota_aws_ocr_inv( ).
            data(lr_client) = lr_cota_ocr_invoice->create_web_http_client( ).
            data(lr_request) = lr_client->get_http_request( ).

            lr_request->set_content_type( 'application/json' ).
            lr_request->set_text( ld_json_message ).

            data(lr_response) = lr_client->execute( i_method = if_web_http_client=>post ).
            if lr_response->get_status( )-code <> '200'.
              message e507(zap) with lr_response->get_status( )-code into gd_msg_dummy. "Failed To Send OCR Request With HTTP Code &1.
              zfi_cx=>raise_with_sysmsg(  ).
            endif.

          catch cx_appdestination into data(lr_cx_appdestination).
            message e899(zap) with lr_cx_appdestination->get_text( ) into gd_msg_dummy. "&1 &2 &3 &4
            zfi_cx=>raise_with_sysmsg(  ).
            message e899(zap) with gd_msg_dummy into gd_msg_dummy. "&1 &2 &3 &4
          catch cx_communication_target_error into data(lr_cx_comm_target_error).
            message e899(zap) with lr_cx_comm_target_error->get_text( ) into gd_msg_dummy. "&1 &2 &3 &4
            zfi_cx=>raise_with_sysmsg(  ).
          catch cx_web_http_client_error into data(lr_cx_web_http_client_error).
            message e899(zap) with lr_cx_web_http_client_error->get_text( ) into gd_msg_dummy. "&1 &2 &3 &4
            zfi_cx=>raise_with_sysmsg(  ).
        endtry.

*Write success to OCR entity
        lt_ocr_create_log = value #( ( ocruuid = gs_register_parameters-ocr_uuid
                                       %target = value #( ( %cid          = 'OCR_LOG_1'
                                                            ocruuid       = gs_register_parameters-ocr_uuid
                                                            MessageNumber = zap_if_constants=>system_status-success
                                                            %control = value #( ocruuid       = if_abap_behv=>mk-on
                                                                                MessageNumber = if_abap_behv=>mk-on ) ) ) ) ).

        modify entities of zap_r_ocr
            entity zap_r_ocr
            create by \_Logs from lt_ocr_create_log.

      catch zfi_cx into data(lr_fi_cx).
        loop at lr_fi_cx->get_messages( abap_true ) into data(ls_message).
          lt_ocr_create_log = value #( ( ocruuid = gs_register_parameters-ocr_uuid
                                         %target = value #( ( %cid            = 'OCR_LOG_1'
                                                              ocruuid         = gs_register_parameters-ocr_uuid
                                                              MessageNumber   = ls_message-msgno
                                                              DetailedMessage = ls_message-message
                                                              %control = value #( MessageNumber   = if_abap_behv=>mk-on
                                                                                  DetailedMessage = if_abap_behv=>mk-on ) ) ) ) ).
        endloop.

        modify entities of zap_r_ocr
            entity zap_r_ocr
            create by \_Logs from lt_ocr_create_log.
    endtry.

    commit entities response of zap_r_ocr
        failed data(ls_ocr_create_failed)
        reported data(ls_ocr_create_reported).

*Check for errors, if found fail the BGPF
    if ls_ocr_create_failed is not initial.
      loop at ls_ocr_create_reported-zap_r_ocr into data(ls_ocr_head_create_reported).
        message e507(zap) with ls_ocr_head_create_reported-%msg->if_message~get_text( ) into gd_msg_dummy. "Error Sending OCR Request: &1.
        raise exception type cx_bgmc_operation
          exporting
            textid         = value #( msgid = sy-msgid
                                      msgno = sy-msgno
                                      attr1 = sy-msgv1 )
            retry_settings = value #( do_retry = abap_false ).
      endloop.
    endif.

  endmethod.


  method if_bgmc_op_single_tx_uncontr~execute.

*Local data
    data: lt_bgpfl_create type table for create zap_r_bgpfl.

    lt_bgpfl_create = value #( ( %cid = 'BGPFL_1'
                                 CommUuid           = gs_register_parameters-comm_uuid
                                 CurrentStep        = gs_register_parameters-current_step
                                 CurrentStepStatus  = gs_register_parameters-current_step_status
                                 OcrUuid            = gs_register_parameters-ocr_uuid
                                 %control = value #( CommUuid           = if_abap_behv=>mk-on
                                                     CurrentStep        = if_abap_behv=>mk-on
                                                     CurrentStepStatus  = if_abap_behv=>mk-on
                                                     OcrUuid            = if_abap_behv=>mk-on ) ) ).
    modify entities of zap_r_bgpfl
        entity zap_r_bgpfl
        create from lt_bgpfl_create.

    commit entities response of zap_r_bgpfl
        failed data(ls_bgpfl_create_failed)
        reported data(ls_bgpfl_create_reported).

    select single @abap_true
       from zap_a_comm
       where comm_uuid           eq @gs_register_parameters-comm_uuid
         and current_step        eq @gs_register_parameters-current_step
         and current_step_status eq @gs_register_parameters-current_step_status
    into @data(ld_is_comm_unchanged).
    if ld_is_comm_unchanged = abap_false.
      return.
    endif.

    case gs_register_parameters-current_step.
      when zap_if_constants=>step-ingestion.

        if gs_register_parameters-current_step_status = zap_if_constants=>system_status-success.
          next_step_ocr(  ).
        endif.

      when zap_if_constants=>step-ocr_invoice.

        if gs_register_parameters-current_step_status = zap_if_constants=>system_status-in_progress.
          ocr_invoice_via_aws(  ).
        elseif gs_register_parameters-current_step_status = zap_if_constants=>system_status-success.
          next_step_val(  ).
        endif.
      when zap_if_constants=>step-validation.
        next_step_park(  ).
      when zap_if_constants=>step-parking.
        next_step_appr(  ).
      when others.

    endcase.

  endmethod.


  method next_step_ocr.

*Local Data
    data: lt_ocr_create     type table for create zap_r_ocr,
          lt_ocr_create_log type table for create zap_r_ocr\_Logs.
    data: ld_ocr_uuid type sysuuid_x16.

*Based on whether the OCR entity exists for the communication
    select single ocr_uuid
     from zap_a_ocr_head
    where parent_uuid eq @gs_register_parameters-comm_uuid
     into @ld_ocr_uuid.

*.create the OCR entity if it does not exist, else update it. Syntax is the same for both create and update.
    if ld_ocr_uuid is initial.
      ld_ocr_uuid = gs_register_parameters-comm_uuid.
    endif.

    lt_ocr_create = value #( ( %cid       = 'OCR_HEAD_1'
                               parentuuid = ld_ocr_uuid
                               %control = value #( parentuuid = if_abap_behv=>mk-on ) ) ).

    lt_ocr_create_log = value #( ( %cid_ref   = 'OCR_HEAD_1'
                                   %target = value #( ( %cid          = 'OCR_LOG_1'
                                                        MessageNumber = zap_if_constants=>system_status-in_progress
                                                        %control = value #( MessageNumber = if_abap_behv=>mk-on ) ) ) ) ).

    modify entities of zap_r_ocr
        entity zap_r_ocr
        create from lt_ocr_create

        entity zap_r_ocr
    create by \_Logs from lt_ocr_create_log.

    commit entities response of zap_r_ocr
        failed data(ls_ocr_create_failed)
        reported data(ls_ocr_create_reported).

*Check for errors, if found fail the BGPF
    if ls_ocr_create_failed is not initial.
      loop at ls_ocr_create_reported-zap_r_ocr into data(ls_ocr_head_create_reported).
        message e508(zap) with ls_ocr_head_create_reported-%msg->if_message~get_text( ) into gd_msg_dummy. "Error Creating OCR: &1.
        raise exception type cx_bgmc_operation
          exporting
            textid         = value #( msgid = sy-msgid
                                      msgno = sy-msgno
                                      attr1 = sy-msgv1 )
            retry_settings = value #( do_retry = abap_false ).
      endloop.
    endif.

  endmethod.
  method next_step_appr.

    data: ld_appr_uuid type sysuuid_x16,
          lt_appr_create     type table for create zap_r_appr,
          lt_appr_create_log type table for create zap_r_appr\_Logs.


    lt_appr_create = value #( ( %cid       = 'APPR_1'
                               parentuuid = gs_register_parameters-comm_uuid
                               %control = value #( parentuuid = if_abap_behv=>mk-on ) ) ).

    lt_appr_create_log = value #( ( %cid_ref   = 'APPR_1'
                                   %target = value #( ( %cid          = 'APPR_LOG_1'
                                                        MessageNumber = zap_if_constants=>system_status-created
                                                        %control = value #( MessageNumber = if_abap_behv=>mk-on ) ) ) ) ).

    modify entities of zap_r_appr
        entity zap_r_appr
        create from lt_appr_create
        entity zap_r_appr
    create by \_Logs from lt_appr_create_log.

    commit entities response of zap_r_appr
        failed data(ls_appr_create_failed)
        reported data(ls_appr_create_reported).

*Check for errors, if found fail the BGPF
    if ls_appr_create_failed is not initial.
      loop at ls_appr_create_reported-zap_r_appr into data(ls_appr_reported).
        message e511(zap) with ls_appr_reported-%msg->if_message~get_text( ) into gd_msg_dummy. "Error Creating Approval: &1.
        raise exception type cx_bgmc_operation
          exporting
            textid         = value #( msgid = sy-msgid
                                      msgno = sy-msgno
                                      attr1 = sy-msgv1 )
            retry_settings = value #( do_retry = abap_false ).
      endloop.
    endif.

  endmethod.

  method next_step_park.

*Build the parking data from the validation data
    zap_cl_ap_val_build_park=>build_parking_data( exporting id_comm_guid       = gs_register_parameters-comm_uuid
                                                            id_val_uuid        = gs_register_parameters-val_uuid
                                                  importing et_park_create     = data(lt_park_create)
                                                            et_park_create_log = data(lt_park_create_log) ).

*Create the parking entities
    modify entities of zap_r_park
        entity zap_r_park
        create from lt_park_create
         entity zap_r_park
        create by \_Logs from lt_park_create_log
    failed data(ls_failed)
    reported data(ls_reported).

*Check for errors, if found fail the BGPF
    if ls_failed is not initial.
      loop at ls_reported-zap_r_park into data(ls_zap_r_park_reported).
        message e205(zap_park) with ls_zap_r_park_reported-%msg->if_message~get_text( ) into gd_msg_dummy. "Error Creating OCR: &1.
        raise exception type cx_bgmc_operation
          exporting
            textid         = value #( msgid = sy-msgid
                                      msgno = sy-msgno
                                      attr1 = sy-msgv1 )
            retry_settings = value #( do_retry = abap_false ).
      endloop.
    endif.
  endmethod.

endclass.
