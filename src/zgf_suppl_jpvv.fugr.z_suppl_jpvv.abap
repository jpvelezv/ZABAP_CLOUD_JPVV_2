FUNCTION z_suppl_jpvv.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IT_SUPPLEMENTS) TYPE  ZTT_SUPPL_JPVV
*"     REFERENCE(IV_OP_TYPE) TYPE  ZDE_FLAG_JPVV
*"  EXPORTING
*"     REFERENCE(EV_UPDATE) TYPE  ZDE_FLAG_JPVV
*"----------------------------------------------------------------------
  CONSTANTS:
    BEGIN OF lc_constants,
      create TYPE zde_flag_jpvv VALUE 'C',
      update TYPE zde_flag_jpvv VALUE 'U',
      delete TYPE zde_flag_jpvv VALUE 'D',
    END OF lc_constants.

  IF it_supplements IS INITIAL.
    RETURN.
  ENDIF.

  CASE iv_op_type.
    WHEN lc_constants-create.
      INSERT zbooksuppl_jpvv FROM TABLE @it_supplements.
    WHEN lc_constants-update.
      UPDATE zbooksuppl_jpvv FROM TABLE @it_supplements.
    WHEN lc_constants-delete.
      DELETE zbooksuppl_jpvv FROM TABLE @it_supplements.
  ENDCASE.

  IF sy-subrc EQ 0.
    ev_update = abap_true.
  ENDIF.

ENDFUNCTION.
