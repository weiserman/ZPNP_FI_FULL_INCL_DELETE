class zap_cl_ap_ocr_build_val definition

  public
  final
  create public .

  public section.

*For now use the OCR tables
    types: ty_tt_val_create       type table for create zap_r_val,
           ty_tt_val_create_items type table for create zap_r_val\_Items,
           ty_tt_val_create_logs  type table for create zap_r_val\_Logs.
    class-methods:

      build_validation_data importing id_comm_guid        type sysuuid_x16
                            exporting et_val_create       type ty_tt_val_create
                                      et_val_create_items type ty_tt_val_create_items
                                      et_val_create_log   type ty_tt_val_create_logs.
  protected section.
  private section.

    class-methods build_val_header
      importing
        is_ocr_head   type ty_ocr_head
      exporting
        et_val_create type ty_tt_val_create.
*      changing
*        ct_val_logs  type ty_tt_val_logs.

    class-methods build_val_items
      importing
        it_ocr_items        type ty_tt_ocr_items
      exporting
        et_val_create_items type ty_tt_val_create_items.

    class-methods format_as_number
      importing
                id_input         type c
      returning value(rd_output) type string.

    class-methods format_ref_number
      importing
                id_ref_no type c
      exporting ed_ref_no type c.

    class-methods format_po_number
      importing
                id_po_no type c
      exporting ed_po_no type c.

    class-methods add_leading_zero
      importing
                id_input         type string
                id_length        type i default 10
      returning value(rd_output) type string.

    class-methods is_qty_valid
      importing
                id_input                type zap_de_ocr_item_quantity
      returning value(rd_item_quantity) type zap_de_val_item_quantity.

    class-methods is_amt_valid
      importing
                id_input             type zap_de_ocr_item_nett_value
      returning value(rd_item_value) type zap_de_val_item_nett_value.

    class-methods is_valid_date
      importing id_date         type d
      returning value(rd_valid) type abap_bool.

    class-methods format_vat_number
      importing
        id_pnp_vat_no  type c
        id_vend_vat_no type c
      exporting
        ed_pnp_vat_no  type c
        ed_vend_vat_no type c.

    class-methods:
      read_ocr importing id_comm_guid type sysuuid_x16
               exporting es_ocr_head  type ty_ocr_head
                         et_ocr_items type ty_tt_ocr_items
                         et_ocr_logs  type ty_tt_ocr_logs.
endclass.



class zap_cl_ap_ocr_build_val implementation.

  method build_validation_data.

    clear: et_val_create, et_val_create_items, et_val_create_log.

*Read the OCR Data
    read_ocr( exporting id_comm_guid = id_comm_guid
              importing es_ocr_head  = data(ls_ocr_head)
                        et_ocr_items = data(lt_ocr_items)
                        et_ocr_logs  = data(lt_ocr_logs) ).

*Get validation header from OCR
    build_val_header( exporting is_ocr_head   = ls_ocr_head
                      importing et_val_create = et_val_create ).
*                     changing ct_val_logs  = et_val_logs ).

*Get the items from the OCR
    build_val_items( exporting it_ocr_items        = lt_ocr_items
                     importing et_val_create_items = et_val_create_items ).

*Validate data initial - this will be done in the BDEF of the entity
*    et_val_create_log = value #( ( %cid_ref   = 'VAL_HEAD_1'
*                                   %target = value #( ( %cid          = 'VAL_HEAD_1'
*                                                        MessageNumber = zap_if_constants=>system_status-in_progress
*                                                        DetailedMessage = 'Validation created - waiting validation'
*                                                        %control = value #( MessageNumber = if_abap_behv=>mk-on
*                                                                            DetailedMessage  = if_abap_behv=>mk-on ) ) ) ) ).
  endmethod.


  method read_ocr.

    select single * from zap_a_ocr_head
     where parent_uuid = @id_comm_guid
      into @es_ocr_head.

    select * from zap_a_ocr_item
    where ocr_uuid = @es_ocr_head-ocr_uuid
    into table @et_ocr_items.

  endmethod.


  method build_val_header.
*    data: ls_val_create   type line of ty_tt_val_create.
    data: ld_PurchaseOrderNumber type zap_de_val_purchase_order,
          ld_InvoiceReference    type zap_de_val_invoice_reference,
          ld_InvoiceDate         type zap_de_val_invoice_date,
          ld_TotalVatInclusive   type zap_de_val_total_vat_inclusive,
          ld_VatValue            type zap_de_val_vat_value.

*Purchase Order
    format_po_number( exporting id_po_no = is_ocr_head-purchase_order_number
                      importing ed_po_no = ld_PurchaseOrderNumber ).

    format_ref_number( exporting id_ref_no = is_ocr_head-invoice_reference
                       importing ed_ref_no = ld_InvoiceReference ).

*Don't do this here but in ECC
*    format_vat_number( exporting id_pnp_vat_no  = is_ocr_head-pnp_vat_number
*                                 id_vend_vat_no = is_ocr_head-vendor_vat_number
*                       importing ed_pnp_vat_no  = ls_val_create-pnp_vat_number
*                                 ed_vend_vat_no = ls_val_create-vendor_vat_number ).


*Move in the date
    try.
        ld_InvoiceDate = is_ocr_head-invoice_date.
        if  is_valid_date( ld_InvoiceDate ) eq abap_false.
          clear ld_InvoiceDate.
        endif.
      catch cx_sy_conversion_error.
        clear ld_InvoiceDate.
    endtry.

*Move in the total
    try.
        ld_TotalVatInclusive = is_ocr_head-total_vat_inclusive.
      catch cx_sy_conversion_error.
        clear ld_TotalVatInclusive.
    endtry.

*Move in the VAT
    try.
        ld_VatValue = is_ocr_head-vat_value.
      catch cx_sy_conversion_error.
        clear ld_VatValue.
    endtry.

*Move the rest of the fields - they map directly:
    et_val_create = value #( ( %cid                    = 'VAL_HEAD_1'
                               PurchaseOrderNumber     = ld_PurchaseOrderNumber
                               InvoiceReference        = ld_InvoiceReference
                               InvoiceDate             = ld_InvoiceDate
                               TotalVatInclusive       = ld_TotalVatInclusive
                               VatValue                = ld_VatValue
                               VendorVatNumber         = is_ocr_head-vendor_vat_number
                               PnpVatNumber            = is_ocr_head-pnp_vat_number
                               ParentUuid              = is_ocr_head-parent_uuid
                               VendorName              = is_ocr_head-vendor_name
                               %control = value #( PurchaseOrderNumber     = if_abap_behv=>mk-on
                                                   InvoiceReference        = if_abap_behv=>mk-on
                                                   InvoiceDate             = if_abap_behv=>mk-on
                                                   TotalVatInclusive       = if_abap_behv=>mk-on
                                                   VatValue                = if_abap_behv=>mk-on
                                                   VendorVatNumber         = if_abap_behv=>mk-on
                                                   PnpVatNumber            = if_abap_behv=>mk-on
                                                   ParentUuid              = if_abap_behv=>mk-on
                                                   VendorName              = if_abap_behv=>mk-on
                                                      ) ) ).

  endmethod.


  method build_val_items.

*    data: ls_val_create_item type line of ty_tt_val_create_items.
*    data ls_val_create_item type structure for create zap_r_val\_Items.

*    ls_val_create_item-%cid_ref   = 'VAL_HEAD_1'.
    et_val_create_items = value #( for ls_ocr_item in it_ocr_items index into ld_index
                                   ( %cid_ref   = 'VAL_HEAD_1'
                                     %target = value #( ( %cid          = |ITEM{  ld_index }|
                                                          ItemDescription = ls_ocr_item-item_description
                                                          ItemNettValue   = is_amt_valid( ls_ocr_item-item_nett_value )
                                                          ItemQuantity    = is_qty_valid( ls_ocr_item-item_quantity  )
                                                           %control       = value #( ItemDescription = if_abap_behv=>mk-on
                                                                                     ItemNettValue   = if_abap_behv=>mk-on
                                                                                     ItemQuantity    = if_abap_behv=>mk-on  ) ) ) ) ).
endmethod.

 method format_as_number.

    rd_output = id_input.
    try.
        data(lr_regex) =  cl_abap_regex=>create_pcre( pattern = '[^0-9]' ).
        replace all occurrences of regex lr_regex in rd_output with ''.
      catch cx_sy_regex cx_sy_invalid_regex_operation .
        clear rd_output.
    endtry.

  endmethod.

  method is_qty_valid.

    try.
        rd_item_quantity  = id_input.
      catch cx_sy_conversion_error.
        clear rd_item_quantity.
    endtry.

  endmethod.

  method is_amt_valid.

    try.
        rd_item_value  = id_input.
      catch cx_sy_conversion_error.
        clear rd_item_value.
    endtry.

  endmethod.

  method format_ref_number.

*Reference number
*1. 16 Characters
*2. If > 16 characters, trim from the left (keep rightmost 16 characters)
*3. Characters allowed:
*   Forward slashes: /
*   Hyphens/dashes: -
*   All alphanumeric characters
*   Periods: .
*   Underscores: _
    data ld_ref_no type string.
    clear ed_ref_no.
    ld_ref_no = id_ref_no.

    try.
        replace all occurrences of regex cl_abap_regex=>create_pcre( pattern = '[^[:alnum:]/._-]' )

                in ld_ref_no with ''.
      catch cx_sy_regex cx_sy_invalid_regex_operation .
        return.
    endtry.

    try.
        ld_ref_no = substring( val = ld_ref_no
                               off = nmax( val1 = strlen( ld_ref_no   ) - 16  val2 = 0 )
                               len = nmin( val1 = strlen( ld_ref_no   )  val2 = 16 ) ) .
      catch cx_sy_range_out_of_bounds.
        return.
    endtry.
    ed_ref_no = ld_ref_no.

  endmethod.


  method format_po_number.

*Characters Allowed:
*1.  Extract only numeric digits
*2.  Take rightmost 10 characters
*3.  Left pad with zeros to ensure exactly 10 digits
*4.  Final format must be: 0XXXXXXXXX (starting with 0)
    data ld_po_no type string.
    clear ed_po_no.
    ld_po_no = id_po_no.
    try.
        replace all occurrences of regex cl_abap_regex=>create_pcre( pattern = '[^0-9]' )
                in ld_po_no  with ''.
      catch cx_sy_regex cx_sy_invalid_regex_operation .
        return.
    endtry.

    try.
        ld_po_no = |{ substring( val = ld_po_no
                               off = nmax( val1 = strlen( ld_po_no ) - 10  val2 = 0 )
                               len = nmin( val1 = strlen( ld_po_no )  val2 = 10 ) ) alpha = in width = 10 }| .
      catch cx_sy_range_out_of_bounds.
        return.
    endtry.
    ed_po_no = ld_po_no.

  endmethod.

  method add_leading_zero.

  endmethod.


  method format_vat_number.

  endmethod.


  method is_valid_date.

    data: ld_date_in  type d,
          ld_date_out type string.
    ld_date_in = id_date.
    try.
        cl_abap_datfm=>conv_date_int_to_ext( exporting im_datint   = ld_date_in
                                                       im_datfmdes = cl_abap_datfm=>get_country_datfm( 'ZA' )
                                             importing ex_datext   = ld_date_out ).

      catch cx_abap_datfm_no_date cx_abap_datfm_invalid_date cx_abap_datfm_format_unknown cx_abap_datfm_ambiguous .
        rd_valid = abap_false.
    endtry.
    if ld_date_out is initial.
      rd_valid = abap_false.
    else.
      rd_valid = abap_true.
    endif.

  endmethod.
endclass.
