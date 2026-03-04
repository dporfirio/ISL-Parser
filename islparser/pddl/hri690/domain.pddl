; =======================================================
; GENERAL
;
; This pddl domain is intended to provide constants,
; predicates, and actions that generalize to most
; possible human-robot interactions in a mobile setting.
;
; This domain is purely intended for mobile (i.e.,
; service) interactions, as opposed to manufacturing
; or industry.
;
; The main assumption is that any human or robot in
; the domain are "mobile", i.e., able to travel to
; different geographic locations (called regions) and
; entities in the world.
;
; =======================================================

(define (domain hri)

    (:requirements
        ; General requirements - DO NOT MODIFY
        ; THE FOLLOWING LINE!
        :negative-preconditions :typing
    )

    (:types
        ; ==============================
        ; ASSIGNMENT: Add types here.
        ;  |    Note: all custom types
        ;  |    MUST have a parent in
        ;  |    the type tree that
        ;  |    inherits from 'object'.
        ;  |
        ;  v
        location item - object
        storage surface - location
    )

    (:predicates
        ; Predicates are specified as follows:
        ; (<symbol> [<arg1> <arg2> ...]) ; <comment>
        ;
        ; <symbol> is the predicate symbol, i.e., its "name"
        ; <argn> is a predicate argument. There can be 0 or more arguments.
        ; <comment> is a REQUIRED comment. Comments may take the following form:
        ;
        ;   INTERNAL - indicates that the predicate is only used internally,
        ;              i.e., will not be exposed to any end user.
        ;   NL: <string> - provides a natural-language form of the predicate.
        ;                  <string> can take arguments, which are placed in
        ;                  brackets. Numbers inside of the brackets indicate
        ;                  the index of the predicate arg to be inserted into
        ;                  the natural language statement.
        ;
        ; Only one predicate should exist per line!

        ; ==============================
        ; ASSIGNMENT: Use the predicates below.
        ; You WILL need additional predicates.
        ;  |
        ;  v
        ; first, where things are
        (robot_at ?l - location)
        (person_at ?l - location)
        (item_at ?i - item ?l - location)

        ; then, who has what
        (robot_has ?i - item)
        (person_has ?i - item)

        ; what is connected to what?
        (connected ?l1 - location ?l2 - location)

        ; whether a storage location is open or closed
        (is_open ?s - storage)

        ; tmp
        (tmp)
    )

    ; ==============================
    ; ACTIONS
    ; ==============================
    ;
    ; Actions are specified as follows:
    ;
    ; (:action <name> 
    ;    :parameters (<formula>)
    ;    :precondition (<formula>)
    ;    :effect (<formula>)
    ; )
    ;
    ; <name> is the name of the operator
    ; <formula> is a boolean formula specified in predicate logic

    ; ==============================
    ; ASSIGNMENT: Fill in the actions here!
    ; Note that you shouldn't need any more
    ; actions than the ones specified below.
    ;  |
    ;  v
    (:action move_from_to
        :parameters (?from - location ?to - location)
        :precondition () ; FILL IN
        :effect (tmp) ; DELETE tmp AND FILL IN
    )

    (:action pickup_item_from
        :parameters (?item - item ?location - location)
        :precondition () ; FILL IN
        :effect (tmp) ; DELETE tmp AND FILL IN
    )

    (:action drop_item_on
        :parameters (?item - item ?surface - surface)
        :precondition () ; FILL IN
        :effect (tmp) ; DELETE tmp AND FILL IN
    )

    (:action store_item_in
        :parameters (?item - item ?storage - storage)
        :precondition () ; FILL IN
        :effect (tmp) ; DELETE tmp AND FILL IN
    )

    (:action give_item_to_person_at
        :parameters (?item - item ?location - location)
        :precondition () ; FILL IN
        :effect (tmp) ; DELETE tmp AND FILL IN
    )

    (:action open_storage
        :parameters (?storage - storage)
        :precondition () ; FILL IN
        :effect (tmp) ; DELETE tmp AND FILL IN
    )
)