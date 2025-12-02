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
            ; uitem is unique item, citem is consumable item
            world bookkeeping - object
            region entity - world
            agent inanimate - entity
            item surface container - inanimate
            objectsurface floor - surface 
            uitem citem tool - item 
            vacuum_tool wiper_tool - tool
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
    (:constants unknown_region - region
    )

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
        (person_has ?person - person ?object - item)              ; NL: [0] has [1]
        (is_open ?cont - container) ; NL: [1] is open

        ; General predicates - DO NOT MODIFY
        ; PREDICATES BELOW THIS LINE!
        ;
        ; AGENTS (i.e., robots, humans)
        ; the agent can only traverse regions, and
        ; thus can only be IN a region.
        ; the agent is ALWAYS in a region
        (agent_near ?agent - robot ?entity - entity)       ; NL: [0] near [1]
        (agent_is_near_something)  ; INTERNAL

        ; OBJECTS
        ; an object can theoretically be at any location.
        (object_at ?object - item ?location - surface)              ; NL: [0] at [1]
        (item_inside ?item - item ?cont - container)           ; NL: [0] is inside [1]
        ; all objects must be in a region
        (entity_in ?object - entity ?region - region)         ; NL: [0] in [1]
        
        ; ITEM ACCESSIBILITY
        ; (accessible ?location - entity)                       ; INTERNAL
        
        ; ITEM ATTRIBUTES
        (is_openable ?cont - container)                             ; INTERNAL

        ;surface is dirty
        (is_clean ?surface - surface)                             ; NL: [0] is dirty
        (has_item ?surface - surface)                             ; NL: [0] has an item

        ; is tool
        (is_tool ?item - item)                                   ; NL: [0] is a tool

        ; REQUEST 
        (requested ?agent - robot ?item - item ?person - person) ; NL: [0] requested [1] from [2]

        ; META ACTIONS
        (is_moving) ; NL: is moving
        (is_approaching) ; NL: is approaching
        (is_grabbing) ; NL: is grabbing
        (is_putting) ; NL: is putting
        (is_opening) ; NL: is opening
        (is_closing) ; NL: is closing
        (is_requesting) ; NL: is requesting
        (is_receiving) ; NL: is receiving
        (is_delivering) ; NL: is delivering
        (is_wiping) ; NL: is wiping
        (is_vacuuming) ; NL: is vacuuming

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
    (:action move_from_reg_to ; NL: [0] moves from [1] to [2]
        :parameters (?agent - robot ?from - region ?to - region)
        :precondition (and (entity_in ?agent ?from)
                           (not (agent_is_near_something)))
        :effect (and (entity_in ?agent ?to)
                     (not (entity_in ?agent ?from))
                     (not (agent_is_near_something))
                     (is_moving)
                     (not is_approaching)
                     (not is_grabbing)
                     (not is_putting)
                     (not is_opening)
                     (not is_closing)
                     (not is_requesting)
                     (not is_receiving)
                     (not is_delivering))
    )

    (:action move_from_ent_to ; NL: [0] moves from [1] to [3]
        :parameters (?agent - robot ?from - entity ?in - region ?to - region)
        :precondition (and (entity_in ?agent ?in)
                           (entity_in ?from ?in)
                           (agent_near ?agent ?from)
                           (agent_is_near_something))
        :effect (and (entity_in ?agent ?to)
                     (not (entity_in ?agent ?in))
                     (not (agent_near ?agent ?from))
                     (not agent_is_near_something)
                     (is_moving)
                     (not is_approaching)
                     (not is_grabbing)
                     (not is_putting)
                     (not is_opening)
                     (not is_closing)
                     (not is_requesting)
                     (not is_receiving)
                     (not is_delivering))
    )


    (:action approach_from_region ; NL: [0] approaches [1] in [2]
        :parameters (?agent - robot ?to - entity ?in - region)
        :precondition (and ; (accessible ?to)
                           (entity_in ?to ?in)
                           (entity_in ?agent ?in)
                           (not (agent_is_near_something)))
        :effect (and 
                    (agent_near ?agent ?to)
                    (agent_is_near_something)
                    (not is_moving)
                    (is_approaching)
                    (not is_grabbing)
                    (not is_putting)
                    (not is_opening)
                    (not is_closing)
                    (not is_requesting)
                    (not is_receiving)
                    (not is_delivering)
                )
    )

    (:action approach_from_entity ; NL: [0] approaches [2] from [1]
        :parameters (?agent - robot ?from - entity ?to - entity ?in - region)
        :precondition (and ; (accessible ?to)
                           (entity_in ?to ?in)
                           (entity_in ?agent ?in)
                           (agent_near ?agent ?from)
                           (agent_is_near_something))
        :effect (and 
                    (not (agent_near ?agent ?from))
                    (agent_near ?agent ?to)
                    (agent_is_near_something)
                    (not is_moving)
                    (is_approaching)
                    (not is_grabbing)
                    (not is_putting)
                    (not is_opening)
                    (not is_closing)
                    (not is_requesting)
                    (not is_receiving)
                    (not is_delivering)
                )
    )

    (:action grab ; NL: [0] grabs [1] from [2] in [3]
        :parameters (?agent - robot ?item - item ?surface - surface ?region - region)
        :precondition (and (agent_near ?agent ?item)
                       (can_carry ?agent)
                       ; (accessible ?item)
                       (entity_in ?item ?region)
                       (entity_in ?agent ?region)
                       (entity_in ?surface ?region)
                       (object_at ?item ?surface))
        :effect (and (agent_has ?agent ?item)
                 (not (can_carry ?agent))
                 ; (not (accessible ?item))
                 (agent_near ?agent ?surface)      ;when grab, the robot near the surface, but when put_on surface, agent is not near the surface? make the agent only near one entity at a time? 
                 (not (object_at ?item ?surface))
                 (not (entity_in ?item ?region))
                 (not (agent_near ?agent ?item))
                 (not is_moving)
                 (not is_approaching)
                 (is_grabbing)
                 (not is_putting)
                 (not is_opening)
                 (not is_closing)
                 (not is_requesting)
                 (not is_receiving)
                 (not is_delivering))
    )

    (:action grab_from_inside ; NL: [0] grabs [1] from [2] in [3]
        :parameters (?agent - robot ?item - item ?container - container ?region - region)
        :precondition (and (agent_near ?agent ?item)
                       (can_carry ?agent)
                       ; (accessible ?item)
                       (entity_in ?item ?region)
                       (entity_in ?agent ?region)
                       (entity_in ?container ?region)
                       (is_open ?container)
                       (item_inside ?item ?container))
        :effect (and (agent_has ?agent ?item)
                 (not (can_carry ?agent))
                 ; (not (accessible ?item))
                 (agent_near ?agent ?container)
                 (not (item_inside ?item ?container))
                 (not (entity_in ?item ?region))
                 (not (agent_near ?agent ?item))
                 (not is_moving)
                 (not is_approaching)
                 (is_grabbing)
                 (not is_putting)
                 (not is_opening)
                 (not is_closing)
                 (not is_requesting)
                 (not is_receiving)
                 (not is_delivering))
    )

    (:action put_on_surface ; NL: [0] puts [1] on [2]
        :parameters (?agent - robot ?item - item ?surface - surface ?region - region)
        :precondition (and (agent_near ?agent ?surface)
                       (not (object_at ?item ?surface))
                       (not (is_tool ?item))  ; vacume can not be put on surface
                       (not (can_carry ?agent))
                       (agent_has ?agent ?item)
                       (entity_in ?surface ?region))
        :effect (and (not (agent_has ?agent ?item))
                 (can_carry ?agent)
                 ; (accessible ?item)
                 ;(is_grabbable ?item)
                 (not (agent_near ?agent ?surface))
                 (agent_near ?agent ?item)
                 (object_at ?item ?surface)
                 (entity_in ?item ?region)
                 (not is_moving)
                 (not is_approaching)
                 (not is_grabbing)
                 (is_putting)
                 (not is_opening)
                 (not is_closing)
                 (not is_requesting)
                 (not is_receiving)
                 (not is_delivering)
        )
    )

    ; robot needs to put the tool back to the storage cabinet before grabing other items
   (:action put_tool_back ; NL: [0] puts back [1] into [2] in [3]
    :parameters (?agent - robot ?item - tool ?container - container ?region - region)
    :precondition (and (agent_near ?agent ?container)
                       (not (item_inside ?item ?container))
                       (not (can_carry ?agent))
                       (is_open ?container)
                       (entity_in ?container ?region)  ; Add this!
                       (entity_in ?agent ?region)       ; Add this!
                       (agent_has ?agent ?item))
    :effect (and (not (agent_has ?agent ?item))
                 (can_carry ?agent)
                 (agent_near ?agent ?item)
                 (not (agent_near ?agent ?container))
                 (item_inside ?item ?container)
                 (entity_in ?item ?region)              ; Add this!
                 (not is_moving)
                 (not is_approaching)
                 (not is_grabbing)
                 (is_putting)
                 (not is_opening)
                 (not is_closing)
                 (not is_requesting)
                 (not is_receiving)
                 (not is_delivering)
    )
)

    ;; the items inside the container are accessible when the container is open
    (:action open ; NL: [0] opens [1]
        :parameters (?agent - robot ?cont - container)
        :precondition (and (agent_near ?agent ?cont)
                           (is_openable ?cont)
                           (not (is_open ?cont)))
        :effect (and (is_open ?cont)
                ;(forall (?item - item) 
                ;        (when (item_inside ?item ?cont) 
                ;              (and (accessible ?item) )))
                (not is_moving)
                (not is_approaching)
                (not is_grabbing)
                (not is_putting)
                (is_opening)
                (not is_closing)
                (not is_requesting)
                (not is_receiving)
                (not is_delivering)
                )
    )


    ;; close the container and make all items inside are not accessible
    (:action close ; NL: [0] closes [1]
        :parameters (?agent - robot ?cont - container)
        :precondition (and (agent_near ?agent ?cont)
                           (is_openable ?cont)
                           (is_open ?cont))
        :effect (and (not (is_open ?cont))
                ;(forall (?item - item) 
                ;        (when (item_inside ?item ?cont) 
                ;              (not (accessible ?item))))
                (not is_moving)
                (not is_approaching)
                (not is_grabbing)
                (not is_putting)
                (not is_opening)
                (is_closing)
                (not is_requesting)
                (not is_receiving)
                (not is_delivering)
                )
                
   )   

   ;; request from person for a item
   (:action request ; NL: [0] requests [1] from [2]
        :parameters (?agent - robot ?item - item ?giver - person ?region - region)
        :precondition (and (agent_near ?agent ?giver)
                          (entity_in ?agent ?region)
                          (entity_in ?giver ?region)
                          (not (requested ?agent ?item ?giver))) ;can't request twice
        :effect (and (requested ?agent ?item ?giver)
                     (not is_moving)
                     (not is_approaching)
                     (not is_grabbing)
                     (not is_putting)
                     (not is_opening)
                     (not is_closing)
                     (is_requesting)
                     (not is_receiving)
                     (not is_delivering))
        )    

  ;; receive a unique item from a person, only happen after request, the agent can no longer carry anything and the item is not accessible anymore. The item is also not inside the container anymore and is not in any region.
  (:action receive_uitem ; NL: [0] receives [1] from [2]
        :parameters (?agent - robot ?item - uitem ?giver - person ?region - region)
        :precondition (and (requested ?agent ?item ?giver)
                           (agent_has ?giver ?item)
                           (can_carry ?agent)
                           (agent_near ?agent ?giver)
                           (entity_in ?agent ?region)
                           (entity_in ?giver ?region))
                          
        :effect (and (agent_has ?agent ?item)
                     (not (can_carry ?agent))
                     ;(not (accessible ?item))
                     (not (agent_has ?giver ?item))
                     (not (requested ?agent ?item ?giver))
                     (not (entity_in ?item ?region))
                     ; only remove when the giveer doesn't have supply of the item
                     (not (agent_has ?giver ?item))
                     (not is_moving)
                     (not is_approaching)
                     (not is_grabbing)
                     (not is_putting)
                     (not is_opening)
                     (not is_closing)
                     (not is_requesting)
                     (is_receiving)
                     (not is_delivering)
        )
    )
 (:action receive_citem ; NL: [0] receives [1] from [2]
        :parameters (?agent - robot ?item - citem ?giver - person ?region - region)
        :precondition (and (requested ?agent ?item ?giver)
                           (agent_has ?giver ?item)
                           (can_carry ?agent)
                           (agent_near ?agent ?giver)
                           (entity_in ?agent ?region)
                           (entity_in ?giver ?region))
                          
        :effect (and (agent_has ?agent ?item)
                     (not (can_carry ?agent))
                     ;(not (accessible ?item))
                     (not (agent_has ?giver ?item))
                     (not (requested ?agent ?item ?giver))
                     (not is_moving)
                     (not is_approaching)
                     (not is_grabbing)
                     (not is_putting)
                     (not is_opening)
                     (not is_closing)
                     (not is_requesting)
                     (is_receiving)
                     (not is_delivering)
        )
    )
  
  ;; deliver object to a person, after delivering the item, the agent can carry and the item is not accessible anymore. The item is also not inside the container anymore and is not in any region.
 (:action deliver ; NL: [0] delivers [1] to [2]
        :parameters (?agent - robot ?item - item ?person - person)
        :precondition (and (agent_has ?agent ?item)
                           (agent_near ?agent ?person))
    :effect (and (person_has ?person ?item)
                 (not (agent_has ?agent ?item))
                 (can_carry ?agent)
                 ;(not (accessible ?item))
                 (not is_moving)
                 (not is_approaching)
                 (not is_grabbing)
                 (not is_putting)
                 (not is_opening)
                 (not is_closing)
                 (not is_requesting)
                 (not is_receiving)
                 (is_delivering)
    )
)
   
  
  ;; wipe action from cleaning, do we need to assume that the area was dirty and now is clean? or just perfor the action?
(:action wipe ; NL: [0] wipes [1]
    :parameters (?agent - robot ?surface - objectsurface ?region - region ?tool - wiper_tool)
    :precondition (and (agent_near ?agent ?surface)
                       (entity_in ?agent ?region)
                       (entity_in ?surface ?region)
                       (agent_has ?agent ?tool))
    :effect (and (is_clean ?surface)
                (not is_moving)
                (not is_approaching)
                (not is_grabbing)
                (not is_putting)
                (not is_opening)
                (not is_closing)
                (not is_requesting)
                (not is_receiving)
                (not is_delivering)
                (is_wiping)
            )
)

  ;; dump action from cleaning, like grabe a water and dump to sink? Assume robot has dustbin / water tank? 


(:action vacuum_floor ; NL: [0] vacuums [1] in [2]
    :parameters (?agent - robot ?floor - floor ?region - region ?tool - vacuum_tool)  ; Changed from uitem to tool
    :precondition (and (entity_in ?agent ?region)
                       (entity_in ?floor ?region)
                       (agent_has ?agent ?tool)
                       (not(is_clean ?floor)))  ; Add this!
    :effect (and (is_clean ?floor)  ; Add this!
                 (not is_moving)
                 (not is_approaching)
                 (not is_grabbing)
                 (not is_putting)
                 (not is_opening)
                 (not is_closing)
                 (not is_requesting)
                 (not is_receiving)
                 (not is_delivering)
                 (not is_wiping)  
                 (is_vacuuming)
                 )
)

)