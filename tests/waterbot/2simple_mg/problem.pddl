(define (problem general)
	(:domain general)
	(:objects galley cabin charging - region
		      cup - item
		      passenger - person
		      sauron - robot
        	  gripper - end_effector)
	(:init (entity_in sauron charging)
		   (entity_in passenger cabin)
		   (agent_has sauron cup)
		   (accessible passenger)
           (is_free gripper)
           (owns_gripper sauron gripper))
	(:goal (agent_has passenger cup)))