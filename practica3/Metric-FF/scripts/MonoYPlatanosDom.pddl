(define (domain mono)
    (:requirements :strips :typing)
    (:types
        movible localizacion - object
        mono caja - movible
    )
    (:predicates
        (en ?obj - movible ?x - localizacion)
        (tienePlatano ?m - mono)
        (platanoEn ?x - localizacion)
        (sobre ?m - mono ?c - caja)
    )
    
    (:action cogerPlatanos
        :parameters (?m - mono ?c - caja ?l - localizacion)
        :precondition
            (and
                (sobre ?m ?c)
                (en ?m ?l)
                (en ?c ?l)
                (platanoEn ?l)
            )
        :effect
            (and
                (tienePlatano ?m)
            )
    )

    (:action empujarCaja
    :parameters (?m - mono ?c - caja ?o - localizacion ?d - localizacion)
    :precondition
        (and
            (en ?m ?o)
            (en ?c ?o)
        )
    :effect
        (and
            (en ?m ?d)
            (en ?c ?d)
        )
    )

    (:action subirSobreCaja
    :parameters (?m - mono ?c - caja ?o - localizacion ?d - localizacion)
    :precondition
        (and
            (en ?m ?o)
            (en ?c ?o)
            (not (sobre ?m ?c))
        )
    :effect
        (and
            (sobre ?m ?c)
        )
    )

    
)