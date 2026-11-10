(define (domain coffee_maker)
    (:requirements 

        ; General requirements - DO NOT
        ; MODIFY THE FOLLOWING LINE!
        :negative-preconditions :typing
    )

    (:types 
            item location - object
            region surface - location
            device - surface        ; grinder, maker
            grabbable - item
            container - grabbable        ; can hold water (pot)
            topping
    )

    (:constants grinder maker - device
                sink person table cream_st sugar_st - surface
                cream sugar - topping
                beans grounds filter mug - grabbable
                pot - container
    )

    (:predicates
        (robot_at ?loc - location)
        (item_on ?item - grabbable ?loc - location)
        (robot_carrying ?item - grabbable)
        (gripper_free)
        (has_water ?x - object)             ; pot or maker
        (has_grounds ?x - object)           ; filter
        (has_coffee ?x - grabbable)         ; mug
        (has_topping ?mug - grabbable ?top - topping)
        (topping_at ?top - topping ?st - surface)
    )

    (:action move_to
        :parameters (?from - location ?to - location)
        :precondition (and (robot_at ?from)
                           (not (robot_at ?to))
                      )
        :effect (and (robot_at ?to)
                     (not (robot_at ?from))
                )
    )

    (:action grab
        :parameters (?item - grabbable ?src - location)
        :precondition (and (item_on ?item ?src)
                           (robot_at ?src)
                           (gripper_free)
                      )
        :effect (and (not (gripper_free))
                     (not (item_on ?item ?src))
                     (robot_carrying ?item)
                )
    )

    (:action place
        :parameters (?item - grabbable ?surface - surface)
        :precondition (and (robot_carrying ?item)
                           (robot_at ?surface)
                      )
        :effect (and (gripper_free)
                     (item_on ?item ?surface)
                     (not (robot_carrying ?item))
                )
    )

    (:action fill
        :parameters (?container - container)
        :precondition (and (robot_carrying ?container)
                           (robot_at sink)
                           (not (has_water ?container))
                      )
        :effect (has_water ?container)
    )
    
    (:action turn_on_grinder
        :parameters ()
        :precondition (and (robot_at grinder)
                           (item_on beans grinder)
                      )
        :effect (and (not (item_on beans grinder))
                     (item_on grounds grinder)
                )
    )
    
    (:action turn_on_maker
        :parameters (?mug - grabbable)
        :precondition (and (robot_at maker)
                           (gripper_free)
                           (has_water maker)
                           (item_on filter maker)
                           (has_grounds filter)
                           (item_on ?mug maker)
                      )
        :effect (and (has_coffee ?mug)
                     (not (has_water maker))
                     (not (has_grounds filter))
                )
    )


    ; One generalized pour action, matching the panel's (object, target) input.
    ; Disjunctive preconditions select the valid source/target interaction;
    ; conditional effects apply only that interaction's state changes.
    (:action pour
        :parameters (?object - grabbable ?target - object)
        :precondition (or
            (and (= ?object pot) (= ?target maker)
                 (robot_carrying pot) (has_water pot)
                 (robot_at maker) (not (has_water maker)))
            (and (= ?object grounds) (= ?target filter)
                 (robot_carrying grounds) (robot_at maker)
                 (item_on filter maker) (not (has_grounds filter)))
            (and (= ?object mug) (= ?target cream)
                 (robot_carrying mug) (robot_at cream_st)
                 (topping_at cream cream_st) (has_coffee mug))
            (and (= ?object mug) (= ?target sugar)
                 (robot_carrying mug) (robot_at sugar_st)
                 (topping_at sugar sugar_st) (has_coffee mug))
        )
        :effect (and
            (when (= ?target maker)
                (and (not (has_water pot)) (has_water maker)))
            (when (= ?target filter)
                (and (has_grounds filter) (not (robot_carrying grounds)) (gripper_free)))
            (when (= ?target cream) (has_topping mug cream))
            (when (= ?target sugar) (has_topping mug sugar))
        )
    )




)
