(define (problem coffee_maker_station)
    (:domain coffee_maker)
    (:objects
        kitchen - region
        beans_st pot_st mug_st - surface
    )
    (:init
        (robot_at kitchen)
        (gripper_free)
        (item_on beans beans_st)
        (item_on filter maker)
        (item_on pot pot_st)
        (item_on mug mug_st)
        (topping_at cream cream_st)
        (topping_at sugar sugar_st)

    )
    (:goal (and (has_coffee mug)
                (has_topping mug cream)
                (has_topping mug sugar)
                (item_on mug person)))
)
