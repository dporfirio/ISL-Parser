(define (problem coffee_maker_station)
    (:domain coffee_maker)
    (:objects
        kitchen - region
        beans_st pot_st mug_st - surface
    )
    (:init
        (robot_at kitchen)
        (gripper_free)
        (item_on coffee_beans beans_st)
        (uses_filter)
        (contains coffee_maker filter)
        (item_on pot pot_st)
        (item_on mug mug_st)
    )
    (:goal (and (has_coffee mug)
                (has_cream mug)
                (has_sugar mug)
                (item_on mug person)))
)