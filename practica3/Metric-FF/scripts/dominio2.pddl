(define (domain dominio1)
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
    )

    (:constants
        ; los VCE son un tipo de unidades que tienen la capacidad de recolectar un recurso y de construir
        VCE - tUnidad

        ; los edificios pueden ser de tipo centro de mando o barracon
        centroDeMando barracon extractor - tEdificio

        ; existen dos tipos de recurso, mineral y gas
        mineral gas - tRecurso ; TODO: es esto correcto??
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

                ; (not (extrayendoRecurso ?u)) TODO: sería necesario??
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
            )
        :effect
            (and
                ; indicamos que la unidad VCE está trabajando en la extracción del recurso
                (unidadTrabajando ?u)

                ; indicamos que el recurso del tipo indicado está siendo extraído
                (extrayendoRecurso ?r)
            )
    )


    (:action Construir
        :parameters (?u - unidad ?e - edificio ?l - localizacion ?r - recurso)
        :precondition
            (and
                (en ?u ?l)
                (not (unidadTrabajando ?u))
                (extrayendoRecurso ?r)
                (not (edificioConstruido ?e))
            )
        :effect
            (and
                ; (unidadTrabajando ?u) TODO: Es esto correcto? una unidad se queda trabajando en un edificio hasta terminar la ejecución?
                (en ?e ?l)
                (edificioConstruido ?e)
            )
    )
)