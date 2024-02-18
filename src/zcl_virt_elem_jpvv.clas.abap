CLASS zcl_virt_elem_jpvv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_sadl_exit_calc_element_read.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_VIRT_ELEM_JPVV IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.

    IF iv_entity = 'Z_C_TRAVEL_JPVV'.

      " Se comprueba la entidad, para realizar la lógica correspondiente
      LOOP AT it_requested_calc_elements INTO DATA(ls_calc_elements) .

        " Se hacen las comprobaciones de los elementos
        IF ls_calc_elements EQ 'DISCOUNTPRICE'.
          " Se indican los campos que necesitamos utilizar en la lógica del siguiente método
          APPEND 'TOTALPRICE' TO et_requested_orig_elements.
        ENDIF.

      ENDLOOP.

    ENDIF.

  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~calculate.

    DATA: lt_original_data TYPE STANDARD TABLE OF z_c_travel_jpvv WITH DEFAULT KEY.

    " Volcamos los datos recibidos por parámetros a la tabla interna
    lt_original_data = CORRESPONDING #( it_original_data ).

    " Recorremos los valores para hacer el descuento del 105 sobre el precio total
    " y almacenamos el resultado en el nuevo campo (Objeto virtual) creado
    LOOP AT lt_original_data ASSIGNING FIELD-SYMBOL(<fs_original_data>).
      <fs_original_data>-DiscountPrice = <fs_original_data>-TotalPrice - ( <fs_original_data>-TotalPrice * ( 1 / 10 ) ).
    ENDLOOP.

    " Volcamos la información calculada anteriormente a la tabla de retorno
    ct_calculated_data = CORRESPONDING #( lt_original_data ).

  ENDMETHOD.
ENDCLASS.
