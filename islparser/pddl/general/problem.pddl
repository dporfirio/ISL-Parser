(define (problem general)
	(:domain general)
	(:objects kitchen home - region
		      countertop - surface
			  david - person
		      stretch - robot)
	(:init (entity_in stretch home)
		   (entity_in countertop kitchen)
		   (accessible david)
		   (accessible countertop))
	(:goal (entity_in stretch kitchen)))