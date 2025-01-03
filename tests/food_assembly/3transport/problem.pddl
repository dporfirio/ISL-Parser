(define (problem transport)
    (:domain food_assembly)

    (:objects
        sauron - robot
        apple - item
        home - region
        table countertop - surface
        gripper - end_effector
    )

    (:init
        (object_at apple table)
        (entity_in sauron home)
        (is_grabbable apple)
        (is_free gripper)
        (owns_gripper sauron gripper)
        (accessible table)
        (accessible countertop)
        (accessible apple)
    )

    (:goal (object_at apple countertop))
)