; =======================================
; HEALTHCARE
; 
; This pddl domain is intended to provide
; constants, predicates, and actions that
; generalize to most possible human-robot
; interactions in a mobile setting.
; 
; This domain is purely intended for mob-
; -ile (ie service) interactions, as opp-
; -osed to manufacturing or industry. 
;
; The main assumption is that any human
; or robot in the domain are "mobile", ie
; able to travel to different geographic-
; -al locations (called region) and enti-
; -ties in the world.

; =============================
; USER: Rename domain here
;                 |
;                 v
(define (domain healthcare)
    (:requirements 

        ; General requirements - DO NOT
        ; MODIFY THE FOLLOWING LINE!
        :negative-preconditions :typing :conditional-effects

        ; =============================
        ; USER: Add custom requirements here
        ;  |
        ;  v

    )
    (:types 

            ; General types - DO NOT MODIFY
            ; THE FOLLOWING 5 LINES!
            world bookkeeping - object
            region entity - world
            agent inanimate - entity
            item surface - inanimate
            person robot - agent

            ; =============================
            ; USER: Add custom types here.
            ;  |    Note: all custom types
            ;  |    MUST have a parent in
            ;  |    the type tree that
            ;  |    inherits from 'world'.
            ;  |
            ;  v
    )

    ; any region that is not labeled defaults to "unknown"
    (:constants unknown_region - region)

    (:predicates

        ; predicates are specified as follows:
        ; (<symbol> [<arg1> <arg2> ...]) ; <comment>
        ; 
        ; <symbol> is the predicate symbol, i.e., it's "name"
        ; <argn> is a predicate argument. There can be 0 or more arguments.
        ; <comment> is a REQUIRED comment. Comments may take the following form:
        ; 
        ;   INTERNAL - indicates that the predicate is only used internally, i.e.,
        ;              will not be exposed to any end user.
        ;   NL: <string> - provides a natural-language form of the predicate.
        ;                  <string> can take arguments, which are placed in
        ;                  brackets. Numbers inside of the brackets indicate
        ;                  the index of the predicate arg to be inserted into
        ;                  the natural language statement.
        ; 
        ; Only one predicate should exist per line!


        ; =============================
        ; USER: Add custom predicates here
        ;  |
        ;  v
        (can_carry ?agent)                        ; INTERNAL
        (agent_has ?agent - agent ?object - item)              ; NL: [0] is carrying [1]
        (is_open ?object - item) ; NL: [1] is open

        ; General predicates - DO NOT MODIFY
        ; PREDICATES BELOW THIS LINE!
        ;
        ; AGENTS (i.e., robots, humans)
        ; the agent can only traverse regions, and
        ; thus can only be IN a region.
        ; the agent is ALWAYS in a region
        (agent_near ?agent - agent ?entity - entity)       ; NL: [0] near [1]

        ; OBJECTS
        ; an object can theoretically be at any location.
        (object_at ?object - item ?location - inanimate)              ; NL: [0] at [1]
        ; all objects must be in a region
        (entity_in ?object - entity ?region - region)         ; NL: [0] in [1]
        
        ; ITEM ACCESSIBILITY
        (accessible ?location - entity)                       ; INTERNAL
        
        ; ITEM ATTRIBUTES
        (is_grabbable ?object - item)                            ; INTERNAL
        (is_openable ?object - item)                             ; INTERNAL

        ; DUMMY predicate
        ; required for certain parsers
        (default)                                                ; NL: no change
    )



    ; Actions are specified as follows:
    ; 
    ; (:action <name> ; <comment>
    ;    :parameters (<formula>)
    ;    :precondition (<formula)
    ;    :effect (<formula>)
    ; )
    ; 
    ; <name> is the name of the operator
    ; <comment> is a comment specified similarly to predicates
    ; <formula> is a boolean formula specified in predicate logic


    ; ----- ACTION #1: MOVE TO -----
    
    ; -- Description: The agent moves from the source to the target region.
    ; -- Pre-condition: The agent must be in the source region.
    ; -- Post-condition: 
            ; (1) An agent is in the target region.
            ; (2) The agent is not in the source region.
            ; (3) The agent isn't near any entities

    ;  The robot always exists in a region and can move
    ;  between regions.
    (:action move_from_region_to_region ; NL: [0] moves from [1] to [2]
        :parameters (?agent - agent ?from - region ?to - region)
        :precondition (entity_in ?agent ?from)
        :effect (and (entity_in ?agent ?to)
                     (not (entity_in ?agent ?from))
                     (forall (?e - entity) (not (agent_near ?agent ?e)))) ; when the robot moves it is not near anything
    )

    (:action move_from_entity_to_region ; NL: [0] moves from [1] in [2] to [3]
        :parameters (?agent - agent ?from - entity ?in - region ?to - region)
        :precondition (and (entity_in ?agent ?in)
                           (agent_near ?agent ?from))
        :effect (and (entity_in ?agent ?to)
                     (not (entity_in ?agent ?in))
                     (forall (?e - entity) (not (agent_near ?agent ?e)))) ; when the robot moves it is not near anything
    )

    (:action move_from_region_to_entity ; NL: [0] moves from [1] to [2] in [3]
        :parameters (?agent - agent ?from - region ?to - entity ?in - region)
        :precondition (and (entity_in ?agent ?from)
                           (forall (?e - entity) (not (agent_near ?agent ?e))))
        :effect (and (entity_in ?agent ?in)
                     (not (entity_in ?agent ?from))
                     (agent_near ?agent ?to))
    )

    (:action move_from_entity_to_entity ; NL: [0] moves from [1] in [2] to [3] in [4]
        :parameters (?agent - agent ?from - entity ?from_in - region ?to - entity ?to_in - region)
        :precondition (and (entity_in ?agent ?from_in)
                           (agent_near ?agent ?from))
        :effect (and (entity_in ?agent ?to_in)
                     (agent_near ?agent ?to)
                     (not (agent_near ?agent ?from)))
    )

    (:action grab_from_floor ; NL: [0] grabs [1] from [2]
        :parameters (?agent - agent ?item - item ?region - region)
        :precondition (and (agent_near ?agent ?item)
                       (can_carry ?agent)
                       (accessible ?item)
                       (entity_in ?item ?region)
                       (is_grabbable ?item)
                       (forall (?surface - surface) (not (object_at ?item ?surface))))
        :effect (and (agent_has ?agent ?item)
                 (not (can_carry ?agent))
                 (not (accessible ?item))
                 (not (entity_in ?item ?region)))
    )

    (:action grab_from_surface ; NL: [0] grabs [1] from [2] in [3]
        :parameters (?agent - agent ?item - item ?surface - surface ?region - region)
        :precondition (and (agent_near ?agent ?item)
                       (can_carry ?agent)
                       (accessible ?item)
                       (object_at ?item ?surface)
                       (entity_in ?item ?region)
                       (entity_in ?surface ?region)
                       (is_grabbable ?item))
        :effect (and (agent_has ?agent ?item)
                 (not (can_carry ?agent))
                 (not (accessible ?item))
                 (not (object_at ?item ?surface))
                 (not (entity_in ?item ?region))
                 (not (agent_near ?agent ?item)))
    )

    (:action put_on_surface ; NL: [0] puts [1] on [2] in [3]
        :parameters (?agent - agent ?item - item ?surface - surface ?region - region)
        :precondition (and (agent_near ?agent ?surface)
                       (entity_in ?surface ?region)
                       (not (object_at ?item ?surface))
                       (not (entity_in ?item ?region))
                       (not (can_carry ?agent))
                       (agent_has ?agent ?item))
        :effect (and (not (agent_has ?agent ?item))
                 (can_carry ?agent)
                 (accessible ?item)
                 (entity_in ?item ?region)
                 (object_at ?item ?surface))
    )
)