(define (problem offer_and_take) 

    (:domain food_assembly)
    (:objects 
        sauron - robot
        david - person
        home - region
        countertop table - surface
        bread - item
        gripper hand - end_effector
    )

    (:init
        (entity_in sauron home)
        (object_at bread countertop)
        (accessible bread)
        (accessible countertop)
        (accessible table)
        (accessible david)
        (accessible sauron)
        (is_free gripper)
        (is_free hand)
        (is_grabbable bread)
        (owns_gripper sauron gripper)
        (owns_gripper david hand)
    )

    (:goal (object_at bread table))

)
