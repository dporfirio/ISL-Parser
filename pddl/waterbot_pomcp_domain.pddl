; =======================================
; GENERAL
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
(define (domain general)
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
            cell - world
            region_cell - cell
            surface_cell - cell

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
        (agent_has ?agent - agent ?thing - item) ; NL: [0] has [1]
        (available_to ?thing - item ?agent - agent) ; INTERNAL
        (is_full ?thing - item) ; NL: [0] is full
        (traversable_to_cell ?from - cell ?to - cell) ; NL: can traverse from [0] to [1]
        (entity_at_cell ?object - entity ?cell - cell) ; NL: [0] at [1]
        (cell_in_surface ?cell - cell ?surface - surface) ; NL: [0] in [1]
        (cell_in_region ?cell - cell ?region - region) ; NL: [0] in [1]
        (gripper_free)  ; NL: gripper is free



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
        (default)                                                    ; NL: no change
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
    ; 
    ; DO NOT MODIFY THE FOLLOWING 3
    ; GENERAL ACTIONS!

    ; ----- ACTION #0: IDLE -----
    
    ; -- Description: No action executes.  
    ; -- Pre-condition: No pre-conditions.
    ; -- Post-condition: "Null" action.

    ;  idle is the "null" action.
    (:action idle ; NL: [0] idles
        :parameters (?agent - agent)
        :precondition ()
        :effect (default)
    )

    ; ----- ACTION #1: MOVE TO -----
    
    ; -- Description: The agent moves to the target region.
    ; -- Pre-condition: No preconditions.
    ; -- Post-condition: 
            ; (1) An agent is in the target region.
            ; (2) For all other regions, the agent is not in those regions. 

    ;  The robot always exists in a region and can move
    ;  between regions.
    (:action move_to ; NL: [0] moves from [1] to [2]
        :parameters (?agent - agent ?from - cell ?to - region_cell)
        :precondition (and (entity_at_cell ?agent ?from)
                           (traversable_to_cell ?from ?to))
        :effect (and (entity_at_cell ?agent ?to)
                     (not (entity_at_cell ?agent ?from))
                     (forall (?r - region)
                             (and (when (not (cell_in_region ?to ?r))
                                        (not (entity_in ?agent ?r)))
                                  (when (cell_in_region ?to ?r) 
                                        (entity_in ?agent ?r))
                             )
                     )
                     (forall (?i - item)
                             (and (when (not (entity_at_cell ?i ?to))
                                        (not (agent_near ?agent ?i)))
                                  (when (entity_at_cell ?i ?to) 
                                        (agent_near ?agent ?i))
                             )
                     )
                     (forall (?s - surface)
                             (not (agent_near ?agent ?s))
                     )
                )
    )

    ; ----- ACTION #2: APPROACH -----
    
    ; -- Description: The agent approaches an object.
    ; -- Pre-condition: The agent can access an object.
    ; -- Post-condition:
            ; (1) An agent is near the entity of interest.
            ; (2) For all other entities, the agent is not near those entities.
            ; (3) For all regions:
                    ; If the entity of interest is not in the region, then the agent is also not in the region.
                    ; If the entity of interest is in the region, then the agent is also in the region.
    
    ;  The robot can "approach" entities in the world.
    ;  the robot can only focus on one entity at a time.
    (:action approach_surface ; NL: [0] moves from [1] and approaches [2]
        :parameters (?agent - agent ?from - cell ?to - surface_cell)
        :precondition (and (entity_at_cell ?agent ?from)
                           (traversable_to_cell ?from ?to))
        :effect (and (entity_at_cell ?agent ?to)
                     (not (entity_at_cell ?agent ?from))
                     (forall (?r - region)
                             (and (when (not (cell_in_region ?to ?r))
                                        (not (entity_in ?agent ?r)))
                                  (when (cell_in_region ?to ?r) 
                                        (entity_in ?agent ?r))
                             )
                     )
                     (forall (?s - surface)
                             (and (when (not (cell_in_surface ?to ?s))
                                        (not (agent_near ?agent ?s)))
                                  (when (cell_in_surface ?to ?s) 
                                        (agent_near ?agent ?s))
                             )
                     )
                     (forall (?i - item)
                             (and (when (not (entity_at_cell ?i ?to))
                                        (not (agent_near ?agent ?i)))
                                  (when (entity_at_cell ?i ?to) 
                                        (agent_near ?agent ?i))
                             )
                     )
                )
    )

    ; =============================
    ; USER: Add custom actions here
    ;  |
    ;  v
    (:action offer ; NL: [0] offers [1] [2]
        :parameters (?from - agent ?to - agent ?thing - item)
        :precondition (and (agent_near ?from ?to)
                           (agent_has ?from ?thing))
        :effect (and (available_to ?thing ?to))
    )

    (:action take ; NL: [0] takes [1]
        :parameters (?agent - agent ?thing - item)
        :precondition (and (available_to ?thing ?agent))
        :effect (and (forall (?a - agent) (not (agent_has ?a ?thing)))
                     (agent_has ?agent ?thing))
    )

    ; ----- ACTION #3: GRAB -----

    ; -- Description: The robot goes to fetch an item.
    ; -- Pre-condition:
    ;         (1)   The agent is near the object
    ;         (2-3) The object is both grabbable and accessible
    ;         (4-5) The robot's gripper is free
    ; -- Post-condition:
    ;         (1)   The object is no longer in any region
    ;         (2)   The agent is no longer near the object
    ;         (3-4) The agent is carrying the object and its gripper is no longer free.

    (:action grab ; NL: [0] grabs [1]
        :parameters (?agent - robot ?object - item)
        :precondition (and 
            (agent_near ?agent ?object)
            (is_grabbable ?object)
            (accessible ?object)
            (gripper_free)
        )
        :effect (and 
            (forall (?r - region) (not (entity_in ?object ?r)))
            (not (agent_near ?agent ?object))
            (agent_has ?agent ?object)
            (not (accessible ?object))
            (not (gripper_free))
        )
    )

    ; ----- ACTION #4: PUT -----

    ; -- Description: The robot puts down an item.
    ; -- Pre-condition:
    ;          (1) The agent is near the place to put the item
    ;          (2) The agent is carrying the item to put
    ; -- Post-condition:
    ;          (1)   The item is at the location.
    ;          (2-3) The agent's gripper is free and the robot is no longer carrying the item.
    ;          (4)   The item is accessible.

    (:action put   ; NL [0] puts [1] in [2]
        :parameters (?agent - robot ?object - item ?location - inanimate)
        :precondition (and 
            (agent_near ?agent ?location)
            (agent_has ?agent ?object)
            (not (gripper_free))
        )
        :effect (and 
            (object_at ?object ?location)
            (accessible ?object)
            (not (agent_has ?agent ?object))
            (gripper_free)
        )
    )
)