(define (problem problema2)
    (:domain dominio2)
    (:objects
        ; declarar las casillas del grid
        loc11 loc12 loc13 loc14 - localizacion
        loc21 loc22 loc23 loc24 - localizacion
        loc31 loc32 loc33 loc34 - localizacion
        loc44 - localizacion

        ; declaración de edificios
        centroDeMando1 extractor1 - edificio

        ; declaración de unidades
        VCE1 VCE2 - unidad
    )
    (:init

        ; asignar tipo a cada variable
        (tipoEdificio centroDeMando1 centroDeMando)
        (tipoEdificio extractor1 extractor)
        (tipoUnidad VCE1 VCE)
        (tipoUnidad VCE2 VCE)

        ; Definición del tablero, donde se indican los caminos existentes entre casillas
        (existeCamino loc11 loc12)
        (existeCamino loc12 loc11)

        (existeCamino loc12 loc22)
        (existeCamino loc22 loc12)

        (existeCamino loc22 loc32)
        (existeCamino loc32 loc22)

        (existeCamino loc32 loc31)
        (existeCamino loc31 loc32)

        (existeCamino loc31 loc21)
        (existeCamino loc21 loc31)

        (existeCamino loc21 loc11)
        (existeCamino loc11 loc21)


        (existeCamino loc22 loc23)
        (existeCamino loc23 loc22)


        (existeCamino loc13 loc14)
        (existeCamino loc14 loc13)

        (existeCamino loc14 loc24)
        (existeCamino loc24 loc14)

        (existeCamino loc24 loc34)
        (existeCamino loc34 loc24)

        (existeCamino loc34 loc33)
        (existeCamino loc33 loc34)

        (existeCamino loc33 loc23)
        (existeCamino loc23 loc33)

        (existeCamino loc23 loc13)
        (existeCamino loc13 loc23)


        (existeCamino loc34 loc44)
        (existeCamino loc44 loc34)


        ; se construye centroDeMando 1 en lc11
        (edificioConstruido centroDeMando1)
        (en centroDeMando1 loc11)

        ; se indica dónde se va a construir el extractor1, para la que se requieren minerales
        (en extractor1 loc44) ;TODO: puedo referenciar explicitamenre la posicion del extractor?
        (construccionRequiere extractor1 mineral)

        ; se situa VCE1 en loc11
        (en VCE1 loc11)
        (en VCE2 loc11)

        ; se situan fuentes de mineral en loc22 y loc23
        (en mineral loc22) ; TODO: Cómo prevenir que en una misma localización no haya más de un recurso?
        (en mineral loc32)

        ; se situa una fuente de gas en loc44
        (en gas loc44)

        
    )
    (:goal
        (and
            ; el objetivo es generar recursos de tipo gas
            (extrayendoRecurso gas)
        )
    )
)