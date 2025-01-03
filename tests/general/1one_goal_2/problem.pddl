(define (problem general)
	(:domain general)
	(:objects kitchen home - region
		      countertop - surface
		      sauron - robot)
	(:init (entity_in sauron home)
		   (entity_in countertop kitchen)
		   (accessible countertop))
	(:goal (entity_in sauron kitchen)))