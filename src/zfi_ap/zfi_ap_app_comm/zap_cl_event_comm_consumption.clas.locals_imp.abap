*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
class lcl_comm_event_consumption definition inheriting from cl_abap_behavior_event_handler.
  private section.
    methods respond_to_vendor for entity event send_email for zap_r_comm~respond_to_vendor.
endclass.

class lcl_comm_event_consumption implementation.

  method respond_to_vendor.





  endmethod.

endclass.
