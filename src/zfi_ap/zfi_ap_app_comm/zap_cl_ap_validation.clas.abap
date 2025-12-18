!class zap_cl_ap_validation definition

  public
  final
  create public .

public section.
  types: begin of ty_ecc_determinations,
           po_ccode      type zap_de_po_ccode,
           country_code  type zap_de_country_code,
           po_type       type zap_de_po_type,
           vendor_number type zap_de_vendor_number,
         end of  ty_ecc_determinations.

  types: ty_tt_val       type table for read result zap_r_val,
         ty_tt_val_items type table for read result zap_r_val\_Items,
         ty_tt_val_logs  type standard table of ZAP_B_VAL_log.


  class-methods:

    rap_validations importing it_val_head  type ty_tt_val
                              it_val_items type ty_tt_val_items
                    changing  ct_val_logs  type ty_tt_val_logs,

    ecc_validations importing it_val_head           type ty_tt_val
                              it_val_items          type ty_tt_val_items
                    changing  ct_val_logs           type ty_tt_val_logs
                              cs_ecc_determinations type ty_ecc_determinations.
protected section.
private section.

  class-methods rap_validate_header
    importing
      it_val_head type ty_tt_val
    changing
      ct_val_logs type ty_tt_val_logs.

  class-methods rap_validate_items
    importing
      it_val_head  type ty_tt_val
      it_val_items type ty_tt_val_items
    changing
      ct_val_logs  type ty_tt_val_logs.

endclass.

class zap_cl_ap_validation implementation.


method rap_validations.


*Validate the header and build the parking document
  rap_validate_header( exporting it_val_head = it_val_head
                       changing  ct_val_logs = ct_val_logs ).

*Validate the item
  rap_validate_items( exporting it_val_head  = it_val_head
                                it_val_items = it_val_items
                      changing  ct_val_logs  = ct_val_logs ).
endmethod.


method ecc_validations.

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


  types: begin of ty_val_log,
           messagenumber   type symsgno,
           detailedmessage type zap_de_detailed_message,
         end of ty_val_log.

  data: ld_complete     type abap_bool,
        ld_msg          type c length 255,
        ls_val_item_rfc type ty_val_item_rfc,
        ls_val_head_rfc type ty_val_head_rfc,
        lt_val_item_rfc type standard table of ty_val_item_rfc,
        lt_val_logs_rfc type standard table of ty_val_log.

  data(ls_val_head) = it_val_head[  1 ].
  check sy-subrc eq 0.
  clear cs_ecc_determinations.

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

  loop at it_val_items into data(ls_val_item).
    ls_val_item_rfc-item_description = ls_val_item-ItemDescription.
    ls_val_item_rfc-item_nett_value  = ls_val_item-ItemNettValue.
    ls_val_item_rfc-item_quantity    = ls_val_item-ItemQuantity.
    append ls_val_item_rfc to lt_val_item_rfc.
  endloop.

  try.
      data(lo_destination) = cl_rfc_destination_provider=>create_by_comm_arrangement( comm_scenario = 'ZAP_RFC_ECC_OUT'   " Communication scenario
                                                                                      service_id    = 'ZAP_RFC_OUTBOUND_OCR_VAL_SRFC' ).   " Outbound service

*Call the remote Function Module
      data(ld_destination) = lo_destination->get_destination_name( ).
      call function '/PNP/FI_AP_VALIDATION'
        destination ld_destination
        exporting
          it_val_items          = lt_val_item_rfc
        importing
          et_val_logs           = lt_val_logs_rfc
          ed_complete           = ld_complete
        changing
          cs_val_head           = ls_val_head_rfc
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
      move-corresponding: lt_val_logs_rfc to ct_val_logs keeping target lines,
                          ls_val_head_rfc to cs_ecc_determinations.

    catch cx_rfc_dest_provider_error.
      append value #( MessageNumber = '095' DetailedMessage = |Unable to Determine Remote ECC Destination| ) to ct_val_logs.
  endtry.

endmethod.


method rap_validate_header.

*Validate the header
  data(ls_val_head) = it_val_head[  1 ].
*
*P U R C H A S E   O R D E R   N U M B E R
* Cannot be blank and Cannot be all zeros
*Must be at least 9 long and must be numerical.
  if ls_val_head-PurchaseOrderNumber is initial
  or ls_val_head-PurchaseOrderNumber co '0'.
    append value #( MessageNumber = '101' DetailedMessage = 'Purchase Order cannot be blank or all zeroes' ) to ct_val_logs.
  elseif ls_val_head-PurchaseOrderNumber cn '0123456789' .
    append value #( MessageNumber = '102' DetailedMessage = 'Purchase Order must be numeric' )               to ct_val_logs.
  elseif ls_val_head-PurchaseOrderNumber+0(2) eq '00' .
    append value #( MessageNumber = '103' DetailedMessage = 'Purchase Order is too short' )                  to ct_val_logs.
  endif.

*I N V O I C E   R E F E R E N C E
*Cannot be blank or empty
  if ls_val_head-InvoiceReference is initial.
    append value #( MessageNumber = '104' DetailedMessage = 'Invoice Reference Is required' ) to ct_val_logs.
  endif.

*I N V O I C E   D A T E
*Cannot be empty and must be a valid date
  if ls_val_head-InvoiceDate is initial
  or  ls_val_head-InvoiceDate co '0'.
    append value #( MessageNumber = '105' DetailedMessage = 'Invoice Date is required' ) to ct_val_logs.
*    elseif is_valid_date( id_date = conv #( ls_val_head-invoice_date ) ) eq abap_false.
*      append value #( MessageNumber = '106' DetailedMessage = 'Invoice Date is invalid' ) to ct_val_logs.
  endif.

*T O T A L   A M O U N T
  if ls_val_head-TotalVatInclusive le 0.
    append value #( MessageNumber = '107' DetailedMessage = 'VAT Inclusive Total must be greater than R0.00 ' ) to ct_val_logs.
  elseif ls_val_head-TotalVatInclusive lt ls_val_head-VatValue.
    append value #( MessageNumber = '108' DetailedMessage = 'VAT Inclusive Total must be greater than VAT Total' ) to ct_val_logs.
  endif.

* V A T   V A L U E
  if ls_val_head-VatValue ge ls_val_head-TotalVatInclusive.
    append value #( MessageNumber = '109' DetailedMessage = 'VAT Total is greater or equal VAT Inclusive Total' ) to ct_val_logs.
  endif.

* V E N D O R   N A M E
  if ls_val_head-VendorName is initial
  and ls_val_head-AcknowledgeWarning = abap_false.            "Ignore this one if selected
    append value #( MessageNumber = '110' DetailedMessage = 'Vendor name is blank' ) to ct_val_logs.
  endif.

endmethod.


method rap_validate_items.
*Validate the line items

  data: ld_tot_item_nett_value  type zap_de_val_total_vat_inclusive.
  if it_val_items  is initial.
    append value #( MessageNumber = '151' DetailedMessage = 'At least one line item required' ) to ct_val_logs.
  endif.

* D E S C R I P T I O N
*Each line item must have description, but if at least ONE item has both description and value then that is allowed????
  loop at it_val_items transporting no fields where ItemDescription is not initial
                                               and  ItemNettValue is not initial.
    exit.
  endloop.
  if sy-subrc ne 0.
    loop at it_val_items transporting no fields where ItemDescription is not initial.
      exit.
    endloop.
    if sy-subrc eq 0.
      append value #( MessageNumber = '152' DetailedMessage = 'Line item description required' ) to ct_val_logs.
    endif.
  endif.

*Total the line items
  data(ls_val_head) = it_val_head[  1 ].
  loop at it_val_items into data(ls_val_item).
    ld_tot_item_nett_value = ld_tot_item_nett_value + ls_val_item-ItemNettValue.
  endloop.
  if ld_tot_item_nett_value ne ( ls_val_head-TotalVatInclusive - ls_val_head-VatValue )
  and ls_val_head-AcknowledgeWarning = abap_false.            "Ignore this one if selected
    append value #( MessageNumber = '153' DetailedMessage = 'Invoice does not Balance' ) to ct_val_logs.
  endif.
endmethod.
endclass.
