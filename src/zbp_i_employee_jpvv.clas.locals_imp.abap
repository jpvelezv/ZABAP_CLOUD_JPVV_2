CLASS lhc_Employee DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Employee RESULT result.

ENDCLASS.

CLASS lhc_Employee IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

ENDCLASS.
