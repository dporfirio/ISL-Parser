; ============================================================================
; DOMAIN: Healthcare
; ============================================================================
; 
; DESCRIPTION:
; This PDDL domain provides constants, predicates, and actions that generalize
; to most human-robot interactions in a mobile setting. It is specifically
; designed for service/mobile interactions (as opposed to manufacturing).
;
; CORE ASSUMPTION:
; All agents (humans, robots) are "mobile" - they can travel to different
; geographic locations (regions) and interact with entities in the world.
;
; ============================================================================

(define (domain kitchen)

    ; ========================================================================
    ; REQUIREMENTS
    ; ========================================================================
    (:requirements 
        ; Core PDDL requirements
        :negative-preconditions     ; Allow 'not' in preconditions
        :typing                     ; Enable type system
    )

    ; ========================================================================
    ; TYPE HIERARCHY
    ; ========================================================================
    ; The type tree must have all custom types inherit from 'world'
    ;
    ; Type Hierarchy:
    ;   world
    ;   ├── bookkeeping
    ;   └── entity
    ;       ├── agent
    ;       │   ├── person
    ;       │   └── robot
    ;       └── inanimate
    ;           ├── item
    ;           └── surface, container
    ;
    (:types 
        ; Root types
        world bookkeeping - object
        
        ; Entity types
        region entity - world
        
        ; Agent types
        agent inanimate - entity
        person robot - agent
        
        ; Item types
        item surface container - inanimate
    )


    ; ========================================================================
    ; CONSTANTS
    ; ========================================================================
    ; none


    ; ========================================================================
    ; PREDICATES
    ; ========================================================================
    ; Format: (name ?param - type ...) ; comment
    ;
    ; Comments can be:
    ;   INTERNAL          - predicate used only internally (not exposed to user)
    ;   NL: <description> - natural language form, where [0], [1], etc. are 
    ;                       replaced with argument values
    ;
    (:predicates

        ; =====================================================================
        ; CUSTOM PREDICATES (defined by user)
        ; =====================================================================

        (can_carry)  ; INTERNAL - indicates if the agent can carry an item

        (agent_has ?agent - agent ?object - item)  ; NL: [0] is carrying [1]

        (is_open ?cont - container)  ; NL: [0] is open

        (is_closed ?cont - container)  ; NL: [0] is closed


        ; =====================================================================
        ; BUILT-IN PREDICATES (core domain functionality)
        ; =====================================================================

        ; --- Agent Location and Proximity ---
        (agent_near ?agent - robot ?entity - entity)  ; NL: [0] is near [1]
            ; Indicates agent is adjacent to an entity

        (agent_is_near_something)  ; INTERNAL - true if agent is currently near any entity


        ; --- Object Placement ---
        (object_at ?object - item ?location - surface)  ; NL: [0] is on [1]
            ; Indicates item is placed on a surface

        (item_inside ?item - item ?cont - container)  ; NL: [0] is inside [1]
            ; Indicates item is stored inside a container


        ; --- Region Location ---
        (entity_in ?object - entity ?region - region)  ; NL: [0] is in [1]
            ; All entities must be in a region
    )


    ; ========================================================================
    ; ACTIONS
    ; ========================================================================
    ; Format:
    ;   (:action <name>
    ;       :parameters (<declaration>)
    ;       :precondition (<formula>)
    ;       :effect (<formula>)
    ;   )


    ; ========================================================================
    ; ACTION GROUP 1: MOVEMENT ACTIONS
    ; ========================================================================

    ; ACTION: Move between regions
    ; DESCRIPTION: Agent moves from one region to another
    ; PRECONDITIONS:
    ;   - Agent must be in source region
    ;   - Agent is not near any entities
    ;   - Robot drawer is closed
    ; EFFECTS:
    ;   - Agent moves to target region
    ;   - Agent no longer in source region
    (:action move_from_reg_to  ; NL: [0] moves from [1] to [2]
        :parameters (?agent - robot ?from - region ?to - region)
        :precondition (and 
            (entity_in ?agent ?from)
            (not (agent_is_near_something))
        )
        :effect (and 
            (entity_in ?agent ?to)
            (not (entity_in ?agent ?from))
        )
    )


    ; ACTION: Move from entity to region
    ; DESCRIPTION: Agent moves away from an entity to a new region
    ; PRECONDITIONS:
    ;   - Agent is currently near the entity
    ;   - Agent and entity are in same source region
    ;   - Robot drawer is closed
    ; EFFECTS:
    ;   - Agent is no longer near entity
    ;   - Agent no longer near anything flag is cleared
    ;   - Agent moves to target region
    (:action move_from_ent_to  ; NL: [0] moves from [1] to [3]
        :parameters (?agent - robot ?from - entity ?in - region ?to - region)
        :precondition (and 
            (entity_in ?agent ?in)
            (entity_in ?from ?in)
            (agent_near ?agent ?from)
            (agent_is_near_something)
        )
        :effect (and 
            (entity_in ?agent ?to)
            (not (entity_in ?agent ?in))
            (not (agent_near ?agent ?from))
            (not (agent_is_near_something))
        )
    )


    ; ========================================================================
    ; ACTION GROUP 2: APPROACH/PROXIMITY ACTIONS
    ; ========================================================================

    ; ACTION: Approach entity from across region
    ; DESCRIPTION: Agent approaches an entity, moving from elsewhere in region
    ; PRECONDITIONS:
    ;   - Target entity exists in region
    ;   - Agent is in same region
    ;   - Agent is not currently near anything
    ;   - Robot drawer is closed
    ; EFFECTS:
    ;   - Agent is now near the entity
    ;   - Agent is now near something
    (:action approach_from_region  ; NL: [0] moves to [1]
        :parameters (?agent - robot ?to - entity ?in - region)
        :precondition (and 
            (entity_in ?to ?in)
            (entity_in ?agent ?in)
            (not (agent_is_near_something))
        )
        :effect (and 
            (agent_near ?agent ?to)
            (agent_is_near_something)
        )
    )


    ; ACTION: Approach entity from another entity
    ; DESCRIPTION: Agent moves from being near one entity to being near another
    ; PRECONDITIONS:
    ;   - Agent is currently near 'from' entity
    ;   - Both entities in same region
    ;   - Agent is in same region
    ;   - Robot drawer is closed
    ; EFFECTS:
    ;   - Agent is no longer near 'from' entity
    ;   - Agent is now near 'to' entity
    (:action approach_from_entity  ; NL: [0] moves from [1] to [2]
        :parameters (?agent - robot ?from - entity ?to - entity ?in - region)
        :precondition (and 
            (entity_in ?to ?in)
            (entity_in ?agent ?in)
            (agent_near ?agent ?from)
            (agent_is_near_something)
        )
        :effect (and 
            (not (agent_near ?agent ?from))
            (agent_near ?agent ?to)
        )
    )


    ; ========================================================================
    ; ACTION GROUP 3: OBJECT PICKUP ACTIONS
    ; ========================================================================

    ; ACTION: Grab item from surface
    ; DESCRIPTION: Agent picks up an item from a surface
    ; PRECONDITIONS:
    ;   - Agent is near the item
    ;   - Agent can carry (not already holding something)
    ;   - Item is on the surface
    ;   - Item and agent in same region
    ; EFFECTS:
    ;   - Agent now holding the item
    ;   - Agent can no longer carry (hand full)
    ;   - Item no longer at surface location
    ;   - Agent is near surface (not the item)
    (:action grab   ; NL: [0] grabs [1]
        :parameters (?agent - robot ?item - item ?surface - surface ?region - region)
        :precondition (and 
            (agent_near ?agent ?item)
            (can_carry)
            (entity_in ?item ?region)
            (entity_in ?agent ?region)
            (entity_in ?surface ?region)
            (object_at ?item ?surface)
        )
        :effect (and 
            (agent_has ?agent ?item)
            (not (can_carry))
            (agent_near ?agent ?surface)
            (not (object_at ?item ?surface))
            (not (entity_in ?item ?region))
            (not (agent_near ?agent ?item))
        )
    )


    ; ACTION: Grab item from inside container
    ; DESCRIPTION: Agent picks up an item from inside a container
    ; PRECONDITIONS:
    ;   - Agent is near the item
    ;   - Agent can carry (not already holding something)
    ;   - Container is open
    ;   - Item is inside the container
    ;   - Item and agent in same region
    ; EFFECTS:
    ;   - Agent now holding the item
    ;   - Agent can no longer carry (hand full)
    ;   - Item is no longer in container
    ;   - Agent is near container (not the item)
    (:action grab_from_inside  ; NL: [0] grabs [1]
        :parameters (?agent - robot ?item - item ?container - container ?region - region)
        :precondition (and 
            (agent_near ?agent ?item)
            (can_carry)
            (entity_in ?item ?region)
            (entity_in ?agent ?region)
            (entity_in ?container ?region)
            (is_open ?container)
            (item_inside ?item ?container)
        )
        :effect (and 
            (agent_has ?agent ?item)
            (not (can_carry))
            (agent_near ?agent ?container)
            (not (item_inside ?item ?container))
            (not (entity_in ?item ?region))
            (not (agent_near ?agent ?item))
        )
    )


    ; ========================================================================
    ; ACTION GROUP 4: OBJECT PLACEMENT ACTIONS
    ; ========================================================================

    ; ACTION: Place item on surface
    ; DESCRIPTION: Agent puts down an item onto a surface
    ; PRECONDITIONS:
    ;   - Agent is near the surface
    ;   - Agent is holding the item
    ;   - Agent cannot carry (hand full)
    ;   - Item is not vacuum (vacuum cannot be placed)
    ;   - Surface is in same region
    ; EFFECTS:
    ;   - Agent is no longer holding the item
    ;   - Agent can carry again (hand free)
    ;   - Item is now on the surface
    ;   - Item is in the region
    ;   - Agent is near item (not surface)
    (:action put_on_surface  ; NL: [0] places [1] on [2]
        :parameters (?agent - robot ?item - item ?surface - surface ?region - region)
        :precondition (and 
            (agent_near ?agent ?surface)
            (not (object_at ?item ?surface))
            (not (can_carry))
            (agent_has ?agent ?item)
            (entity_in ?surface ?region)
        )
        :effect (and 
            (not (agent_has ?agent ?item))
            (can_carry)
            (not (agent_near ?agent ?surface))
            (agent_near ?agent ?item)
            (object_at ?item ?surface)
            (entity_in ?item ?region)
        )
    )

    (:action put_inside  ; NL: [0] places [1] inside [2]
        :parameters (?agent - robot ?item - item ?container - container ?region - region)
        :precondition (and 
            (agent_near ?agent ?container)
            (not (item_inside ?item ?container))
            (not (can_carry))
            (agent_has ?agent ?item)
            (entity_in ?container ?region)
            (is_open ?container)
        )
        :effect (and 
            (not (agent_has ?agent ?item))
            (can_carry)
            (not (agent_near ?agent ?container))
            (agent_near ?agent ?item)
            (item_inside ?item ?container)
            (entity_in ?item ?region)
        )
    )


    ; ========================================================================
    ; ACTION GROUP 5: CONTAINER MANAGEMENT ACTIONS
    ; ========================================================================

    ; ACTION: Open container
    ; DESCRIPTION: Agent opens a container, making items inside accessible
    ; PRECONDITIONS:
    ;   - Agent is near the container
    ;   - Agent can carry
    ;   - Container is currently closed
    ;   - Container is not the robot drawer
    ; EFFECTS:
    ;   - Container is now open
    ;   - Container is no longer closed
    (:action open   ; NL: [0] opens [1]
        :parameters (?agent - robot ?cont - container)
        :precondition (and 
            (agent_near ?agent ?cont)
            (can_carry)
            (is_closed ?cont)
        )
        :effect (and 
            (is_open ?cont)
            (not (is_closed ?cont))
        )
    )


    ; ACTION: Close container
    ; DESCRIPTION: Agent closes a container, making items inside inaccessible
    ; PRECONDITIONS:
    ;   - Agent is near the container
    ;   - Agent can carry
    ;   - Container is currently open
    ;   - Container is not the robot drawer
    ; EFFECTS:
    ;   - Container is now closed
    ;   - Container is no longer open
    (:action close   ; NL: [0] closes [1]
        :parameters (?agent - robot ?cont - container)
        :precondition (and 
            (can_carry)
            (is_open ?cont)
            (agent_near ?agent ?cont)
        )
        :effect (and 
            (not (is_open ?cont))
            (is_closed ?cont)
        )
    )


    ; ========================================================================
    ; ACTION GROUP 6: DELIVERY ACTIONS
    ; ========================================================================

    ; ACTION: Deliver item to person
    ; DESCRIPTION: Agent transfers the held item to a person
    ; PRECONDITIONS:
    ;   - Agent is holding the item
    ;   - Agent is near the person (recipient)
    ;   - Agent cannot carry (hand full/holding something)
    ;   - Robot drawer is closed
    ; EFFECTS:
    ;   - Person now has the item
    ;   - Agent no longer has the item
    ;   - Agent can carry again (hand free)
    (:action deliver  ; NL: [0] delivers [1] to [2]
        :parameters (?agent - robot ?item - item ?person - person)
        :precondition (and 
            (agent_has ?agent ?item)
            (agent_near ?agent ?person)
            (not (can_carry))
        )
        :effect (and 
            (agent_has ?person ?item)
            (not (agent_has ?agent ?item))
            (can_carry)
        )
    )
)