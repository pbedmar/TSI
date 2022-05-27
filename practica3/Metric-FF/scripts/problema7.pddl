(define (problem problema7)
    (:domain dominio7)
    (:objects
        ; declarar las casillas del grid
        loc11 loc12 loc13 loc14 - localizacion
        loc21 loc22 loc23 loc24 - localizacion
        loc31 loc32 loc33 loc34 - localizacion
        loc44 - localizacion

        ; declaración de edificios
        centroDeMando1 extractor1 barracones1 - edificio

        ; declaración de unidades
        VCE1 VCE2 VCE3 - unidad
        marine1 marine2 - unidad
        soldado1 - unidad
    )
    (:init

        ; asignar tipo a cada variable
        (tipoEdificio centroDeMando1 centroDeMando)
        (tipoEdificio extractor1 extractor)
        (tipoEdificio barracones1 barracon)
        (tipoUnidad VCE1 VCE)
        (tipoUnidad VCE2 VCE)
        (tipoUnidad VCE3 VCE)
        (tipoUnidad marine1 marine)
        (tipoUnidad marine2 marine)
        (tipoUnidad soldado1 soldado)

        ; recursos requeridos para construir cada tipo de edificio
        (construccionRequiere barracon mineral)
        (construccionRequiere barracon gas)
        (construccionRequiere extractor mineral)

        ; recursos requeridos para generar cada tipo de unidad
        (unidadRequiere VCE mineral)
        (unidadRequiere marine mineral)
        (unidadRequiere marine gas)
        (unidadRequiere soldado mineral)
        (unidadRequiere soldado gas)

        ; en que tipo de edificio se genera cada tipo de unidad
        (unidadGeneradaEn VCE centroDeMando)
        (unidadGeneradaEn marine barracon)
        (unidadGeneradaEn soldado barracon)

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
        
        ; localizacion de unidades
        (unidadGenerada VCE1)
        (en VCE1 loc11)

        ; localizacion de recursos
        (en mineral loc22) ; TODO: Cómo prevenir que en una misma localización no haya más de un recurso?
        (en mineral loc32)
        (en gas loc44)

        ; la cantidad inicial de VCEs asignados a los recursos es 0
        (= (cantidadVCEAsig loc22) 0)
        (= (cantidadVCEAsig loc32) 0)
        (= (cantidadVCEAsig loc44) 0)
        
        ; al inicio de la ejecución el stock de todos los recursos está vacío
        (= (cantidadRecurso mineral) 0)
        (= (cantidadRecurso gas) 0)

        ; definición de la cantidad de recurso necesaria para construir un tipo de edificio dado
        (= (costeEdificio barracon mineral) 30)
        (= (costeEdificio barracon gas) 10)
        (= (costeEdificio extractor mineral) 10)
        (= (costeEdificio extractor gas) 0)

        ; definición de la cantidad de recurso necesaria para generar un tipo de unidad dada
        (= (costeUnidad VCE mineral) 5)
        (= (costeUnidad VCE gas) 0)
        (= (costeUnidad marine mineral) 10)
        (= (costeUnidad marine gas) 15)
        (= (costeUnidad soldado mineral) 30)
        (= (costeUnidad soldado gas) 30)

        ; el coste del plan inicialmente es 0
        (= (costeDelPlan) 0)
    )
    (:goal
        (and
            ; los marines y el soldado deben encontrarse en las posiciones indicadas
            (en marine1 loc31)
            (en marine2 loc24)
            (en soldado1 loc12)
            
            ; localización de barracones1
            (en barracones1 loc32)

            ; el coste del plan debe de ser una unidad menor que 45, o sea, 44. este es el minimo coste que hemos encontrado que safisface el problema
            (< (costeDelPlan) 45)
        )
    )
)