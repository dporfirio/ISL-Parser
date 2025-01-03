(define (problem move_to_table)
    (:domain food_assembly)
    (:objects
        table home - region
        sauron - robot
    )
    (:init
        (entity_in sauron home)
    )
    (:goal
        (entity_in sauron table)
    )
)