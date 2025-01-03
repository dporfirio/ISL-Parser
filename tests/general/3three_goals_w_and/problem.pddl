(define (problem general)
	(:domain general)
	(:objects kitchen dining home - region
		      countertop - surface
		      david - person
		      sauron - robot)
	(:init (entity_in sauron home)
		   (entity_in countertop dining)
		   (accessible david))
	(:goal (entity_in sauron kitchen)))