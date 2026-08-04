(define (problem wash_kitchen_dishes)
  (:domain hri_kitchen)

  (:objects
    stretch - robot
    mug bowl - dish_item
    plate - carrier_item
    table - surface
  )

  (:init
    (agent_near stretch robot_start)
    (can_carry stretch)
    (object_at mug table)
    (object_at plate table)
    (item_inside bowl sink)
    (is_open sink)
    (is_closed dishwasher)
    (is_empty dishwasher)
  )

  (:goal
    (and
      (is_clean plate)
      (is_clean mug)
      (item_inside plate sink)
      (item_inside mug sink)
    )
  )
)
