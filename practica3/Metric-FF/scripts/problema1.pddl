(define (problem problema1)
    (:domain dominio1)
    (:objects
        loc11 loc12 loc13 loc14 - localizacion
        loc21 loc22 loc23 loc24 - localizacion
        loc31 loc32 loc33 loc34 - localizacion
        loc44 - localizacion

        centroDeMando1 - edificio
        VCE1 - unidad
    )
    (:init

        ; Definición del tablero
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


        ; Edificios
        (edificioConstruido centroDeMando1)
        (en centroDeMando1 loc11)

        ; Unidades
        (en VCE1 loc11)

        ; Minerales
        (en mineral loc22) ; Cómo prevenir que en una misma localización no haya más de un recurso?
        (en mineral loc23)
        
    )
    (:goal
        (and
            (extrayendoRecurso mineral)
        )
    )
)