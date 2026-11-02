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
    )

    (:constants grinder coffee_maker - device
                sink person table cream_st sugar_st - surface
                coffee_beans grounds filter pot mug - grabbable
    )

    (:predicates
        (robot_at ?loc - location)
        (item_on ?item - grabbable ?loc - location)
        (robot_carrying ?item - grabbable)
        (gripper_free)
        (contains ?dev - device ?item - grabbable)
        (uses_filter)                       ; fixed per variant: the filter is part of the recipe
        (has_water ?x - object)             ; pot or coffee_maker
        (has_grounds ?x - object)           ; filter or coffee_maker
        (has_coffee ?x - grabbable)         ; mug
        (has_cream ?mug - grabbable)
        (has_sugar ?mug - grabbable)
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

    (:action place_beans_in_grinder
        :parameters ()
        :precondition (and (robot_carrying coffee_beans)
                           (robot_at grinder)
                      )
        :effect (and (gripper_free)
                     (not (robot_carrying coffee_beans))
                     (contains grinder coffee_beans)
                )
    )

    (:action turn_on_grinder
        :parameters ()
        :precondition (and (robot_at grinder)
                           (contains grinder coffee_beans)
                      )
        :effect (and (not (contains grinder coffee_beans))
                     (item_on grounds grinder)
                )
    )

    (:action place_filter_in_maker
        :parameters ()
        :precondition (and (uses_filter)
                           (robot_carrying filter)
                           (robot_at coffee_maker)
                      )
        :effect (and (gripper_free)
                     (not (robot_carrying filter))
                     (contains coffee_maker filter)
                )
    )

    (:action fill_pot
        :parameters ()
        :precondition (and (robot_carrying pot)
                           (robot_at sink)
                           (not (has_water pot))
                      )
        :effect (has_water pot)
    )

    (:action pour_water_into_maker
        :parameters ()
        :precondition (and (robot_carrying pot)
                           (has_water pot)
                           (robot_at coffee_maker)
                           (not (has_water coffee_maker))
                      )
        :effect (and (not (has_water pot))
                     (has_water coffee_maker)
                )
    )

    (:action pour_grounds_into_filter
        :parameters ()
        :precondition (and (uses_filter)
                           (robot_carrying grounds)
                           (robot_at coffee_maker)
                           (contains coffee_maker filter)
                           (not (has_grounds filter))
                      )
        :effect (and (has_grounds filter)
                     (not (robot_carrying grounds))
                     (gripper_free)
                )
    )

    (:action pour_grounds_into_maker
        :parameters ()
        :precondition (and (not (uses_filter))
                           (robot_carrying grounds)
                           (robot_at coffee_maker)
                           (not (has_grounds coffee_maker))
                      )
        :effect (and (has_grounds coffee_maker)
                     (not (robot_carrying grounds))
                     (gripper_free)
                )
    )

    (:action turn_on_maker_with_filter
        :parameters ()
        :precondition (and (uses_filter)
                           (robot_at coffee_maker)
                           (gripper_free)
                           (has_water coffee_maker)
                           (contains coffee_maker filter)
                           (has_grounds filter)
                           (item_on mug coffee_maker)
                      )
        :effect (and (has_coffee mug)
                     (not (has_water coffee_maker))
                     (not (has_grounds filter))
                )
    )

    (:action turn_on_maker_no_filter
        :parameters ()
        :precondition (and (not (uses_filter))
                           (robot_at coffee_maker)
                           (gripper_free)
                           (has_water coffee_maker)
                           (has_grounds coffee_maker)
                           (item_on mug coffee_maker)
                      )
        :effect (and (has_coffee mug)
                     (not (has_water coffee_maker))
                     (not (has_grounds coffee_maker))
                )
    )

    (:action pour_cream
        :parameters ()
        :precondition (and (robot_carrying mug)
                           (robot_at cream_st)
                           (has_coffee mug)
                      )
        :effect (has_cream mug)
    )

    (:action pour_sugar
        :parameters ()
        :precondition (and (robot_carrying mug)
                           (robot_at sugar_st)
                           (has_coffee mug)
                      )
        :effect (has_sugar mug)
    )
)