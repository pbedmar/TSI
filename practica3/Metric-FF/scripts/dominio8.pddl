(define (domain dominio8)
    (:requirements :strips :typing :negative-preconditions :fluents)
    (:types
        ; una entidad es un elemento que se encuentra en una posición concreta del mapa
        unidad edificio recurso - entidad

        ; coordenada del mapa
        localizacion

        ; tipos de cada entidad
        tUnidad - unidad
        tEdificio - edificio
        tRecurso - recurso
    )

    (:constants
        ; los VCE son un tipo de unidades que tienen la capacidad de recolectar un recurso y de construir
        VCE marine soldado - tUnidad

        ; los edificios pueden ser de tipo centro de mando, barracon o edificio
        centroDeMando barracon extractor - tEdificio

        ; existen dos tipos de recurso, mineral y gas
        mineral gas - tRecurso
    )

    (:predicates
        ; comprobamos si existe entidad (unidad, edificio, recurso) en una localización determinada
        (en ?E - entidad ?l - localizacion)

        ; comprobamos si existe un camino que conecta dos localizaciones
        (existeCamino ?l1 - localizacion ?l2 - localizacion)

        ; comprobamos si un determinado edificio ha sido construido
        (edificioConstruido ?e - edificio)

        ; comprobamos si se está extrayendo el tipo de recurso indicado
        (extrayendoRecurso ?r - recurso)

        ; comprobamos si una unidad está extrayendo un recurso o está libre
        (unidadTrabajando ?u - unidad) 

        ; comprobamos que la unidad es de un tipo concreto
        (tipoUnidad ?u - unidad ?t - tUnidad)

        ; comprobamos que el edificio es de un tipo concreto
        (tipoEdificio ?e - edificio ?t - tEdificio)

        ; indicamos el recurso necesario para construir un edificio
        (construccionRequiere ?e - edificio ?r - recurso)

        ; indicamos el recurso necesario para generar una unidad
        (unidadRequiere ?u - unidad ?r - recurso)

        ; indicamos el tipo de edificio donde se debe generar una unidad
        (unidadGeneradaEn ?u - unidad ?te - tEdificio)

        ; indicamos que se ha generado una unidad
        (unidadGenerada ?u - unidad)
    )

    (:functions
        ; almacenar la cantidad de unidades de cada recurso
        (cantidadRecurso ?r - recurso)

        ; almacenar la cantidad de VCEs asignados en una localizacion
        (cantidadVCEAsig ?l)

        ; guardar el número de unidades necesarias de un recurso concreto para construir un tipo de edificio
        (costeEdificio ?te - tEdificio ?r - recurso)

        ; guardar el número de unidades necesarias de un recurso concreto para generar un tipo de unidad
        (costeUnidad ?tu - tUnidad ?r - recurso)

        ; buscamos minimizar el valor de esta funcion
        (costeDelPlan)

        ; medida del tiempo que tardan las acciones
        (tiempoRealizacion)
    )

    ; permite desplazar una unidad entre dos localizaciones
    (:action Navegar
        :parameters (?u - unidad ?origen - localizacion ?destino - localizacion)
        :precondition
            (and
                ; la unidad debe encontrarse en la localización de origen
                (en ?u ?origen)

                ; la unidad no debe encontrarse en la localización de destino
                (not (en ?u ?destino))

                ; debe existir un camino entre ambas localizaciones
                (existeCamino ?origen ?destino)

                ; la unidad no debe encontrarse trabajando en otra tarea
                (not (unidadTrabajando ?u))
            )
        :effect
            (and
                ; la unidad pasa de encontrarse en la posición de origen a la posición de destino
                (not (en ?u ?origen))
                (en ?u ?destino)

                ; al realizar la acción, se incrementa el coste del plan en 1
                (increase (costeDelPlan) 1)

                ; incrementamos el tiempo que tarda el plan segun el tiempo que tarda en navegar el VCE
                (when (tipoUnidad ?u VCE)
                    (increase (tiempoRealizacion) 20)
                )

                ; incrementamos el tiempo que tarda el plan segun el tiempo que tarda en navegar el marine
                (when (tipoUnidad ?u marine)
                    (increase (tiempoRealizacion) 4)
                )

                ; incrementamos el tiempo que tarda el plan segun el tiempo que tarda en navegar el soldado
                (when (tipoUnidad ?u soldado)
                    (increase (tiempoRealizacion) 1)
                )
            )
    )

    ; asigna un VCE a un nodo de recurso
    (:action Asignar
        :parameters (?u - unidad ?l - localizacion ?r - recurso)
        :precondition
            (and
                ; la unidad debe encontrarse en la localización del recurso
                (en ?u ?l)

                ; el VCE no puede encontrarse extrayendo en ese momento
                (not (unidadTrabajando ?u))

                ; en la localización debe existir el recurso deseado
                (en ?r ?l)

                ; la unidad que se asigna debe ser de tipo VCE
                (tipoUnidad ?u VCE)

                ; si el recurso que se quiere obtener es gas vespeno, debe existir un edificio extractor construido en la localización del gas
                (imply (en gas ?l)
                    (exists (?e - edificio)
                        (and 
                            (edificioConstruido ?e)
                            (tipoEdificio ?e extractor)
                            (en ?e ?l)
                        )
                    )
                )
            )
        :effect
            (and
                ; indicamos que la unidad VCE está trabajando en la extracción del recurso
                (unidadTrabajando ?u)

                ; indicamos que el recurso del tipo indicado está siendo extraído
                (extrayendoRecurso ?r)

                ; aumentar en uno la cantidad de VCE asignados en una localización
                (increase (cantidadVCEAsig ?l) 1)

                ; al realizar la acción, se incrementa el coste del plan en 1
                (increase (costeDelPlan) 1)
            )
    )

    ; una unidad construye un edificio en una determinada localizacion, utilizando un recurso concreto
    (:action CONSTRUIREDIFICIO
        :parameters (?u - unidad ?e - edificio ?l - localizacion)
        :precondition
            (and
                ; la unidad debe estar en la localizacion donde se va a construir
                (en ?u ?l)

                ; debe existir una unidad libre
                (not (unidadTrabajando ?u))

                ; la unidad constructora debe ser de tipo VCE
                (tipoUnidad ?u VCE)

                ; este exists se utiliza para enlazar el edificio a construir con su tipo
                (exists (?te - tEdificio)
                    (and
                        (tipoEdificio ?e ?te)
                        ; se recorren todos los tipos de recurso existentes 
                        (forall (?tr - tRecurso)
                            ; si la construcción de ese tipo de edificio requiere el recurso
                            (imply (construccionRequiere ?te ?tr)
                                (and
                                    ; este debe de estar extrayéndose
                                    (extrayendoRecurso ?tr)
                                    ; la cantidad de recurso debe ser mayor que el coste
                                    (>= (cantidadRecurso ?tr) (costeEdificio ?te ?tr))
                                )
                            )
                        )
                    )
                )

                ; no se debe haber construído el edificio previamente
                (not (edificioConstruido ?e))

                ; no puede existir ningún edificio construido en la localización ?l
                (forall (?e2 - edificio) 
                    ; si esto no se cumple, el imply es falso
                    (imply (en ?e2 ?l)
                        (not (edificioConstruido ?e2))
                    )
                )

            )
        :effect
            (and
                ; se marca el edificio como construido
                (edificioConstruido ?e)

                ; el edificio debe estar en una determinada posicion
                (en ?e ?l)

                ; si el edificio es de tipo barracon, reducimos el stock de los minerales y gases que necesita e incrementamos el tiempo que tarda el plan
                (when (tipoEdificio ?e barracon)
                    (and
                        (decrease (cantidadRecurso mineral) (costeEdificio barracon mineral))

                        (decrease (cantidadRecurso gas) (costeEdificio barracon gas))

                        (increase (tiempoRealizacion) 50)
                    )
                )

                ; si el edificio es de tipo extractor, reducimos el stock de los minerales y gases que necesita e incrementamos el tiempo que tarda el plan
                (when (tipoEdificio ?e extractor)
                    (and
                        (decrease (cantidadRecurso mineral) (costeEdificio extractor mineral))

                        (decrease (cantidadRecurso gas) (costeEdificio extractor gas))

                        (increase (tiempoRealizacion) 30)
                    )
                )

                ; al realizar la acción, se incrementa el coste del plan en 1
                (increase (costeDelPlan) 1)
            )
    )

    (:action Reclutar
        :parameters (?e - edificio ?u - unidad ?l - localizacion)
        :precondition
            (and
                ; el edificio debe estar en la localización correcta
                (en ?e ?l)

                ; el edificio debe haber sido construido
                (edificioConstruido ?e)

                ; la unidad a generar no ha debido ser generada anteriormente
                (not (unidadGenerada ?u))

                ; la unidad debe de ser generada en el edificio que le corresponde según su tipo
                (exists (?tu - tUnidad)
                    (and
                        ; extraemos el tipo de la unidad
                        (tipoUnidad ?u ?tu)
                        (exists (?te - tEdificio)
                            (and
                                ; extraemos el tipo de edificio
                                (tipoEdificio ?e ?te)
                                ; nos aseguramos de que el tipo de unidad se corresponde con el tipo de edificio donde debe de ser generada
                                (unidadGeneradaEn ?tu ?te)
                            )
                        )
                    )
                )


                ; asegura que se están extrayendo los recursos necesarios para generar la unidad
                (exists (?tu - tUnidad)
                    (and
                        ; extraemos el tipo de unidad
                        (tipoUnidad ?u ?tu)
                        ; si su generación requiere algún recurso
                        (forall (?tr - tRecurso)
                            (imply (unidadRequiere ?tu ?tr)
                                (and
                                    ; debe de estar extrayéndose
                                    (extrayendoRecurso ?tr)
                                    ; la cantidad de recurso disponible debe ser mayor o igual que lo que se necesita para generar la unidad
                                    (>= (cantidadRecurso ?tr) (costeUnidad ?tu ?tr))
                                )
                            )
                        )
                    )
                )
            )
        :effect
            (and
                ; se ha reclutado la unidad en la localización del edificio generador
                (en ?u ?l)
                ; se ha reclutado la unidad
                (unidadGenerada ?u)

                ; si la unidad es de tipo VCE, reducimos el stock de los minerales y gases que necesita e incrementamos el tiempo que tarda el plan
                (when (tipoUnidad ?u VCE)
                    (and
                        (decrease (cantidadRecurso mineral) (costeUnidad VCE mineral))

                        (decrease (cantidadRecurso gas) (costeUnidad VCE gas))

                        (increase (tiempoRealizacion) 10)
                    )
                )
                
                ; si la unidad es de tipo marine, reducimos el stock de los minerales y gases que necesita e incrementamos el tiempo que tarda el plan
                (when (tipoUnidad ?u marine)
                    (and                
                        (decrease (cantidadRecurso mineral) (costeUnidad marine mineral))

                        (decrease (cantidadRecurso gas) (costeUnidad marine gas))

                        (increase (tiempoRealizacion) 20)
                    )
                )
                
                ; si la unidad es de tipo soldado, reducimos el stock de los minerales y gases que necesita e incrementamos el tiempo que tarda el plan
                (when (tipoUnidad ?u soldado)
                    (and
                        (decrease (cantidadRecurso mineral) (costeUnidad soldado mineral))

                        (decrease (cantidadRecurso gas) (costeUnidad soldado gas))

                        (increase (tiempoRealizacion) 30)
                    )
                )

                ; al realizar la acción, se incrementa el coste del plan en 1
                (increase (costeDelPlan) 1)
            )
    )

    (:action Recolectar
        :parameters (?r - recurso ?l - localizacion)
        :precondition
            (and
                ; el recurso está en la localización indicada
                (en ?r ?l)

                ; se está extrayendo el recurso
                (extrayendoRecurso ?r)

                ; al recolectar el recurso, su stock no va a superar las 60 unidades
                (>= 60 (+ (cantidadRecurso ?r) (* 10 (cantidadVCEAsig ?l))))

                ; el número de VCEs asignados en la localización va a ser mayor a 0
                (< 0 (cantidadVCEAsig ?l))
            )
        :effect
            (and
                ; aumenta el stock del recurso según el número de VCEs asignados
                (increase (cantidadRecurso ?r) (* 10 (cantidadVCEAsig ?l)))

                ; al realizar la acción, se incrementa el coste del plan en 1
                (increase (costeDelPlan) 1)

                ; se incrementa el tiempo que tarda el plan en la cantidad especificada en el guion
                (increase (tiempoRealizacion) 5)
            )
    )
)