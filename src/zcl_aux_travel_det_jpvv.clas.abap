CLASS zcl_aux_travel_det_jpvv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      tt_travel_reported      TYPE TABLE FOR REPORTED z_i_travel_jpvv,
      tt_booking_reported     TYPE TABLE FOR REPORTED z_i_booking_jpvv,
      tt_supplements_reported TYPE TABLE FOR  REPORTED z_i_booksuppl_jpvv,
      tt_travel_id            TYPE TABLE OF /dmo/travel_id.

    CLASS-METHODS calculate_price IMPORTING it_travel_id TYPE tt_travel_id.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_AUX_TRAVEL_DET_JPVV IMPLEMENTATION.


  METHOD calculate_price.

    DATA:
      lv_total_booking_price TYPE /dmo/total_price,
      lv_total_suppl_price   TYPE /dmo/total_price.

    IF it_travel_id IS INITIAL.
      RETURN.
    ENDIF.

    READ ENTITIES OF z_i_travel_jpvv
        ENTITY Travel
        FIELDS ( travel_id currency_code )
        WITH VALUE #( FOR ls_travel_id IN it_travel_id ( travel_id = ls_travel_id ) )
        RESULT DATA(lt_read_travel).

    " Se leen las reservas que tienen que ver con el/los viajes recuperados
    " Solo aquellos viajes que han sido modificados
    READ ENTITIES OF z_i_travel_jpvv
        ENTITY Travel BY \_Booking
        FROM VALUE #( FOR lv_travel_id IN it_travel_id (
                            travel_id = lv_travel_id
                            %control-flight_price  = if_abap_behv=>mk-on
                            %control-currency_code = if_abap_behv=>mk-on ) )
        RESULT DATA(lt_read_booking).

    " Se recorren las reservas recuperadas anteriormente
    LOOP AT lt_read_booking INTO DATA(ls_booking)
        GROUP BY ls_booking-travel_id INTO DATA(lv_travel_key).

      " Se asigna la estructura del viaje en un field-symbol para actualizar directamente sobre el fs
      ASSIGN lt_read_travel[ KEY entity COMPONENTS travel_id = lv_travel_key ]
        TO FIELD-SYMBOL(<ls_travel>).

      LOOP AT GROUP lv_travel_key INTO DATA(ls_booking_result)
          GROUP BY ls_booking_result-currency_code INTO DATA(lv_curr).
        " Se recorren las reservas agrupadas por monedas

        " Se inicializa por cada reserva
        lv_total_booking_price = 0.

        LOOP AT GROUP lv_curr INTO DATA(ls_booking_line).
          " Se recorre la agrupación de cada moneda y se incremente el precio de cada reserva
          lv_total_booking_price += ls_booking_line-flight_price.
        ENDLOOP.

        " Se comprueba la moneda de la reserva, si es la misma se incrementa
        " En caso contrario, se realiza la conversión a la moneda del viaje y después se incrementa"
        IF lv_curr EQ <ls_travel>-currency_code.
          <ls_travel>-total_price += lv_total_booking_price.
        ELSE.
          " Se realiza la conversión de la moneda
          /dmo/cl_flight_amdp=>convert_currency(
              EXPORTING
                  iv_amount                 = lv_total_booking_price
                  iv_currency_code_source   = lv_curr
                  iv_currency_code_target   = <ls_travel>-currency_code
                  iv_exchange_rate_date     = cl_abap_context_info=>get_system_date( )
              IMPORTING
                  ev_amount                 = DATA(lv_amount_converted)
          ).

          <ls_travel>-total_price += lv_amount_converted.

        ENDIF.

      ENDLOOP.

    ENDLOOP.


    " Se leen los suplementos que tienen que ver con el/los viajes/reservas recuperados
    " Solo aquellos suplementos que han sido modificados el precio o la moneda
    READ ENTITIES OF z_i_travel_jpvv
        ENTITY Booking BY \_BookingSupplement
        FROM VALUE #( FOR ls_travel IN lt_read_booking (
                            travel_id                = ls_travel-travel_id
                            booking_id               = ls_travel-booking_id
                            %control-price           = if_abap_behv=>mk-on
                            %control-currency        = if_abap_behv=>mk-on ) )
        RESULT DATA(lt_read_supplements).

    " Se reccorren los suplementos recuperados anteriormente
    LOOP AT lt_read_supplements INTO DATA(ls_booking_suppl)
        GROUP BY ls_booking_suppl-travel_id INTO lv_travel_key.

      " Se asigna la estructura del suplemento en un field-symbol para actualizar directamente sobre el fs
      ASSIGN lt_read_travel[ KEY entity COMPONENTS travel_id = lv_travel_key ] TO <ls_travel>.

      LOOP AT GROUP lv_travel_key INTO DATA(ls_supplements_result)
          GROUP BY ls_supplements_result-currency INTO lv_curr.
        " Se recorren los suplementos agrupadas por monedas

        " Se inicializa por cada suplemento
        lv_total_suppl_price = 0.

        LOOP AT GROUP lv_curr INTO DATA(ls_supplement_line).
          " Se recorre la agrupación de cada moneda y se incremente el precio del suplemento
          lv_total_suppl_price += ls_supplement_line-price.
        ENDLOOP.

        " Se comprueba la moneda del suplemento, si es la misma se incrementa
        " En caso contrario, se realiza la conversión a la moneda del viaje y después se incrementa"
        IF lv_curr EQ <ls_travel>-currency_code.
          <ls_travel>-total_price += lv_total_suppl_price.
        ELSE.
          " Se realiza la conversión de la moneda
          /dmo/cl_flight_amdp=>convert_currency(
          EXPORTING
              iv_amount                 = lv_total_suppl_price
              iv_currency_code_source   = lv_curr
              iv_currency_code_target   = <ls_travel>-currency_code
              iv_exchange_rate_date     = cl_abap_context_info=>get_system_date( )
          IMPORTING
              ev_amount                 = lv_amount_converted ).

          <ls_travel>-total_price += lv_amount_converted.

        ENDIF.

      ENDLOOP.

    ENDLOOP.

    " Se modifica la entidad raiz con el valor del total price
    MODIFY ENTITIES OF z_i_travel_jpvv
        ENTITY Travel
        UPDATE FROM VALUE #( FOR ls_travel_bo IN lt_read_travel (
                                    travel_id            = ls_travel_bo-travel_id
                                    total_price          = ls_travel_bo-total_price
                                    %control-total_price = if_abap_behv=>mk-on ) ).

  ENDMETHOD.
ENDCLASS.
