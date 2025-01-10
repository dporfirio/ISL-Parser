(define (problem offer_and_take) 

    (:domain food_assembly)
    (:objects 
        stretch - robot
        david - person
        home dining_area kitchen - region
        countertop table kitchen_table dining_table - surface
        bread cup plate apple fridge - item
        gripper hand - end_effector
    )

    (:init
        (entity_in stretch home)
        (entity_in fridge kitchen)
        (object_at bread countertop)
        (accessible bread)
        (accessible cup)
        (accessible plate)
        (accessible apple)
        (accessible countertop)
        (accessible table)
        (accessible kitchen_table)
        (accessible dining_table)
        (accessible david)
        (accessible stretch)
        (accessible fridge)
        (is_free gripper)
        (is_free hand)
        (is_openable fridge)
        (owns_gripper stretch gripper)
        (owns_gripper david hand)
        (object_at cup dining_table)
        (object_at plate dining_table)
        (is_grabbable bread)
        (is_grabbable cup)
        (is_grabbable plate)
        (is_grabbable apple)
    )

    (:goal (object_at bread table))

)
