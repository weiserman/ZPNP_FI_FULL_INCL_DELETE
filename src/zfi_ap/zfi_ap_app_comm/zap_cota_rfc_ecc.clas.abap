class ZAP_COTA_RFC_ECC definition
  public
  inheriting from CL_COMMUNICATION_TARGET_RFCLV5
  create public .

public section.

  methods CONSTRUCTOR
    importing
      value(APPLICATION_DESTINATION) type SAPPDESTNAME optional
    raising
      CX_APPDESTINATION
      CX_COMMUNICATION_TARGET_ERROR .
protected section.
private section.

  constants CID type CL_COMMUNICATION_TARGET_LV5=>NAME_TYPE value 'ZAP_COTA_RFC_ECC' ##NO_TEXT.
  constants CMAINTYPE type MAIN_TYPE value RFC ##NO_TEXT.
  constants CMULTIPLE_APPDESTS type ABAP_BOOL value 'X' ##NO_TEXT.
  constants CMULTITENANCY_MODE type CL_COMMUNICATION_TARGET_ROOT=>MULTITENANCY_MODE_TYPE value CL_COMMUNICATION_TARGET_ROOT=>CLIENT_DEPENDENT ##NO_TEXT.
  constants Ccreated_by_cota type CL_COMMUNICATION_TARGET_LV5=>NAME_TYPE value 'ZAP_COTA_RFC_ECC' ##NO_TEXT.
ENDCLASS.



CLASS ZAP_COTA_RFC_ECC IMPLEMENTATION.


  method CONSTRUCTOR.
  SUPER->constructor(
    EXPORTING
      id = cid
      SECKEY = CONV int8( '6256127051873842186-' )
      created_by_cota = Ccreated_by_cota
      multiple_appdests = CMULTIPLE_APPDESTS
      application_destination = application_destination
     ).
  endmethod.
ENDCLASS.
