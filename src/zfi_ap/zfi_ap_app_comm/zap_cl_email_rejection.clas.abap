class zap_cl_email_rejection definition
  public
  inheriting from zca_cl_email_srv
  final
  create public .

  public section.

    methods constructor.

    methods send_email
      importing id_comm_uuid type sysuuid_x16
      raising   zfi_cx
                zca_cx.

  protected section.
  private section.

    data: ld_msg_dummy type bapi_msg.

endclass.



class zap_cl_email_rejection implementation.

  method constructor.

    super->constructor( ).

  endmethod.

  method send_email.

*Local Data
    data: lt_recipient_email_addr type zca_tt_cota_recipient_addr.
    data: ls_comm_details     type zap_a_comm,
          ls_email_tml_config type zca_a_email_tml,
          ls_email_que        type zca_a_email_que.
    data: ld_subject_line      type zca_de_email_subject_line,
          ld_sender_email_addr type zca_de_sender_email_addr,
          ld_email_body        type string,
          ld_ref_uuid          type sysuuid_x16.

*Retrieve communication details
    select single *
      from zap_a_comm
     where comm_uuid = @id_comm_uuid
      into @ls_comm_details.
    if sy-subrc <> 0.
      message e013(zca_email_srv) with id_comm_uuid into ld_msg_dummy. "Communication Details Not Found for UUID &1.
      zfi_cx=>raise_with_sysmsg(  ).
    endif.

*Build email body
*.retrieve email template configuration
    select single *
      from zca_a_email_tml
     where template_id = ''
      into @ls_email_tml_config.
    if sy-subrc <> 0.
      message e011(zca_email_srv) with '' into ld_msg_dummy. "Email Template &1 Not Found.
      zfi_cx=>raise_with_sysmsg(  ).
    endif.

*Build subject line
    ld_subject_line = 'Invoice Number' && | | && ls_comm_details-invoice_reference && | | && '||' && | | && 'Notice of Rejected Invoice'.

*Retrieve sender email address








*Retrieve vendor email address










*Send email
    queue_email( exporting id_template_id          = ''
                           id_subject_line         = ld_subject_line
                           id_sender_email_addr    = ld_sender_email_addr
                           it_recipient_email_addr = lt_recipient_email_addr
                           id_email_body           = ld_email_body
                           id_ref_uuid             = id_comm_uuid
                           id_process_immediately  = abap_true
                 importing es_email_que            = ls_email_que ).
*catch zca_cx.














  endmethod.

endclass.
