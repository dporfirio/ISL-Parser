(define (problem delegation_weight_simple)
    (:domain delegation_weight)

    (:objects
        level1 lowlevel - region

        officedesk frontdesk robotic_lab stair_mid stair_level1 stair_lowlevel lowlevel_office - surface

        package1 package2 - item

        could_you_please_deliver_package_1_and_package_2_to_recipient_in_robotic_lab - message

        requestor recipient professor - requester
        staff - staff_member
        temi - robot
    )

    (:init
        (entity_in temi level1)
        (entity_in requestor level1)
        (entity_in recipient level1)
        (entity_in staff level1)
        (entity_in officedesk level1)
        (entity_in frontdesk level1)
        (entity_in robotic_lab level1)
        (entity_in stair_mid level1)
        (entity_in stair_level1 level1)
        (entity_in stair_lowlevel lowlevel)
        (entity_in lowlevel_office lowlevel)
        (entity_in professor lowlevel)
        (entity_in package1 level1)
        (entity_in package2 level1)

        (agent_near temi officedesk)
        (agent_is_near_something temi)
        (agent_near requestor officedesk)
        (agent_is_near_something requestor)
        (agent_near recipient robotic_lab)
        (agent_is_near_something recipient)
        (agent_near staff frontdesk)
        (agent_is_near_something staff)
        (object_at package1 frontdesk)
        (object_at package2 frontdesk)

        (requested_item could_you_please_deliver_package_1_and_package_2_to_recipient_in_robotic_lab package1)
        (requested_item could_you_please_deliver_package_1_and_package_2_to_recipient_in_robotic_lab package2)

        (can_move temi)
        (can_move staff)
        (robot_basket_empty temi)
        (region_connected level1 level1)
        (region_connected lowlevel lowlevel)
        (region_connected level1 lowlevel)
        (region_connected lowlevel level1)
    )

    (:goal
        (and
            (agent_has recipient package1)
            (agent_has recipient package2)
        )
    )
)
