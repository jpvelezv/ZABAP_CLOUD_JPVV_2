CLASS zcl_ext_update_ent_jpvv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_EXT_UPDATE_ENT_JPVV IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    MODIFY ENTITIES OF z_i_travel_jpvv
        ENTITY Travel
        UPDATE FIELDS ( agency_id description )
        WITH VALUE #( ( travel_id = '000000001'
                        agency_id = '070017'
                        description = 'New external Update' ) )
        FAILED DATA(failed)
        REPORTED DATA(reported).

    READ ENTITIES OF z_i_travel_jpvv
        ENTITY Travel
        FIELDS ( agency_id description )
        WITH VALUE #( ( travel_id = '000000001' ) )
        RESULT DATA(lt_travel_data)
        FAILED failed
        REPORTED reported.

    " Se controla manualmente el commit entities porque estamos fuera
    " de las clases de comportamiento
    COMMIT ENTITIES.

    IF failed IS INITIAL.
      out->write( 'Commit Sucessfull' ).
    ELSE.
      out->write( 'Commit Failed' ).
    ENDIF.


  ENDMETHOD.
ENDCLASS.
