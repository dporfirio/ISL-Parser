(define (problem general)
	(:domain general)
	(:objects kitchen home - region
		      david - person
		      sauron - robot)
	(:init (entity_in sauron home)
		   (accessible david))
	(:goal (entity_in sauron kitchen)))