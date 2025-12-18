class zap_cl_ap_fetch_clerk_data definition
  public
  final
  create public .

  public section.
    types ty_tt_vend_cc type standard table of zap_a_vend_cc.
    interfaces if_oo_adt_classrun.
  protected section.
    class-data: gd_msg_dummy type bapi_msg.
    class-methods Get_clerk_data
      exporting
                et_vend_cc type ty_tt_vend_cc
      raising   zfi_cx cx_communication_target_error cx_appdestination.
  private section.
endclass.



class zap_cl_ap_fetch_clerk_data implementation.
  method if_oo_adt_classrun~main.

*Get the Clerk Data
    try.
        Get_clerk_data( importing et_vend_cc = data(lt_et_vend_cc) ).

*
*Delete and recreate the data
        delete from zap_a_vend_cc.
        insert zap_a_vend_cc from table @lt_et_vend_cc.
        if sy-subrc eq 0.
          commit work.
          if sy-subrc eq 0.
            out->write( |{ lines( lt_et_vend_cc ) } Vendor Company code updated| ).
          endif.
        endif.
      catch cx_communication_target_error cx_appdestination into data(lx_error).
        out->write( lx_error->get_text( ) ).
      catch zfi_cx into data(lr_fi_cx).

*        out->write( lr_fi_cx->get_text( ) ).
*
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

*    try.

*    lo_cota = new zap_cota_rfc_ecc( ).

*    data(lo_remote_session) = lo_cota->create_session( ). "Alternatively use method get transient session
*
**  CALL FUNCTION 'RFC_PING' in remote session lo_remote_session.
*    call function '/PNP/FI_AP_GET_VENDOR_DETAILS' in remote session lo_remote_session
*      importing
*        et_ap_clerk_details = lt_ap_clerk_details
*        ed_complete         = ld_complete.
*
**      catch cx_communication_target_error cx_appdestination into data(lx_error).
**        out->write( lx_error->get_text( ) ).
**
**
**    endtry.
    try.
        data(lo_destination) = cl_rfc_destination_provider=>create_by_comm_arrangement( comm_scenario = 'ZAP_RFC_ECC_OUT'                    " Communication scenario
*        data(lo_destination) = cl_rfc_destination_provider=>create_by_comm_arrangement( comm_scenario = 'ZAP_RFC_ECC_OUT'                    " Communication scenario
                                                                                        service_id    = 'ZAP_RFC_OUTBOUND_CLERK_DATA_SRFC' ).   " Outbound service

*Call the remote Function Module
        data(ld_destination) = lo_destination->get_destination_name( ).
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
