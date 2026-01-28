class zap_cl_ap_val_build_park definition
  public
  final
  create public .

  public section.
    interfaces if_oo_adt_classrun.

    types: begin of ty_parked_doc,
             park_doc        type zap_de_park_doc,
             park_doc_year   type zap_de_park_doc_year,
             park_doc_status type zap_de_park_doc_status,
           end of  ty_parked_doc.

    types: ty_tt_park_create      type table for create zap_r_park,
           ty_tt_park_create_logs type table for create zap_r_park\_Logs,
           ty_tt_val              type table for read result zap_r_val,
           ty_tt_val_items        type table for read result zap_r_val\_Items,
           ty_tt_park_logs        type standard table of zap_b_park_log,
           ty_tt_attach           type table for read result zap_r_comm\_Attachments.

    class-methods:

      build_parking_data importing id_comm_guid       type sysuuid_x16
                                   id_val_uuid        type sysuuid_x16
                         exporting et_park_create     type ty_tt_park_create
                                   et_park_create_log type ty_tt_park_create_logs.
  protected section.
    class-methods: ecc_park_document importing it_val_head   type ty_tt_val
                                               it_val_items  type ty_tt_val_items
                                               it_attach     type ty_tt_attach
                                     changing  ct_park_logs  type ty_tt_park_logs
                                               cs_parked_doc type ty_parked_doc.
  private section.
endclass.



class zap_cl_ap_val_build_park implementation.

  method if_oo_adt_classrun~main.

    build_parking_data( exporting id_comm_guid       = '5A1F9B1918BE1FD0B3E8E7D20A4E17D3'
                                  id_val_uuid        = '5A533F24B9221FE0B3E8E93635B46E5F'
                        importing et_park_create     = data(lt_park_create)
                                  et_park_create_log = data(lt_park_create_logs) ).



  endmethod.
  method build_parking_data.

    data: lt_park_logs  type ty_tt_park_logs,
          ls_parked_doc type ty_parked_doc.
    clear: et_park_create, et_park_create_log.

*Read the validation data
    read entities of zap_r_val  entity zap_r_val           all fields with value #( (  %key-valuuid =  id_val_uuid ) )  result data(lt_val_head).
    read entities of zap_r_val entity zap_r_val by \_Items all fields with corresponding #( lt_val_head )               result data(lt_val_items).

*Read the attachments
    read entities of zap_r_comm  entity zap_r_comm            all fields with value #( (  %key-CommUuid =  id_comm_guid ) ) result data(lt_comm) .
    read entities of zap_r_comm  entity zap_r_comm  by \_Attachments all fields with corresponding #( lt_comm )             result data(lt_attach).


*Do the parking in ECC
    ecc_park_document( exporting it_val_head   = lt_val_head
                                 it_val_items  = lt_val_items
                                 it_attach     = lt_attach
                       changing  ct_park_logs  = lt_park_logs
                                 cs_parked_doc = ls_parked_doc ).

*Create the header and items regardless
    et_park_create = value #( ( %cid                    = 'PARK_HEAD_1'
                               ParentUuid              = id_comm_guid
                               ParkDoc                 = ls_parked_doc-park_doc
                               ParkDocYear             = ls_parked_doc-park_doc_year
                               ParkDocStatus           = ls_parked_doc-park_doc_status
                               %control = value #( ParentUuid     = if_abap_behv=>mk-on
                                                   ParkDoc        = if_abap_behv=>mk-on
                                                   ParkDocYear    = if_abap_behv=>mk-on
                                                   ParkDocStatus  = if_abap_behv=>mk-on  ) ) ).

    et_park_create_log = value #( for ls_new_val_log in lt_park_logs index into ld_index
                                   (  %cid_ref  = 'PARK_HEAD_1'
                                      %target = value #( ( %cid            = |LOG{ ld_index }|
                                                           MessageNumber   =  ls_new_val_log-MessageNumber
                                                           DetailedMessage =  ls_new_val_log-DetailedMessage
                                                           %control = value #( MessageNumber   = if_abap_behv=>mk-on
                                                                               DetailedMessage = if_abap_behv=>mk-on  ) ) ) ) ).

  endmethod.
  method ecc_park_document.

    types: begin of ty_val_head_rfc,
             purchase_order_number type zap_de_val_purchase_order,
             invoice_reference     type zap_de_val_invoice_reference,
             invoice_date          type zap_de_val_invoice_date,
             vendor_name           type zap_de_val_vendor_name,
             vendor_vat_number     type zap_de_val_vendor_vat_number,
             pnp_vat_number        type zap_de_val_pnp_vat_number,
             total_vat_inclusive   type zap_de_val_total_vat_inclusive,
             vat_value             type zap_de_val_vat_value,
             acknowledge_warning   type zap_de_val_acknlge_warning,
             vendor_number         type zap_de_vendor_number,
             po_ccode              type zap_de_po_ccode,
             country_code          type zap_de_country_code,
             po_type               type zap_de_po_type,
           end of ty_val_head_rfc.

    types: begin of ty_val_item_rfc,
             item_description type zap_de_val_item_description,
             item_quantity    type zap_de_val_item_quantity,
             item_nett_value  type zap_de_val_item_nett_value,
           end of ty_val_item_rfc.

    types: begin of ty_email_attach,
             aws_s3_sign_url(2048)   type c,
             aws_s3_object_key(1024) type c,
             aws_s3_bucket(1024)     type c,
             aws_s3_file_arn(1024)   type c,
             file_name(256)          type c,
             file_extension(10)      type c,
           end of  ty_email_attach.

    types: begin of ty_val_log,
             messagenumber   type symsgno,
             detailedmessage type zap_de_detailed_message,
           end of ty_val_log.

    data: ld_complete     type abap_bool,
          ld_msg          type c length 255,
          ls_val_item_rfc type ty_val_item_rfc,
          ls_val_head_rfc type ty_val_head_rfc,
          ls_email_attach type ty_email_attach,
          lt_email_attach type standard table of ty_email_attach,
          lt_val_item_rfc type standard table of ty_val_item_rfc,
          lt_val_logs_rfc type standard table of ty_val_log.

    data(ls_val_head) = it_val_head[  1 ].
    check sy-subrc eq 0.
    clear cs_parked_doc.

*    move-corresponding ls_val_head to ls_val_head_rfc.
    ls_val_head_rfc-purchase_order_number = ls_val_head-PurchaseOrderNumber.
    ls_val_head_rfc-invoice_reference     = ls_val_head-InvoiceReference.
    ls_val_head_rfc-invoice_date          = ls_val_head-InvoiceDate.
    ls_val_head_rfc-vendor_name           = ls_val_head-VendorName.
    ls_val_head_rfc-vendor_vat_number     = ls_val_head-VendorVatNumber.
    ls_val_head_rfc-pnp_vat_number        = ls_val_head-PnpVatNumber.
    ls_val_head_rfc-total_vat_inclusive   = ls_val_head-TotalVatInclusive.
    ls_val_head_rfc-vat_value             = ls_val_head-VatValue.
    ls_val_head_rfc-acknowledge_warning   = ls_val_head-AcknowledgeWarning.
    ls_val_head_rfc-po_ccode              = ls_val_head-poccode.
    ls_val_head_rfc-country_code          = ls_val_head-countrycode.
    ls_val_head_rfc-po_type               = ls_val_head-potype.
    loop at it_val_items into data(ls_val_item).
      ls_val_item_rfc-item_description = ls_val_item-ItemDescription.
      ls_val_item_rfc-item_nett_value  = ls_val_item-ItemNettValue.
      ls_val_item_rfc-item_quantity    = ls_val_item-ItemQuantity.
      append ls_val_item_rfc to lt_val_item_rfc.
    endloop.
    loop at it_attach into data(ls_attach).
      ls_email_attach-aws_s3_bucket     = ls_attach-AwsS3Bucket.
      ls_email_attach-aws_s3_object_key = ls_attach-AwsS3ObjectKey.
      ls_email_attach-aws_s3_sign_url   = ls_attach-AwsS3SignedUrl.
      ls_email_attach-file_name         = ls_attach-FileName.
      ls_email_attach-aws_s3_file_arn   = ls_attach-AwsS3FileArn.
      ls_email_attach-file_extension    = to_upper( ls_attach-FileExtension ).
      append ls_email_attach to lt_email_attach.
    endloop.

    try.
        data(lo_destination) = cl_rfc_destination_provider=>create_by_comm_arrangement( comm_scenario = 'ZAP_RFC_ECC_OUT'   " Communication scenario
                                                                                        service_id    = 'ZAP_RFC_OUTBOUND_POST_DOC_SRFC' ).   " Outbound service

*Call the remote Function Module
        data(ld_destination) = lo_destination->get_destination_name( ).
        call function '/PNP/FI_AP_PARK_DOCUMENT'
          destination ld_destination
          exporting
            it_val_items          = lt_val_item_rfc
            it_email_attach       = lt_email_attach
            is_val_head           = ls_val_head_rfc
          importing
            et_val_logs           = lt_val_logs_rfc
            ed_complete           = ld_complete
            es_park_head          = cs_parked_doc
          exceptions
            system_failure        = 1 message ld_msg
            communication_failure = 2 message ld_msg
            others                = 3.
        if sy-subrc eq 1.
          append value #( MessageNumber = '091' DetailedMessage = |ECC SYSTEM_FAILURE - { ld_msg }| ) to lt_val_logs_rfc.
        elseif sy-subrc eq 2.
          append value #( MessageNumber = '092' DetailedMessage = |ECC COMM_FAILURE - { ld_msg }| ) to lt_val_logs_rfc.
        elseif sy-subrc eq 3.
          append value #( MessageNumber = '093' DetailedMessage = |ECC OTHER FAILUE -  Contact System Administrator| ) to lt_val_logs_rfc.
        elseif ld_complete ne abap_true.      "In case there is a dump
          append value #( MessageNumber = '094' DetailedMessage = |ECC FAILUE -  Check For Short Dumps| ) to lt_val_logs_rfc.
        else.
        endif.
        move-corresponding: lt_val_logs_rfc to ct_park_logs.

      catch cx_rfc_dest_provider_error into data(lrx_dest_provider_error).
       data(ld_error_text) = lrx_dest_provider_error->if_message~get_text( ).
        append value #( MessageNumber = '095' DetailedMessage = |DESTINATION ERROR - { ld_error_text }| ) to ct_park_logs.
    endtry.
  endmethod.
endclass.
