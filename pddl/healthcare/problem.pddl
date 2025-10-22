(define (problem healthcare)
	(:domain healthcare)
	(:objects icu lab nursestation emergencyroom cafeteria birthingcenter pharmacy inpatient storage - region
		      icutray bed labbench - surface
              linen bloodsample medication locker - item
		      stretch - robot)
	(:init (entity_in stretch nursestation)

           (can_carry stretch)

		   (entity_in icutray icu)
           (entity_in bed icu)
           (entity_in labbench lab)
           (entity_in locker storage)

           (entity_in linen icu)
           (entity_in bloodsample icu)
           (entity_in medication icu)

           (object_at linen bed)
           (object_at bloodsample icutray)
           (object_at medication icutray)

		   (accessible linen)
           (accessible bloodsample)
           (accessible medication)
		   (accessible icutray)
           (accessible bed)
           (accessible labbench)
           
           (is_grabbable bloodsample)
           (is_grabbable medication)
           (is_grabbable linen)
           (is_openable locker))
	(:goal (entity_in stretch lab)))