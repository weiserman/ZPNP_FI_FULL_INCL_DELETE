*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
class lcl_ap_ocr_event_consumption definition inheriting from cl_abap_behavior_event_handler.

  private section.
    methods ocr_invoice_via_aws for entity event it_events for zap_r_ocr~ocr_invoice_via_aws.

endclass.

class lcl_ap_ocr_event_consumption implementation.

  method ocr_invoice_via_aws.

**Local Data
*    data: lr_cota_ocr_invoice type ref to zap_cota_ocr_invoice.
*    data: lt_comm_update type table for update zap_r_comm.
*    data: ls_ocr_invoice_srv_def type zap_s_cota_ocr_invoice_srv_def,
*          ls_ocr_cfg             type zap_a_ocr_cfg.
*    data: ld_json_message type string,
*          ld_msg_dummy    type string.
*
**Iterate through the events
*    loop at it_events into data(ls_event).
*
**.retrieve data needed for OCR processing
*      try.
*          select single *
*           from zap_a_comm
*           where comm_uuid = @ls_event-comm_uuid
*            into @data(ls_comm_header).
*          if sy-subrc <> 0.
*            message e002(zap_ocr) with ls_event-comm_uuid into ld_msg_dummy. "Comm Header Entity Not Found, &1.
*            zfi_cx=>raise_with_sysmsg(  ).
*          endif.
*
*          select single *
*           from zap_a_attach
*           where parent_uuid     = @ls_event-comm_uuid
*             and attachment_type = @zap_if_constants=>attachment-attachment_type_invoice
*            into @data(ls_attachment).
*          if sy-subrc <> 0.
*            message e003(zap_ocr) into ld_msg_dummy. "No Invoice Attachment Found.
*            zfi_cx=>raise_with_sysmsg(  ).
*          endif.
*
*          ls_ocr_cfg = zap_cl_ocr_inv_cfg_utilities=>determine_ocr_invoice_config( id_ocr_type  = zap_cl_ocr_inv_cfg_utilities=>gc_ocr_type_default
*                                                                                   id_comm_uuid = ls_event-comm_uuid ).
*
*
**..build message structure for OCR service
*          ls_ocr_invoice_srv_def = value #( comm_uuid           = ls_comm_header-comm_uuid
*                                            ocr_uuid            = ls_event-ocruuid
*                                            external_id         = ls_comm_header-external_id
*                                            email_sender_addr   = ls_comm_header-email_sender_addr
*                                            pdf_arn             = ls_attachment-aws_s3_file_arn
*                                            prompt_s3_bucket    = ls_ocr_cfg-aws_s3_prompt_bucket
*                                            prompt_s3_key       = ls_ocr_cfg-aws_s3_prompt_object_key
*                                            force_textract_redo = ls_ocr_cfg-aws_opt_force_textract_redo
*                                            llm_only            = ls_ocr_cfg-aws_opt_llm_only
*                                            bedrock_model_id    = ls_ocr_cfg-aws_bedrock_model_id
*                                            country_code        = ls_comm_header-country_code ).
*
**..serialize message structure to JSON
*          ld_json_message = /ui2/cl_json=>serialize( data        = ls_ocr_invoice_srv_def
*                                                     pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).
*
*          if ld_json_message is initial.
*            message e004(zap_ocr) into ld_msg_dummy. "Failure To Create Message In JSON Format.
*            zfi_cx=>raise_with_sysmsg(  ).
*          endif.
*
**.call outbound service to perform OCR
*          try.
*              lr_cota_ocr_invoice = new zap_cota_ocr_invoice( ).
*              data(lr_client) = lr_cota_ocr_invoice->create_web_http_client( ).
*              data(lr_request) = lr_client->get_http_request( ).
*
*              lr_request->set_content_type( 'application/json' ).
*              lr_request->set_text( ld_json_message ).
*
*              data(lr_response) = lr_client->execute( i_method = if_web_http_client=>post ).
*              if lr_response->get_status( )-code <> '200'.
*                message e005(zap_ocr) into ld_msg_dummy. "Failed To Send OCR Request With HTTP Code &1.
*                zfi_cx=>raise_with_sysmsg(  ).
*              endif.
*
*            catch cx_appdestination into data(lr_cx_appdestination).
*              message e001(zap_ocr) with lr_cx_appdestination->get_text( ) into ld_msg_dummy. "Application Destination Error: &1.
*              zfi_cx=>raise_with_sysmsg(  ).
*              message e001(zap_ocr) with ld_msg_dummy into ld_msg_dummy. "Application Destination Error: &1.
*            catch cx_communication_target_error into data(lr_cx_comm_target_error).
*              message e001(zap_ocr) with lr_cx_comm_target_error->get_text( ) into ld_msg_dummy. "Communication Target Error: &1.
*              zfi_cx=>raise_with_sysmsg(  ).
*            catch cx_web_http_client_error into data(lr_cx_web_http_client_error).
*              message e001(zap_ocr) with lr_cx_web_http_client_error->get_text( ) into ld_msg_dummy. "HTTP Client Error: &1.
*              zfi_cx=>raise_with_sysmsg(  ).
*          endtry.
*
*        catch zfi_cx into data(lr_cx_zap).
*
*      endtry.
*
**.update COMM_HEADER with progress
*      lt_comm_update = value #( ( CommUuid          = ls_event-comm_uuid
*                                  CurrentStepStatus = zap_if_constants=>system_status-success
*                                  CurrentStep       = zap_if_constants=>step-ocr_invoice
*                                  %control = value #( CurrentStepStatus = if_abap_behv=>mk-on
*                                                      CurrentStep       = if_abap_behv=>mk-on ) ) ).
*
*      modify entities of zap_r_comm entity zap_r_comm
*
*        update from lt_comm_update
*
*        failed data(ls_failed)
*        mapped data(ls_mapped)
*        reported data(ls_reported).
*
*    endloop.

  endmethod.

endclass.
