(define (domain dominio5)
    (:requirements :strips :typing :negative-preconditions) ; TODO: puedo utilizar :negative-preconditions?
    (:types ; TODO: los nombres de los tipos deben ser exactamente iguales que los del guión?
        ; una entidad es un elemento que se encuentra en una posición concreta del mapa
        unidad edificio recurso - entidad

        ; coordenada del mapa
        localizacion

        ; tipos de cada entidad
        tUnidad - unidad
        tEdificio - edificio
        tRecurso - recurso

        ; tipo investigación
        investigacion
    )

    (:constants
        ; los VCE son un tipo de unidades que tienen la capacidad de recolectar un recurso y de construir
        VCE marine soldado - tUnidad

        ; los edificios pueden ser de tipo centro de mando, barracon o edificio
        centroDeMando barracon extractor bahiaDeIngenieria - tEdificio

        ; existen dos tipos de recurso, mineral y gas
        mineral gas - tRecurso

        investigarSoldadoUniversal - investigacion ; TODO: es correcto declarar esta investigación como una constante?
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
        (unidadTrabajando ?u - unidad) ; TODO: cómo forzar que sea de tipo VCE?

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

        (investigacionRequiere ?i - investigacion ?r - recurso)

        (investigacionCompletada ?i - investigacion)
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

                (not (unidadTrabajando ?u))
            )
        :effect
            (and
                ; la unidad pasa de encontrarse en la posición de origen a la posición de destino
                (not (en ?u ?origen))
                (en ?u ?destino)
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
            )
    )

    ; una unidad construye un edificio en una determinada localizacion, utilizando un recurso concreto
    (:action Construir
        :parameters (?u - unidad ?e - edificio ?l - localizacion)
        :precondition
            (and
                ; la unidad debe estar en la localizacion donde se va a construir
                (en ?u ?l)

                ; el edificio debe estar planificado en una determinada posicion de antemano 
                (en ?e ?l)

                ; debe existir una unidad libre
                (not (unidadTrabajando ?u))

                ; se recorren todos los tipos de recurso existentes 
                (forall (?tr - tRecurso)
                    ; este exists se utiliza para enlazar el edificio a construir con su tipo. si la construcción de ese tipo de edificio requiere el recurso, este debe de estar extrayéndose.
                    (exists (?te - tEdificio)
                        (and
                            (tipoEdificio ?e ?te)
                            (imply (construccionRequiere ?te ?tr)
                                (extrayendoRecurso ?tr)
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
                (forall (?tr - tRecurso)
                    (exists (?tu - tUnidad)
                        (and
                            ; extraemos el tipo de unidad
                            (tipoUnidad ?u ?tu)
                            ; si su generación requiere algún recurso, debe de estar extrayéndose
                            (imply (unidadRequiere ?tu ?tr)
                                (extrayendoRecurso ?tr)
                            )
                        )
                    )
                )

                ; 
                (imply (tipoUnidad ?u soldado)
                    (investigacionCompletada investigarSoldadoUniversal)
                )
            )
        :effect
            (and
                ; se ha reclutado la unidad en la localización del edificio generador
                (en ?u ?l)
                ; se ha reclutado la unidad
                (unidadGenerada ?u)
            )
    )

    (:action Investigar
        :parameters (?e - edificio ?i - investigacion)
        :precondition
            (and
                (not (investigacionCompletada ?i))

                (edificioConstruido bahiaDeIngenieria)

                ; asegura que se están extrayendo los recursos necesarios para llevar a cabo la investigacion
                (forall (?tr - tRecurso)
                    (and
                        ; si la investigacion requiere algún recurso, debe de estar extrayéndose
                        (imply (investigacionRequiere ?i ?tr)
                            (extrayendoRecurso ?tr)
                        )
                    )
                )

            )
        :effect
            (and
                (investigacionCompletada ?i)
            )
    )
)