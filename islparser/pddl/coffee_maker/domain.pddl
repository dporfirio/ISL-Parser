(define (domain coffee_maker)
    (:requirements 

        ; General requirements - DO NOT
        ; MODIFY THE FOLLOWING LINE!
        :negative-preconditions :typing
    )

    (:types 
            item location - object
            region surface - location
            device - surface        ; grinder, coffee_maker
            grabbable - item
            container - grabbable        ; can hold water (pot)
            topping
    )

    (:constants grinder coffee_maker - device
                sink person table cream_st sugar_st - surface
                cream sugar - topping
                coffee_beans grounds filter mug - grabbable
                pot - container
    )

    (:predicates
        (robot_at ?loc - location)
        (item_on ?item - grabbable ?loc - location)
        (robot_carrying ?item - grabbable)
        (gripper_free)
        (has_water ?x - object)             ; pot or coffee_maker
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
                           (item_on coffee_beans grinder)
                      )
        :effect (and (not (item_on coffee_beans grinder))
                     (item_on grounds grinder)
                )
    )
    
    (:action turn_on_maker
        :parameters (?mug - grabbable)
        :precondition (and (robot_at coffee_maker)
                           (gripper_free)
                           (has_water coffee_maker)
                           (item_on filter coffee_maker)
                           (has_grounds filter)
                           (item_on ?mug coffee_maker)
                      )
        :effect (and (has_coffee ?mug)
                     (not (has_water coffee_maker))
                     (not (has_grounds filter))
                )
    )


    (:action pour
        :parameters (?mug - grabbable ?top - topping ?st - surface)
        :precondition (and (robot_carrying ?mug)
                           (robot_at ?st)
                           (topping_at ?top ?st)
                           (has_coffee ?mug)
                      )
        :effect (has_topping ?mug ?top)
    )

    (:action pour_water_into_maker
        :parameters (?container - container)
        :precondition (and (robot_carrying ?container)
                           (has_water ?container)
                           (robot_at coffee_maker)
                           (not (has_water coffee_maker))
                      )
        :effect (and (not (has_water ?container))
                     (has_water coffee_maker)
                )
    )

    (:action pour_grounds_into_filter
        :parameters ()
        :precondition (and (robot_carrying grounds)
                           (robot_at coffee_maker)
                           (item_on filter coffee_maker)
                           (not (has_grounds filter))
                      )
        :effect (and (has_grounds filter)
                     (not (robot_carrying grounds))
                     (gripper_free)
                )
    )




)