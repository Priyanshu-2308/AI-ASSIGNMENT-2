(define (problem mars-rover-problem)
  (:domain mars-rover)

  (:objects
    curiosity - rover
    base sitea siteb sitec sited sitee sitef - location
    rock1 rock2 rock3 rock4 rock5 - sample
    bay1 bay2 - bay
    drill1 - drill
  )

  (:init
    ; Initial State
    ; rover starts at base
    (at curiosity base)

    ; bays are empty
    (bay-empty bay1)
    (bay-empty bay2)

    ; drill starts at sitee
    (at-drill drill1 sitee)

    ; rock locations
    (at-sample rock1 sitea)
    (at-sample rock2 siteb)
    (at-sample rock3 sitec)
    (at-sample rock4 sited)
    (at-sample rock5 sitef)

    ; soft rocks
    (soft rock1)
    (soft rock2)
    (soft rock4)

    ; hard rocks
    (hard rock3)
    (hard rock5)

    ; two-way routes
    (connected base sitea)
    (connected sitea base)
    (connected base siteb)
    (connected siteb base)
    (connected sitea sitec)
    (connected sitec sitea)
    (connected siteb sited)
    (connected sited siteb)
    (connected sitec sitee)
    (connected sitee sitec)
    (connected sited sitee)
    (connected sitee sited)
    (connected sitee sitef)
    (connected sitef sitee)

    ; one-way route only
    (connected sitec sited)
  )

  (:goal
    (and
      (at curiosity base)
      (at-sample rock1 base)
      (at-sample rock2 base)
      (at-sample rock3 base)
      (at-sample rock4 base)
      (at-sample rock5 base)
      (bay-empty bay1)
      (bay-empty bay2)
    )
  )
)

