CLASS lhc_Supplement DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS calculateTotalSupplPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Supplement~calculateTotalSupplPrice.

ENDCLASS.

CLASS lhc_Supplement IMPLEMENTATION.

  METHOD calculateTotalSupplPrice.

    IF keys IS NOT INITIAL.
      " Se llama al método de la clase auxiliar creada previamente
      " Se recoore la tabla interna KEYS agrupando la información por el travel_id
      zcl_aux_travel_det_jpvv=>calculate_price( it_travel_id =
                                        VALUE #( FOR GROUPS <fs_booking_suppl> OF booking_key IN keys
                                                     GROUP BY booking_key-travel_id WITHOUT MEMBERS ( <fs_booking_suppl> )  )  ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.

CLASS lsc_supplement DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PUBLIC SECTION.

    CONSTANTS:
      create TYPE string VALUE 'C',
      update TYPE string VALUE 'U',
      delete TYPE string VALUE 'D'.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_supplement IMPLEMENTATION.


  METHOD save_modified.

    DATA: lt_supplements TYPE STANDARD TABLE OF zbooksuppl_jpvv,
          lv_op_type     TYPE zde_flag_jpvv,
          lv_updated      TYPE zde_flag_jpvv.

    IF create-supplement IS NOT INITIAL.
      lt_supplements = CORRESPONDING #( create-supplement ).
      lv_op_type = lsc_supplement=>create.
    ENDIF.

    IF update-supplement IS NOT INITIAL.
      lt_supplements = CORRESPONDING #( update-supplement ).
      lv_op_type = lsc_supplement=>update.
    ENDIF.

    IF delete-supplement IS NOT INITIAL.
      lt_supplements = CORRESPONDING #( delete-supplement ).
      lv_op_type = lsc_supplement=>delete.
    ENDIF.

    IF lt_supplements[] IS NOT INITIAL.
      CALL FUNCTION 'Z_SUPPL_JPVV'
        EXPORTING
          it_supplements = lt_supplements
          iv_op_type     = lv_op_type
        IMPORTING
          ev_update      = lv_updated.

      IF lv_updated EQ abap_true.
*        reported-supplement[ 1 ]-
      ENDIF.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
