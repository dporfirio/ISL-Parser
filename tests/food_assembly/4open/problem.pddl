(define (problem open_fridge)
    (:domain food_assembly)
    (:objects
        sauron - robot
        fridge - item
        home kitchen - region
        gripper - end_effector
    )

    (:init
        (entity_in sauron home)
        (entity_in fridge kitchen)
        (is_openable fridge)
        (is_free gripper)
        (owns_gripper sauron gripper)
        (accessible fridge)
    )

    (:goal
        (is_open fridge)
    )

)