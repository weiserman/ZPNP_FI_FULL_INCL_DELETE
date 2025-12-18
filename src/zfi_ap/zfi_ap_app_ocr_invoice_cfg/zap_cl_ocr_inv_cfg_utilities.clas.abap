class zap_cl_ocr_inv_cfg_utilities definition
  public
  final
  create public .

  public section.
    constants: gc_ocr_type_default type zap_de_ocr_type value 'DEFAULT'.

    class-methods: determine_ocr_invoice_config importing id_OCR_TYPE       type zap_de_ocr_type
                                                          id_comm_uuid      type sysuuid_x16
                                                returning value(rs_ocr_cfg) type zap_a_ocr_cfg
                                                raising   zap_cx.

  protected section.
  private section.
ENDCLASS.



CLASS ZAP_CL_OCR_INV_CFG_UTILITIES IMPLEMENTATION.


  method determine_ocr_invoice_config.

*Local Data
    data: ld_msg_dummy type string.

*Retrieve configuration for the specified OCR type
    select single *
    from zap_a_ocr_cfg
    where ocr_type = @id_ocr_type
    into @rs_ocr_cfg.
    if rs_ocr_cfg is initial.
      message e001(zap_ocr_invoice_cfg) with id_ocr_type into ld_msg_dummy. "No OCR Invoice Config Found For Type, &1.
      zap_cx=>raise_with_sysmsg(  ).
    endif.

  endmethod.
ENDCLASS.
