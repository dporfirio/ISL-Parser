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
(define (domain food_assembly)
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
            end_effector - world

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
        (owns_gripper ?agent - agent ?gripper - end_effector)    ; INTERNAL
        (is_free ?gripper - end_effector)                        ; INTERNAL
        (agent_has ?agent - agent ?object - item)              ; NL: [0] is carrying [1]
        (is_open ?object - item)                                 ; NL: [0] is open
        (available_to ?from - agent ?object - item ?to - agent)             ; INTERNAL

        ; General predicates - DO NOT MODIFY
        ; PREDICATES BELOW THIS LINE!
        ;
        ; AGENTS (i.e., robots, humans)
        ; the agent can only traverse regions, and
        ; thus can only be IN a region.
        ; the agent is ALWAYS in a region
        ; (agent_in ?agent - agent ?region - region)               ; NL: [0] in [1]
        ; the agent is near an entity of interest
        ; the agent is NOT always near something
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
    (:action move_to ; NL: [0] moves to [1]
        :parameters (?agent - agent ?to - region)
        :precondition ()
        :effect (and (entity_in ?agent ?to)
                     (forall (?r - region) (not (entity_in ?agent ?r)))
                     (forall (?nr - entity) (not (agent_near ?agent ?nr))))
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
    (:action approach ; NL: [0] approaches [1]
        :parameters (?agent - agent ?to - entity)
        :precondition (accessible ?to)
        :effect (and (agent_near ?agent ?to)
                     (forall (?nr - entity) (not (agent_near ?agent ?nr)))
                     (forall (?r - region) 
                             (and (when (not (entity_in ?to ?r))
                                       (not (entity_in ?agent ?r)))
                                 (when (entity_in ?to ?r)
                                       (entity_in ?agent ?r)))
                     )
                )
    )

    ; =============================
    ; USER: Add custom actions here
    ;  |
    ;  v

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
        :parameters (?agent - agent ?object - item ?gripper - end_effector)
        :precondition (and 
            (agent_near ?agent ?object)
            (is_grabbable ?object)
            (accessible ?object)
            (is_free ?gripper)
            (owns_gripper ?agent ?gripper)
        )
        :effect (and 
            (forall (?r - region) (not (entity_in ?object ?r)))
            (forall (?s - surface) (not (object_at ?object ?s)))
            (not (agent_near ?agent ?object))
            (not (is_free ?gripper))
            (agent_has ?agent ?object)
            (not (is_grabbable ?object))
            (not (accessible ?object))
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
        :parameters (?agent - agent ?object - item ?location - inanimate ?gripper - end_effector)
        :precondition (and 
            (agent_near ?agent ?location)
            (agent_has ?agent ?object)
        )
        :effect (and 
            (object_at ?object ?location)
            (is_free ?gripper)
            (not (agent_has ?agent ?object))
            (accessible ?object)
            (is_grabbable ?object)
            (accessible ?object)
        )
    )

    ; ----- ACTION #5: OPEN -----

    ; -- Description: The robot opens an item.
    ; -- Pre-condition:
    ;           (1)   The item is openable.
    ;           (2-3) The agent's gripper is free.
    ;           (4)   The agent is near the item to open.
    ; -- Post-condition: 
    ;           (1) The item is open
    ;           (2) Everything inside of the item is accessible

    (:action open ; NL: [0] opens [1]
        :parameters (?agent - agent ?object - item ?gripper - end_effector)
        :precondition (and
            (is_openable ?object)
            (is_free ?gripper)
            (owns_gripper ?agent ?gripper)
            (agent_near ?agent ?object)
        )
        :effect (and (is_open ?object)
                     (forall (?i - item)
                             (when (object_at ?i ?object)
                                   (accessible ?i))))
    )

    ; ----- ACTION #6: OFFER -----

    ; -- Description: The agent "from" offers an object to the agent "to".
    ; -- Pre-condition:
    ;           (1) The agent "from" is near the agent "to".
    ;           (2) The agent "from" is carrying the object.
    ; -- Post-condition: The object is available to the agent "to".

    (:action offer ; NL: [0] offers [1] to [2]
        :parameters (?from - agent ?thing - item ?to - agent)
        :precondition (and (agent_near ?from ?to)
                           (agent_has ?from ?thing))
        :effect (and (available_to ?from ?thing ?to ))
    )

    ; ----- ACTION #7: TAKE_FROM -----

    ; -- Description: The agent takes the object from another agent.
    ; -- Pre-condition: 
    ;           (1) The object is available to the agent.
    ;           (2) The agent that offered the object still has it.
    ;           (3) The agent that offered the object is still near the agent taking it.
    ; -- Post-condition:
    ;           (1) None of the other agents have the object.
    ;           (2) The agent is carrying the object.
    ;           (3) Mark object as no longer available_to since the handover is complete.

    (:action take_from ; NL: [0] takes [1] from [2]
        :parameters (?to - agent ?thing - item ?from - agent)
        :precondition (and (available_to ?from ?thing ?to)
                           (agent_has ?from ?thing)
                           (agent_near ?from ?to))
        :effect (and (forall (?a - agent) (not (agent_has ?a ?thing)))
                     (agent_has ?to ?thing)
                     (not (available_to ?from ?thing ?to))
                     (forall (?g - end_effector)
                             (when (owns_gripper ?from ?g)
                                   (is_free ?g))))
    )
)