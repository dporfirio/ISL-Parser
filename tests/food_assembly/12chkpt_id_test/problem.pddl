(define (problem move_to_table)
    (:domain food_assembly)
    (:objects
        kitchen_table dining_table - surface
        kitchen - region
        cup plate - item
        sauron - robot
        gripper - end_effector
    )
    (:init
        (accessible cup)
        (accessible plate)
        (accessible dining_table)
        (accessible kitchen_table)
        (agent_near sauron dining_table)
        (is_free gripper)
        (owns_gripper sauron gripper)
        (object_at cup dining_table)
        (object_at plate dining_table)
        (is_grabbable cup)
        (is_grabbable plate)
    )
    (:goal
        (agent_near sauron dining_table)
    )
)