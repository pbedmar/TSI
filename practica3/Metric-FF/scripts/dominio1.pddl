(define (domain dominio1)
    (:requirements :strips :typing :negative-preconditions) ; TODO: puedo utilizar :negative-preconditions?
    (:types ; TODO: los nombres de los tipos deben ser exactamente iguales que los del guión?
        unidad edificio recurso - entidad
        localizacion
    )

    (:constants
        VCE - unidad
        centroDeMando barracon - edificio
        mineral gas - recurso ; TODO: es esto correcto??
    )

    (:predicates
        (en ?E - entidad ?l - localizacion)
        (existeCamino ?l1 - localizacion ?l2 - localizacion)
        (edificioConstruido ?e - edificio)
        (extrayendoRecurso ?r - recurso)
        (unidadExtrayendo ?unidad - unidad) ; TODO: cómo forzar que sea de tipo VCE?
    )

    (:action Navegar
        :parameters (?u - unidad ?origen - localizacion ?destino - localizacion)
        :precondition
            (and
                (en ?u ?origen)
                (not (en ?u ?destino))
                (existeCamino ?origen ?destino)
                ; (not (extrayendoRecurso ?u)) TODO: sería necesario??
            )
        :effect
            (and
                (not (en ?u ?origen))
                (en ?u ?destino)
            )
    )

    (:action Asignar
        :parameters (?u - unidad ?l - localizacion ?r - recurso)
        :precondition
            (and
                (en ?u ?l)
                (not (unidadExtrayendo ?u))
                (en ?r ?l)
            )
        :effect
            (and
                (unidadExtrayendo ?u)
                (extrayendoRecurso ?r)
            )
    )
)