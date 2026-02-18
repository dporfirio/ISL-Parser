(define (problem gmu_fuse)
	(:domain gmu_fuse)
	(:objects 
		; Regions
		kitchen - region
		
		; Surfaces
		table countertop - surface

		; Containers
		pantry refrigerator - container

		; Items
		towels yogurt - item
		
		; Robot
		stretch - robot

		; Person
		david - person
	)
	
	(:init 
		; Robot initial state
		(entity_in stretch kitchen)
		; (agent_has_drawer stretch robotdrawer)
		(can_carry)

		;person initial state
		(entity_in david kitchen)

		; Surfaces and containers in regions
		(entity_in table kitchen)
		(entity_in countertop kitchen)
		(entity_in pantry kitchen)
		(entity_in refrigerator kitchen)

		; Items in regions (for items on surfaces or in containers)
		(entity_in towels kitchen)
		(entity_in yogurt kitchen)
	
		; Items on surfaces
		(object_at towels table)
		(object_at yogurt countertop)

		; Items inside containers

		; person has item

		; Container states
		(is_closed refrigerator)
		(is_closed pantry)
	)
	(:goal (entity_in stretch kitchen)))