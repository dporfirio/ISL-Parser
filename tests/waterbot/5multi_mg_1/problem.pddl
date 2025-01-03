(define (problem general)
	(:domain general)
	(:objects galley cabin charging - region
		      kitchenette - surface
		      cup - item
		      passenger - person
		      sauron - robot
        	  gripper - end_effector)
	(:init (entity_in sauron charging)
		   (entity_in passenger cabin)
		   (entity_in cup galley)
		   (object_at cup kitchenette)
		   (accessible passenger)
		   (accessible cup)
		   (accessible kitchenette)
		   (is_grabbable cup)
		   (is_full cup)
           (is_free gripper)
           (owns_gripper sauron gripper))
	(:goal (agent_has passenger cup)))