(define (domain hri_kitchen)
  (:requirements :strips :typing :negative-preconditions)

  (:types
    entity - object
    agent inanimate - entity
    robot - agent
    item surface container button - inanimate
    carrier_item dish_item - item
  )

  (:constants
    robot_start kitchen_countertop dish_rack - surface
    sink dishwasher - container
    wash_heated_dry wash_manual_dry - button
  )

  (:predicates
    (agent_near ?agent - robot ?target - entity)
    (can_carry ?agent - robot)
    (agent_has ?agent - robot ?item - item)
    (object_at ?item - item ?surface - surface)
    (item_on_item ?item - item ?carrier - carrier_item)
    (item_inside ?item - item ?container - container)
    (is_open ?container - container)
    (is_closed ?container - container)
    (is_empty ?container - container)
    (button_pressed ?button - button)
    (waited_one_hour)
    (is_clean ?item - item)
  )

  (:action approach_from_entity ; NL: [0] approaches [2]
    :parameters (?agent - robot ?from - entity ?target - entity)
    :precondition (agent_near ?agent ?from)
    :effect (and
      (not (agent_near ?agent ?from))
      (agent_near ?agent ?target)
    )
  )

  (:action grab ; NL: [0] grabs [1]
    :parameters (?agent - robot ?item - item ?surface - surface)
    :precondition (and
      (agent_near ?agent ?surface)
      (can_carry ?agent)
      (object_at ?item ?surface)
    )
    :effect (and
      (agent_has ?agent ?item)
      (not (can_carry ?agent))
      (not (object_at ?item ?surface))
    )
  )

  (:action grab_from_item ; NL: [0] grabs [1] from [2]
    :parameters (?agent - robot ?item - item ?carrier - carrier_item)
    :precondition (and
      (agent_near ?agent ?carrier)
      (can_carry ?agent)
      (item_on_item ?item ?carrier)
    )
    :effect (and
      (agent_has ?agent ?item)
      (not (can_carry ?agent))
      (not (item_on_item ?item ?carrier))
    )
  )

  (:action put_on_item ; NL: [0] puts [1] on [2]
    :parameters (?agent - robot ?item - item ?carrier - carrier_item)
    :precondition (agent_has ?agent ?item)
    :effect (and
      (item_on_item ?item ?carrier)
      (can_carry ?agent)
      (not (agent_has ?agent ?item))
    )
  )

  (:action put_on_surface ; NL: [0] puts [1] on [2]
    :parameters (?agent - robot ?item - item ?surface - surface)
    :precondition (and
      (agent_near ?agent ?surface)
      (agent_has ?agent ?item)
    )
    :effect (and
      (object_at ?item ?surface)
      (can_carry ?agent)
      (not (agent_has ?agent ?item))
    )
  )

  (:action put_inside ; NL: [0] puts [1] inside [2]
    :parameters (?agent - robot ?item - item ?container - container)
    :precondition (and
      (agent_near ?agent ?container)
      (agent_has ?agent ?item)
      (is_open ?container)
      (not (button_pressed wash_heated_dry))
      (not (button_pressed wash_manual_dry))
    )
    :effect (and
      (item_inside ?item ?container)
      (not (is_empty ?container))
      (can_carry ?agent)
      (not (agent_has ?agent ?item))
    )
  )

  (:action open ; NL: [0] opens [1]
    :parameters (?agent - robot ?container - container)
    :precondition (and
      (agent_near ?agent ?container)
      (is_closed ?container)
      (not (button_pressed wash_manual_dry))
    )
    :effect (and
      (is_open ?container)
      (not (is_closed ?container))
    )
  )

  (:action close ; NL: [0] closes [1]
    :parameters (?agent - robot ?container - container)
    :precondition (and
      (agent_near ?agent ?container)
      (is_open ?container)
      (not (is_empty ?container))
    )
    :effect (and
      (is_closed ?container)
      (not (is_open ?container))
    )
  )

  (:action press_heated_dry ; NL: [0] presses the heated-dry button
    :parameters (?agent - robot)
    :precondition (and
      (agent_near ?agent dishwasher)
      (is_closed dishwasher)
      (not (is_empty dishwasher))
    )
    :effect (button_pressed wash_heated_dry)
  )

  (:action heated_clean ; NL: [0] heated clean
    :parameters (?item - item)
    :precondition (and
      (button_pressed wash_heated_dry)
      (item_inside ?item dishwasher)
    )
    :effect (is_clean ?item)
  )

  (:action press_manual_dry ; NL: [0] presses the manual-dry button
    :parameters (?agent - robot)
    :precondition (and
      (agent_near ?agent dishwasher)
      (is_closed dishwasher)
      (not (is_empty dishwasher))
    )
    :effect (button_pressed wash_manual_dry)
  )

  (:action wait_dishwasher ; NL: the dishwasher waits for one hour
    :parameters ()
    :precondition (and
      (button_pressed wash_manual_dry)
      (is_closed dishwasher)
    )
    :effect (waited_one_hour)
  )

  (:action open_after_wait ; NL: [0] opens the dishwasher after waiting
    :parameters (?agent - robot)
    :precondition (and
      (agent_near ?agent dishwasher)
      (is_closed dishwasher)
      (waited_one_hour)
    )
    :effect (and
      (is_open dishwasher)
      (not (is_closed dishwasher))
    )
  )

  (:action unload_to_rack ; NL: [0] unloads [1] to the dish rack
    :parameters (?agent - robot ?item - item)
    :precondition (and
      (agent_near ?agent dishwasher)
      (is_open dishwasher)
      (waited_one_hour)
      (item_inside ?item dishwasher)
    )
    :effect (and
      (object_at ?item dish_rack)
      (is_clean ?item)
      (not (item_inside ?item dishwasher))
    )
  )

  (:action wait_human_wash ; NL: a human washes [0]
    :parameters (?item - item)
    :precondition (and
      (item_inside ?item sink)
    )
    :effect (is_clean ?item)
  )
)
