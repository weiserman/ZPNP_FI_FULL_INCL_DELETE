class zap_cl_ap_log_utilities definition
  public
  final
  create public .

  public section.
    constants: gc_field_message_type(20)     type c       value 'MESSAGETYPE',
               gc_field_message_number(20)   type c       value 'MESSAGENUMBER',
               gc_default_log_status_success type symsgty value 'S',
               gc_default_log_status_error   type symsgty value 'E'.

    class-methods: determine_log_hdr_status importing it_log           type standard table
                                            returning value(rd_status) type zap_de_comm_status.

  protected section.
  private section.
ENDCLASS.



CLASS ZAP_CL_AP_LOG_UTILITIES IMPLEMENTATION.


  method determine_log_hdr_status.

*Local Data
    types: begin of ty_message,
             message_type   type symsgty,
             message_number type symsgno,
           end of ty_message.

    types: tt_messages type standard table of ty_message.

    data: lt_messages type tt_messages.
    data: ls_message type ty_message.
    field-symbols: <ld_message_type>   type symsgty,
                   <ld_message_number> type symsgno.

*Iterate through log entries to build table of messages
    loop at it_log assigning field-symbol(<ls_log>).

*.assign fields
      assign: component gc_field_message_type   of structure <ls_log> to <ld_message_type>,
              component gc_field_message_number of structure <ls_log> to <ld_message_number>.

      append value #( message_type   = <ld_message_type>
                      message_number = <ld_message_number> ) to lt_messages.
    endloop.

*Determine header status
*.rejected
    loop at lt_messages into ls_message where message_number between 900 and 999.
      rd_status = zap_if_constants=>system_status-rejected.

      return.
    endloop.

*.error
    loop at lt_messages into ls_message where message_number between 100 and 899.
      rd_status = zap_if_constants=>system_status-error.

      return.
    endloop.

*.success
    loop at lt_messages into ls_message where message_number = zap_if_constants=>system_status-success.
      rd_status = zap_if_constants=>system_status-success.

      return.
    endloop.

*.in_progress
    loop at lt_messages into ls_message where message_number = zap_if_constants=>system_status-in_progress.
      rd_status = zap_if_constants=>system_status-in_progress.

      return.
    endloop.

*.warning
*    loop at lt_messages into ls_message where message_number = zap_if_constants=>system_status-warning.
*      rd_status = zap_if_constants=>system_status-warning.
*
*      return.
*    endloop.

*.completed
    loop at lt_messages into ls_message where message_number = zap_if_constants=>system_status-completed.
      rd_status = zap_if_constants=>system_status-completed.

      return.
    endloop.

*If no success messages found, set error status
    if rd_status is initial.
      rd_status = zap_if_constants=>system_status-error.
    endif.

  endmethod.
ENDCLASS.
