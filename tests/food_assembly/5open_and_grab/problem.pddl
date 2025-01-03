(define (problem open_and_grab) 

    (:domain food_assembly)
    (:objects 
        sauron - robot
        home kitchen - region
        table - surface
        apple fridge - item
        gripper - end_effector
    )

    (:init
        (object_at apple fridge)
        (entity_in apple kitchen)
        (is_free gripper)
        (entity_in sauron home)
        (entity_in fridge kitchen)
        (is_openable fridge)
        (owns_gripper sauron gripper)
        (accessible table)
        (accessible fridge)
        (is_grabbable apple)
    )

    (:goal (object_at apple table))
)