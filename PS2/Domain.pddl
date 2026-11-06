(define (domain mars-rover)
  (:requirements :strips :typing)

  (:types
    rover
    location
    sample
    bay
    drill
  )

  (:predicates
    (at ?r - rover ?l - location)           ; rover is at location
    (at-sample ?s - sample ?l - location)   ; rock is at location
    (connected ?l1 - location ?l2 - location) ; route exists between locations
    (in-bay ?s - sample ?b - bay)           ; rock is loaded in a bay
    (bay-empty ?b - bay)                    ; bay is empty
    (at-drill ?d - drill ?l - location)     ; drill is at location
    (soft ?s - sample)
    (hard ?s - sample)                      ; rock is hard type
    (has-drill ?r - rover ?d - drill)       ; rover is carrying the drill
  )

  (:action move
    :parameters (?r - rover ?from - location ?to - location)
    :precondition (and (at ?r ?from) (connected ?from ?to))
    :effect (and (at ?r ?to) (not (at ?r ?from)))
  )

  (:action pick-drill
    :parameters (?r - rover ?d - drill ?l - location)
    :precondition (and (at ?r ?l) (at-drill ?d ?l))
    :effect (and (has-drill ?r ?d) (not (at-drill ?d ?l)))
  )
  
  (:action collect-soft
    :parameters (?r - rover ?s - sample ?l - location ?b - bay)
    :precondition (and (at ?r ?l) (at-sample ?s ?l) (bay-empty ?b) (soft ?s))
    :effect (and (in-bay ?s ?b) (not (bay-empty ?b)) (not (at-sample ?s ?l)))
  )

  (:action collect-hard
    :parameters (?r - rover ?s - sample ?l - location ?b - bay ?d - drill)
    :precondition (and (at ?r ?l) (at-sample ?s ?l) (bay-empty ?b) (hard ?s) (has-drill ?r ?d))
    :effect (and (in-bay ?s ?b) (not (bay-empty ?b)) (not (at-sample ?s ?l)))
  )

    (:action deposit
    :parameters (?r - rover ?s - sample ?b - bay ?l - location)
    :precondition (and (at ?r ?l) (in-bay ?s ?b))
    :effect (and (at-sample ?s ?l) (bay-empty ?b) (not (in-bay ?s ?b)))
  )
)
