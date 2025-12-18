class zap_cl_bgpf_utilities definition
  public
  final
  create public.

  public section.
    class-methods: register_operation importing is_register_parameters type zap_s_bgpf_register_parameters
                                      raising   zfi_cx.

  protected section.
  private section.
ENDCLASS.



CLASS ZAP_CL_BGPF_UTILITIES IMPLEMENTATION.


  method register_operation.

*Local Data
    data: lr_operation       type ref to if_bgmc_op_single_tx_uncontr,
          lr_process         type ref to if_bgmc_process_single_op,
          lr_process_factory type ref to if_bgmc_process_factory.

    try.

        lr_operation = new zap_cl_bgpf_operations( is_register_parameters ).

        lr_process_factory = cl_bgmc_process_factory=>get_default( ).

        lr_process = lr_process_factory->create( ).

        lr_process->set_name( 'AP Operation' )->set_operation_tx_uncontrolled( lr_operation ).

        lr_process->save_for_execution( ).

      catch cx_bgmc into data(lr_cx_bgmc).

    endtry.


  endmethod.
ENDCLASS.
