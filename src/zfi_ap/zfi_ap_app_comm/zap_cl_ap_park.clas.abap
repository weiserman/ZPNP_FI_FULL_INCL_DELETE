class zap_cl_ap_park definition
  public
  final
  create public .

  public section.

    types: begin of ty_ecc_status,
             park_doc_status type zap_de_park_doc_status,
           end of ty_ecc_status.

    types: ty_tt_park_logs type standard table of zap_b_park_log,
           ty_tt_park_head type table for read result zap_r_park.

    class-methods: ecc_check_status importing it_park_head  type ty_tt_park_head
                                    changing  ct_park_logs  type ty_tt_park_logs
                                              cs_ecc_status type ty_ecc_status
                                    raising   zfi_cx,   "cx_communication_target_error cx_appdestination.


      check_parked_documents.



  protected section.
  private section.
    class-data: gd_msg_dummy type bapi_msg.
endclass.

class zap_cl_ap_park implementation.
  method ecc_check_status.

    data: ld_complete type abap_bool,
          ld_msg      type c length 255.

    data: lo_cota type ref to zap_cota_rfc_ecc.

    data(ls_val_head) = it_park_head[  1 ].
    check sy-subrc eq 0.
    cs_ecc_status-park_doc_status = ls_val_head-ParkDocStatus.
    try.

*Get the remote destination
        data(lo_destination) = cl_rfc_destination_provider=>create_by_comm_arrangement( comm_scenario = 'ZAP_RFC_ECC_OUT'                    " Communication scenario
                                                                                        service_id    = 'ZAP_RFC_OUTBOUND_POST_STATUS_SRFC' ).   " Outbound service

        data(ld_destination) = lo_destination->get_destination_name( ).

*Call the remote Function Module
        call function '/PNP/FI_AP_GET_PARK_DOC_STATUS'
          destination ld_destination
          exporting
            id_park_doc           = ls_val_head-ParkDoc
            id_park_doc_year      = ls_val_head-ParkDocYear
          importing
            es_ecc_status         = cs_ecc_status
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
        endif.

      catch cx_rfc_dest_provider_error into data(lrx_dest_provider_error).
        data(ld_error_text) = lrx_dest_provider_error->if_message~get_text( ).
        message e095(zap_rfc) into gd_msg_dummy with ld_error_text+0(50) ld_error_text+50(50) ld_error_text+100(50) ld_error_text+150(50).
        zfi_cx=>raise_with_sysmsg(  ).

    endtry.
  endmethod.

  method check_parked_documents.

    data: lt_park_head   type standard table of zap_b_park_head,
          lt_CheckStatus type table for action import zap_r_park~CheckStatus.

*Check the documents that are in status A (parked) are still in that status.
    select *
     from zap_b_park_head
     where status        = @zap_if_constants=>system_status-in_progress
     and   ParkDocStatus = @zap_if_constants=>park_status-parked
     into table @lt_park_head.

    loop at lt_park_head into data(ls_park_head).
      clear lt_CheckStatus.
      lt_CheckStatus = value #( ( %key-ParkUuid = ls_park_head-ParkUuid  ) ).
    modify entities of zap_r_park entity zap_r_park
       execute CheckStatus from lt_CheckStatus
       failed data(ls_failed_deep)
       reported data(ls_reported_deep).
    endloop.



  endmethod.

endclass.
