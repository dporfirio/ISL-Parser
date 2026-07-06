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
        ; ASSIGNMENT: Add custom predicates here
        ;  |
        ;  v
        ; first, where things are
        (robot_at ?l - location)
        (item_at ?i - item ?l - location)

        ; then, who has what
        (robot_has ?i - item)

        ; whether or not the robot is holding something
        (gripper_is_free)
    )

    ; ==============================
    ; ACTIONS
    ; ==============================
    ;
    ; Actions are specified as follows:
    ;
    ; (:action <name>            ; <comment>
    ;    :parameters (<formula>)
    ;    :precondition (<formula>)
    ;    :effect (<formula>)
    ; )
    ;
    ; <name> is the name of the operator
    ; <comment> is a comment specified similarly to predicates
    ; <formula> is a boolean formula specified in predicate logic

    ; ==============================
    ; ASSIGNMENT: Add custom actions here
    ;  |
    ;  v
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