; ============================================================================
; DOMAIN: Delegation Weight
; Simplified one-level package-fetch scenario.
; Costs are injected at runtime by islparser/isl_cost.py.
; ============================================================================

(define (domain delegation_weight)

    (:requirements
        :negative-preconditions
        :typing
    )

    (:types
        world bookkeeping - object

        region entity - world

        agent inanimate - entity
        person robot - agent
        requester staff - person

        item surface - inanimate
        message - bookkeeping
    )

    (:predicates
        (entity_in ?entity - entity ?region - region)
        (agent_near ?agent - agent ?entity - entity)
        (agent_is_near_something ?agent - agent)
        (object_at ?item - item ?surface - surface)

        ; Who currently has an item. Staff can hold multiple items. The robot
        ; uses this predicate too, but the basket capacity is separately
        ; enforced by robot_basket_empty.
        (agent_has ?agent - agent ?item - item)

        (can_move ?agent - agent)
        (said ?speaker - agent ?listener - person ?message - message)
        (delegated ?robot - robot ?staff - staff ?message - message)
        (task_assigned ?staff - staff ?message - message)
        (requested_item ?message - message ?item - item)
        (robot_basket_empty ?robot - robot)
        (region_connected ?from - region ?to - region)
    )

    (:action robot_move_from_reg_to
        :parameters (?agent - robot ?from - region ?to - region)
        :precondition (and
            (can_move ?agent)
            (entity_in ?agent ?from)
            (region_connected ?from ?to)
            (not (agent_is_near_something ?agent))
        )
        :effect (and
            (entity_in ?agent ?to)
            (not (entity_in ?agent ?from))
        )
    )

    (:action robot_move_from_ent_to
        :parameters (?agent - robot ?from - entity ?in - region ?to - region)
        :precondition (and
            (can_move ?agent)
            (entity_in ?agent ?in)
            (entity_in ?from ?in)
            (region_connected ?in ?to)
            (agent_near ?agent ?from)
            (agent_is_near_something ?agent)
        )
        :effect (and
            (entity_in ?agent ?to)
            (not (entity_in ?agent ?in))
            (not (agent_near ?agent ?from))
            (not (agent_is_near_something ?agent))
        )
    )

    (:action staff_move_from_reg_to
        :parameters (?agent - staff ?from - region ?to - region)
        :precondition (and
            (can_move ?agent)
            (entity_in ?agent ?from)
            (region_connected ?from ?to)
            (not (agent_is_near_something ?agent))
        )
        :effect (and
            (entity_in ?agent ?to)
            (not (entity_in ?agent ?from))
        )
    )

    (:action staff_move_from_ent_to
        :parameters (?agent - staff ?from - entity ?in - region ?to - region)
        :precondition (and
            (can_move ?agent)
            (entity_in ?agent ?in)
            (entity_in ?from ?in)
            (region_connected ?in ?to)
            (agent_near ?agent ?from)
            (agent_is_near_something ?agent)
        )
        :effect (and
            (entity_in ?agent ?to)
            (not (entity_in ?agent ?in))
            (not (agent_near ?agent ?from))
            (not (agent_is_near_something ?agent))
        )
    )

    (:action approach_from_region
        :parameters (?agent - agent ?to - entity ?in - region)
        :precondition (and
            (entity_in ?to ?in)
            (entity_in ?agent ?in)
            (not (agent_is_near_something ?agent))
        )
        :effect (and
            (agent_near ?agent ?to)
            (agent_is_near_something ?agent)
        )
    )

    (:action approach_from_entity
        :parameters (?agent - agent ?from - entity ?to - entity ?in - region)
        :precondition (and
            (entity_in ?from ?in)
            (entity_in ?to ?in)
            (entity_in ?agent ?in)
            (agent_near ?agent ?from)
            (agent_is_near_something ?agent)
        )
        :effect (and
            (not (agent_near ?agent ?from))
            (agent_near ?agent ?to)
        )
    )

    (:action say
        :parameters (?robot - robot ?staff - staff ?message - message ?region - region)
        :precondition (and
            (entity_in ?robot ?region)
            (entity_in ?staff ?region)
            (agent_near ?robot ?staff)
        )
        :effect (and
            (said ?robot ?staff ?message)
        )
    )

    (:action delegate_task
        :parameters (?robot - robot ?staff - staff ?message - message ?region - region)
        :precondition (and
            (entity_in ?robot ?region)
            (entity_in ?staff ?region)
            (agent_near ?robot ?staff)
            (said ?robot ?staff ?message)
            (not (task_assigned ?staff ?message))
        )
        :effect (and
            (delegated ?robot ?staff ?message)
            (task_assigned ?staff ?message)
        )
    )

    ; Staff loads the requested item directly into the robot basket. This is
    ; only possible before the task is formally delegated away.
    (:action robot_receive
        :parameters (?robot - robot ?staff - staff ?item - item ?surface - surface ?region - region ?message - message)
        :precondition (and
            (said ?robot ?staff ?message)
            (not (delegated ?robot ?staff ?message))
            (requested_item ?message ?item)
            (entity_in ?robot ?region)
            (entity_in ?staff ?region)
            (entity_in ?surface ?region)
            (entity_in ?item ?region)
            (object_at ?item ?surface)
            (agent_near ?robot ?staff)
            (agent_near ?staff ?item)
            (robot_basket_empty ?robot)
        )
        :effect (and
            (agent_has ?robot ?item)
            (not (robot_basket_empty ?robot))
            (not (object_at ?item ?surface))
            (not (entity_in ?item ?region))
            (not (agent_near ?staff ?item))
            (agent_near ?staff ?surface)
        )
    )

    ; Staff can hold multiple items at a time.
    (:action staff_grab
        :parameters (?staff - staff ?item - item ?surface - surface ?region - region ?message - message)
        :precondition (and
            (task_assigned ?staff ?message)
            (requested_item ?message ?item)
            (entity_in ?staff ?region)
            (entity_in ?surface ?region)
            (entity_in ?item ?region)
            (object_at ?item ?surface)
            (agent_near ?staff ?item)
        )
        :effect (and
            (agent_has ?staff ?item)
            (not (object_at ?item ?surface))
            (not (entity_in ?item ?region))
            (not (agent_near ?staff ?item))
            (agent_near ?staff ?surface)
        )
    )

    (:action robot_deliver
        :parameters (?robot - robot ?requester - requester ?item - item ?region - region)
        :precondition (and
            (entity_in ?robot ?region)
            (entity_in ?requester ?region)
            (agent_near ?robot ?requester)
            (agent_has ?robot ?item)
        )
        :effect (and
            (agent_has ?requester ?item)
            (not (agent_has ?robot ?item))
            (robot_basket_empty ?robot)
        )
    )

    (:action staff_deliver
        :parameters (?staff - staff ?requester - requester ?item - item ?region - region ?message - message)
        :precondition (and
            (task_assigned ?staff ?message)
            (requested_item ?message ?item)
            (entity_in ?staff ?region)
            (entity_in ?requester ?region)
            (agent_near ?staff ?requester)
            (agent_has ?staff ?item)
        )
        :effect (and
            (agent_has ?requester ?item)
            (not (agent_has ?staff ?item))
        )
    )
)
