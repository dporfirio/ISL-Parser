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
            item surface container - inanimate
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
        (is_open ?cont - container) ; NL: [1] is open

        ; General predicates - DO NOT MODIFY
        ; PREDICATES BELOW THIS LINE!
        ;
        ; AGENTS (i.e., robots, humans)
        ; the agent can only traverse regions, and
        ; thus can only be IN a region.
        ; the agent is ALWAYS in a region
        (agent_near ?agent - robot ?entity - entity)       ; NL: [0] near [1]

        ; OBJECTS
        ; an object can theoretically be at any location.
        (object_at ?object - item ?location - surface)              ; NL: [0] at [1]
        (item_inside ?item - item ?cont - container)           ; NL: [0] is inside [1]
        ; all objects must be in a region
        (entity_in ?object - entity ?region - region)         ; NL: [0] in [1]
        
        ; ITEM ACCESSIBILITY
        (accessible ?location - entity)                       ; INTERNAL
        
        ; ITEM ATTRIBUTES
        (is_grabbable ?object - item)                            ; INTERNAL
        (is_openable ?cont - container)                             ; INTERNAL

        ; REQUEST 
        (requested ?agent - robot ?item - item ?person - person) ; NL: [0] requested [1] from [2]

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
    (:action move_to ; NL: [0] moves to [1]
        :parameters (?agent - robot ?to - region)
        :precondition ()
        :effect (and (entity_in ?agent ?to)
                     (forall (?r - region) 
                             (when (not (= ?to ?r)) (not (entity_in ?agent ?r))))
                     (forall (?nr - entity) (not (agent_near ?agent ?nr))))
    )


    (:action approach ; NL: [0] approaches [1]
        :parameters (?agent - robot ?to - entity)
        :precondition (and (accessible ?to)
                           (exists (?r - region)
                                   (and (entity_in ?to ?r)
                                         (entity_in ?agent ?r)
                                   )
                           ))
        :effect (and 
                    (forall (?nr - entity)(not (agent_near ?agent ?nr)))
                     (agent_near ?agent ?to)
                                                  
                     (forall (?r - region) 
                             (and (when (not (entity_in ?to ?r))
                                       (not (entity_in ?agent ?r)))
                                 (when (entity_in ?to ?r)
                                       (entity_in ?agent ?r)))
                     )
                )
    )

    (:action grab ; NL: [0] grabs [1]
        :parameters (?agent - robot ?item - item)
        :precondition (and (agent_near ?agent ?item)
                       (can_carry ?agent)
                       (accessible ?item))
        :effect (and (agent_has ?agent ?item)
                 (not (can_carry ?agent))
                 (not (accessible ?item))
                 (forall (?s - surface)
                         (when (object_at ?item ?s)
                               (and (agent_near ?agent ?s)
                                    (not (object_at ?item ?s))
                               )
                         )
                 )
                 (forall (?r - region) (not (entity_in ?item ?r)))
                 (not (agent_near ?agent ?item)))
    )

    (:action put_on_surface ; NL: [0] puts [1] on [2]
        :parameters (?agent - robot ?item - item ?surface - surface)
        :precondition (and (agent_near ?agent ?surface)
                       (not (object_at ?item ?surface))
                       (not (can_carry ?agent))
                       (agent_has ?agent ?item))
        :effect (and (not (agent_has ?agent ?item))
                 (can_carry ?agent)
                 (accessible ?item)
                 ;(is_grabbable ?item)
                 (object_at ?item ?surface)
                 (forall (?r - region)
                         (when (entity_in ?surface ?r)
                               (entity_in ?item ?r)
                         )
                 )
        )
    )

    ;; the items inside the container are accessible when the container is open
    (:action open ; NL: [0] opens [1]
        :parameters (?agent - robot ?cont - container)
        :precondition (and (agent_near ?agent ?cont)
                           (is_openable ?cont)
                           (not (is_open ?cont)))
        :effect (and (is_open ?cont)
                (forall (?item - item) 
                        (when (item_inside ?item ?cont) 
                              (and (accessible ?item) ))))
    )


    ;; close the container and make all items inside are not accessible
  (:action close ; NL: [0] closes [1]
        :parameters (?agent - robot ?cont - container)
        :precondition (and (agent_near ?agent ?cont)
                           (is_openable ?cont)
                           (is_open ?cont))
        :effect (and (not (is_open ?cont))
                (forall (?item - item) 
                        (when (item_inside ?item ?cont) 
                              (and (not (accessible ?item))
                                   (not (is_grabbable ?item))))))
                
        )   

   ;; request from person for a item
   (:action request ; NL: [0] requests [1] from [2]
        :parameters (?agent - robot ?item - item ?giver - person)
        :precondition (and (agent_near ?agent ?giver)
                          (not (requested ?agent ?item ?giver))) ;can't request twice
        :effect (requested ?agent ?item ?giver)
        )    

  ;; receive from a person, only happen after request, the agent can no longer carry anything and the item is not accessible anymore. The item is also not inside the container anymore and is not in any region.
  (:action receive ; NL: [0] receives [1] from [2]
        :parameters (?agent - robot ?item - item ?giver - person)
        :precondition (and (requested ?agent ?item ?giver)
                           (can_carry ?agent)
                           (agent_has ?giver ?item)
                           (agent_near ?agent ?giver))
        :effect (and (agent_has ?agent ?item)
                     (not (can_carry ?agent))
                     (not (accessible ?item))
                     (not (agent_has ?giver ?item))
                     (not (requested ?agent ?item ?giver))
                     (forall (?r - region) 
                          (not (entity_in ?item ?r)))
        )
    )  
  
  ;; deliver object to a person, after delivering the item, the agent can carry and the item is not accessible anymore. The item is also not inside the container anymore and is not in any region.
 (:action deliver ; NL: [0] delivers [1] to [2]
        :parameters (?agent - robot ?item - item ?recipient - person)
        :precondition (and (agent_has ?agent ?item)
                           (agent_near ?agent ?recipient))
    :effect (and (not (agent_has ?agent ?item))
                 (can_carry ?agent)
                 (not (accessible ?item))
                (forall (?r - region)
                        (when (entity_in ?recipient ?r)
                              (entity_in ?item ?r)))
    )
)
   
  
  ;; wipe action from cleaning, do we need to assume that the area was dirty and now is clean? or just perfor the action?


  ;; dump action from cleaning, like grabe a water and dump to sink? Assume robot has dustbin / water tank? 


;; report action from patrol, send a messgae to the user about the state of the world, for example,  "the patient need help", 

)