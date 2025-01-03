(define (problem handoff) 

    (:domain food_assembly)
    (:objects 
        sauron - robot
        david - person
        home kitchen - region
        apple - item
        table - surface
        gripper - end_effector
    )

    (:init
        (entity_in sauron home)
        (entity_in david kitchen)
        (entity_in table kitchen)
        (object_at apple table)
        (is_free gripper)
        (owns_gripper sauron gripper)
        (accessible david)
        (accessible table)
        (accessible apple)
        (is_grabbable apple)
    )

    (:goal (agent_has david apple))
)
