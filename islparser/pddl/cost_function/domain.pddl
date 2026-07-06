; Generated from this template by islparser/isl_cost.py

(define (domain cost)

    (:requirements
        :negative-preconditions
        :typing
    )

    (:types
        location item - object
    )

    (:predicates
        (robot_at ?l - location)
        (item_at ?i - item ?l - location)
        (robot_has ?i - item)
        (gripper_is_free)
    )

    (:action move1
        :parameters (?from - location ?to - location)
        :precondition (and
            (robot_at ?from)
        )
        :effect (and
            (not (robot_at ?from))
            (robot_at ?to)
        )
    )

    (:action move2
        :parameters (?from - location ?to - location)
        :precondition (and
            (robot_at ?from)
        )
        :effect (and
            (not (robot_at ?from))
            (robot_at ?to)
        )
    )

    (:action grab1
        :parameters (?item - item ?location - location)
        :precondition (and
            (item_at ?item ?location)
            (robot_at ?location)
            (gripper_is_free)
        )
        :effect (and
            (not (item_at ?item ?location))
            (robot_has ?item)
            (not (gripper_is_free))
        )
    )

    (:action grab2
        :parameters (?item - item ?location - location)
        :precondition (and
            (item_at ?item ?location)
            (robot_at ?location)
            (gripper_is_free)
        )
        :effect (and
            (not (item_at ?item ?location))
            (robot_has ?item)
            (not (gripper_is_free))
        )
    )

    (:action put1
        :parameters (?item - item ?location - location)
        :precondition (and
            (robot_has ?item)
            (robot_at ?location)
        )
        :effect (and
            (not (robot_has ?item))
            (item_at ?item ?location)
            (gripper_is_free)
        )
    )

    (:action put2
        :parameters (?item - item ?location - location)
        :precondition (and
            (robot_has ?item)
            (robot_at ?location)
        )
        :effect (and
            (not (robot_has ?item))
            (item_at ?item ?location)
            (gripper_is_free)
        )
    )
)
