class zap_delete_test definition
  public
  final
  create public .

    PUBLIC SECTION.
      INTERFACES if_oo_adt_classrun.

  protected section.
  private section.
ENDCLASS.



CLASS ZAP_DELETE_TEST IMPLEMENTATION.


    method if_oo_adt_classrun~main.

update ZAP_A_COMM set CURRENT_STEP = 'INGESTION'
                where CURRENT_STEP = 'EMAIL_INGESTION'.
                commit work.

*    DATA lo_cota TYPE REF TO ZAP_COTA_OCR_INVOICE2.
*    DATA lt_output TYPE STANDARD TABLE OF string.
*
*check 1 = 1.
*    TRY.
*        lo_cota = NEW ZAP_COTA_OCR_INVOICE2( ).
*        DATA(lo_client) = lo_cota->create_web_http_client( ).
*
*        DATA(lo_request) = lo_client->get_http_request( ).
*lo_request->set_content_type( 'application/json' ).
*lo_request->set_text( |{ | "NAME": "VW",| &
*                      |    "DESCRIPTION": "New cars",| &
*                      |    "STATUS": "A",| &
*                      |    "PRICE": 723.99,| &
*                      |    "CURRENCY": "USD"|
*                      } |
*                     ).
*
*
*
*
*      data(lo_response) = lo_client->execute( if_web_http_client=>post ).
*      data(ls_status) = lo_response->get_status( ).
*
*    catch cx_communication_target_error into data(lx_communication_target_error).
*      append lx_communication_target_error->get_text( ) to lt_output.
*    catch cx_web_http_client_error into data(lx_web_http_client_error).
*      append lx_web_http_client_error->get_text( ) to lt_output.
*
*  endtry.
*
*
*  out->write( lo_response->get_text( ) ).
*
*

endmethod.
ENDCLASS.
