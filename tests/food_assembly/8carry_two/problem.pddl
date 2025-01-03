(define (problem offer_and_take) 

    (:domain food_assembly)
    (:objects 
        sauron - robot
        kitchen - region
        dining table - surface
        cup - item
        plate - item
        gripper - end_effector
    )

    (:init
        (accessible cup)
        (accessible plate)
        (accessible table)
        (accessible dining)
        (is_free gripper)
        (is_grabbable cup)
        (is_grabbable plate)
        (owns_gripper sauron gripper)
    )

    (:goal (object_at cup table))

)
