(define (problem delegation_weight_simple)
    (:domain delegation_weight)

    (:objects
        level1 - region

        office_desk mail_counter - surface

        package_item1 package_item2 - item

        fetch_packages_msg - message

        requester1 - requester
        mailroom_staff1 - staff
        temi - robot
    )

    (:init
        (entity_in temi level1)
        (entity_in requester1 level1)
        (entity_in mailroom_staff1 level1)
        (entity_in office_desk level1)
        (entity_in mail_counter level1)
        (entity_in package_item1 level1)
        (entity_in package_item2 level1)

        (agent_near temi office_desk)
        (agent_is_near_something temi)
        (agent_near requester1 office_desk)
        (agent_is_near_something requester1)
        (agent_near mailroom_staff1 mail_counter)
        (agent_is_near_something mailroom_staff1)
        (object_at package_item1 mail_counter)
        (object_at package_item2 mail_counter)

        (requested_item fetch_packages_msg package_item1)
        (requested_item fetch_packages_msg package_item2)

        (can_move temi)
        (can_move mailroom_staff1)
        (robot_basket_empty temi)
        (region_connected level1 level1)
    )

    (:goal
        (and
            (agent_has requester1 package_item1)
            (agent_has requester1 package_item2)
        )
    )
)
