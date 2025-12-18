class zfi_cx definition
  public
  inheriting from cx_static_check
  final
  create public .

  public section.

    interfaces if_t100_message .
    interfaces if_t100_dyn_msg .

    types begin of ty_symsg_out.
    include type symsg.
    types:  message type bapi_msg.
    types end of ty_symsg_out.

    types: tt_symsg_out type standard table of ty_symsg_out with default key.
    data: mt_symsg type symsg_tab.

    methods constructor
      importing
        !textid   like if_t100_message=>t100key optional
        !previous like previous optional
        !it_symsg type symsg_tab optional.

    class-methods raise
      importing
                it_symsg type symsg_tab
      raising   zfi_cx.

    class-methods raise_with_sysmsg
      raising zfi_cx.

    class-methods raise_if_errors
      importing it_symsg type symsg_tab
      raising   zfi_cx.

    methods get_messages
      importing
        id_build_texts      type abap_bool default abap_false
      returning
        value(rt_symsg_out) type zfi_cx=>tt_symsg_out.

  protected section.
  private section.
ENDCLASS.



CLASS ZFI_CX IMPLEMENTATION.


  method constructor ##ADT_SUPPRESS_GENERATION.
    super->constructor(
    previous = previous
    ).
    me->mt_symsg = it_symsg.
    clear me->textid.
    if textid is initial.
      if_t100_message~t100key = if_t100_message=>default_textid.
    else.
      if_t100_message~t100key = textid.
    endif.
  endmethod.


  method raise.

    raise exception type zfi_cx
      exporting
        it_symsg = it_symsg.

  endmethod.


  method raise_with_sysmsg.

*Local Data
    data: lt_symsg type symsg_tab.

    lt_symsg = value #( ( msgty = sy-msgty
                           msgid = sy-msgid
                           msgno = sy-msgno
                           msgv1 = sy-msgv1
                           msgv2 = sy-msgv2
                           msgv3 = sy-msgv3
                           msgv4 = sy-msgv4 ) ).

    raise exception type zfi_cx
      exporting
        it_symsg = lt_symsg.

  endmethod.


  method raise_if_errors.

    loop at it_symsg transporting no fields where msgty ca 'EAX'. exit. endloop.
    if sy-subrc = 0.
      raise exception type zfi_cx
        exporting
          it_symsg = it_symsg.
    endif.

  endmethod.


  method get_messages.

*Local data
    data: ls_symsg_out type ty_symsg_out.

    loop at me->mt_symsg into data(ls_symsg).
      clear: ls_symsg_out.

      ls_symsg_out = corresponding #( ls_symsg ).

      if id_build_texts = abap_true.
        message id ls_symsg_out-msgid type ls_symsg_out-msgty number ls_symsg_out-msgno
              with ls_symsg_out-msgv1 ls_symsg_out-msgv2 ls_symsg_out-msgv3 ls_symsg_out-msgv4
              into ls_symsg_out-message.
      endif.

      append ls_symsg_out to rt_symsg_out.
    endloop.

  endmethod.
ENDCLASS.
