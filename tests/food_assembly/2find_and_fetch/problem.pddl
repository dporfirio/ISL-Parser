(define (problem find_and_fetch)
    (:domain food_assembly)

    (:objects
        sauron - robot
        apple - item
        home - region
        table - surface
        gripper - end_effector
    )

    (:init
        (object_at apple table)
        (entity_in sauron home)
        (is_grabbable apple)
        (is_free gripper)
        (owns_gripper sauron gripper)
        (accessible table)
        (accessible apple)
    )

    (:goal (agent_has sauron apple))
)