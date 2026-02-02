class zfi_cl_replicate_vend_clk_data definition
  public
  final
  create public .

  public section.
    interfaces if_apj_rt_run .
    data: md_initialize type abap_bool.
    types ty_tt_vend_cc type standard table of zap_a_vend_cc.

  protected section.
    class-data: gd_msg_dummy type bapi_msg.
    class-methods Get_clerk_data
      exporting
                et_vend_cc type ty_tt_vend_cc
      raising   zfi_cx cx_communication_target_error cx_appdestination.
  private section.
endclass.


class zfi_cl_replicate_vend_clk_data implementation.

  method if_apj_rt_run~execute.
*Get the Clerk Data
    try.
        Get_clerk_data( importing et_vend_cc = data(lt_et_vend_cc) ).

*Delete and recreate the data
        if md_initialize = abap_true.
          delete from zap_a_vend_cc.
          insert zap_a_vend_cc from table @lt_et_vend_cc.
          if sy-subrc eq 0.
            commit work.
****          if sy-subrc eq 0.
****            out->write( |{ lines( lt_et_vend_cc ) } Vendor Company code updated| ).
****          endif.
          endif.
          modify zap_a_vend_cc from table @lt_et_vend_cc.
        else.
        endif.
      catch cx_communication_target_error cx_appdestination into data(lx_error).
*        out->write( lx_error->get_text( ) ).
      catch zfi_cx into data(lr_zfi_cx).

        loop at lr_zfi_cx->get_messages( id_build_texts = abap_true ) into data(ls_message).
          raise exception type cx_apj_rt_content message id 'ZAP_RFC' number 999 with ls_message-message.
        endloop.
    endtry.

  endmethod.

  method get_clerk_data.

    types: begin of ty_ap_clerk_detail,
             vendor                  type zap_de_vendor_number,
             ccode                   type zap_de_po_ccode,
             process_clerk           type  zap_de_process_clerk,
             proc_clerk_btp_uname    type zap_de_clerk_btp_uname,
             supvsor_clerk           type zap_de_supvsor_clerk,
             supvsor_clerk_btp_uname type zap_de_clerk_btp_uname,
           end of ty_ap_clerk_detail.

    data: ld_complete         type abap_bool,
          ld_msg              type c length 255,
          lt_ap_clerk_details type standard table of ty_ap_clerk_detail.

    data: lo_cota type ref to zap_cota_rfc_ecc.

    try.

*Get the remote destination
        data(lo_destination) = cl_rfc_destination_provider=>create_by_comm_arrangement( comm_scenario = 'ZAP_RFC_ECC_OUT'                    " Communication scenario
                                                                                        service_id    = 'ZAP_RFC_OUTBOUND_CLERK_DATA_SRFC' ).   " Outbound service


        data(ld_destination) = lo_destination->get_destination_name( ).

*Call the remote Function Module
        call function '/PNP/FI_AP_GET_CLERK_DETAILS'
          destination ld_destination
          importing
            et_ap_clerk_details   = lt_ap_clerk_details
            ed_complete           = ld_complete
          exceptions
            system_failure        = 1 message ld_msg
            communication_failure = 2 message ld_msg
            others                = 3.
        if sy-subrc eq 1.
          message e091(zap_rfc) into gd_msg_dummy with ld_msg+0(50) ld_msg+50(50) ld_msg+100(50) ld_msg+150(50).
          zfi_cx=>raise_with_sysmsg(  ).

        elseif sy-subrc eq 2.
          message e092(zap_rfc) into gd_msg_dummy with ld_msg+0(50) ld_msg+50(50) ld_msg+100(50) ld_msg+150(50).
          zfi_cx=>raise_with_sysmsg(  ).
        elseif sy-subrc eq 3.
          message e093(zap_rfc) into gd_msg_dummy with ld_msg+0(50) ld_msg+50(50) ld_msg+100(50) ld_msg+150(50).
          zfi_cx=>raise_with_sysmsg(  ).
        elseif ld_complete ne abap_true.      "In case there is a dump
          message e094(zap_rfc) into gd_msg_dummy with ld_msg+0(50) ld_msg+50(50) ld_msg+100(50) ld_msg+150(50).
          zfi_cx=>raise_with_sysmsg(  ).
        else.
        endif.
*        move-corresponding: lt_ap_clerk_details to et_vend_cc.
        et_vend_cc = value #( for ls_ap_clerk_detail in lt_ap_clerk_details
                                   ( client                  = syst-mandt
                                     local_created_by        = sy-uname
                                     local_created_at        = zca_cl_abap_utilities=>get_utc_timestamplong( )
                                     local_last_changed_by   = sy-uname
                                     local_last_changed_at   = zca_cl_abap_utilities=>get_utc_timestamplong( )
                                     po_ccode                = ls_ap_clerk_detail-ccode
                                     proc_clerk_btp_uname    = ls_ap_clerk_detail-proc_clerk_btp_uname
                                     process_clerk           = ls_ap_clerk_detail-process_clerk
                                     supvsor_clerk           = ls_ap_clerk_detail-supvsor_clerk
                                     supvsor_clerk_btp_uname = ls_ap_clerk_detail-supvsor_clerk_btp_uname
                                     vendor_number           = ls_ap_clerk_detail-vendor  ) ).

      catch cx_rfc_dest_provider_error into data(lrx_dest_provider_error).
        data(ld_error_text) = lrx_dest_provider_error->if_message~get_text( ).
        message e095(zap_rfc) into gd_msg_dummy with ld_error_text+0(50) ld_error_text+50(50) ld_error_text+100(50) ld_error_text+150(50).
        zfi_cx=>raise_with_sysmsg(  ).

    endtry.
  endmethod.
endclass.
