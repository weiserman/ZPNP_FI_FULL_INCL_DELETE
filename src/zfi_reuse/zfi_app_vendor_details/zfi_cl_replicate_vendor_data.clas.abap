class zfi_cl_replicate_vendor_data definition
  public
  final
  create public .

  public section.

    interfaces if_apj_rt_run .

    data: md_initialize type abap_bool.

  protected section.
  private section.
endclass.

class zfi_cl_replicate_vendor_data implementation.

  method if_apj_rt_run~execute.

*Local data
    data: lt_fi_vend        type standard table of zfi_a_vend,
          lt_vendor_details type zfi_tt_vendor_details.
    data: ld_msg type c length 255.

*Call ECC to retrieve vendor details
    try.

*.retrieve destination
        try.
            data(lr_destination) = cl_rfc_destination_provider=>create_by_comm_arrangement( comm_scenario = 'ZAP_RFC_ECC_OUT'
                                                                                            service_id    = 'ZFI_RFC_OUTBOUND_GET_VENDOR_DETAILS_SRFC' ).
            data(ld_destination) = lr_destination->get_destination_name( ).

          catch cx_rfc_dest_provider_error into data(lr_cx_rfc_dest_provider_error).
            data(ld_error_text) = lr_cx_rfc_dest_provider_error->if_message~get_text( ).
            message e999(zap_rfc) with ld_error_text into ld_msg.
            zfi_cx=>raise_with_sysmsg(  ).
        endtry.

*.call RFC
        call function '/PNP/FI_AP_GET_VENDOR_DETAILS'
          destination ld_destination
          importing
            et_vendor_details     = lt_vendor_details
          exceptions
            system_failure        = 1
            communication_failure = 2
            others                = 3.
        if sy-subrc <> 0.
          zfi_cx=>raise_with_sysmsg(  ).
        endif.

        loop at lt_vendor_details into data(ls_vendor_detail).
          append value #( vendor_number         = ls_vendor_detail-lifnr
                          vendor_name           = ls_vendor_detail-name1
                          email_address         = ls_vendor_detail-email_address
                          local_created_by      = sy-uname
                          local_created_at      = zca_cl_abap_utilities=>get_utc_timestamplong( )
                          local_last_changed_by = sy-uname
                          local_last_changed_at = zca_cl_abap_utilities=>get_utc_timestamplong( ) ) to lt_fi_vend.
        endloop.

*Depending on user selection
        if md_initialize = abap_true.

          delete from zfi_a_vend.
          insert zfi_a_vend from table @lt_fi_vend.

        else.

          modify zfi_a_vend from table @lt_fi_vend.

        endif.

      catch zfi_cx into data(lr_zfi_cx).
        loop at lr_zfi_cx->get_messages( id_build_texts = abap_true ) into data(ls_message).
          raise exception type cx_apj_rt_content message id 'ZAP_RFC' number 999 with ls_message-message.
        endloop.
    endtry.

  endmethod.
endclass.
