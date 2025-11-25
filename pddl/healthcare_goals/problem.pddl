(define (problem healthcare)
	(:domain healthcare)
	(:objects 
		; Regions
		icu lab nursestation emergencyroom cafeteria birthingcenter pharmacy inpatient storage - region
		
		; Surfaces
		icutray bed labbench emtray kitchencountertop - surface
		
		; Containers
		medicinecabinet storagecabinet trashbin - container

		; Items
		mop vacume linen bloodsample amoxicillin bandages insulin ibuprofen antacid meal xrayfile - item
		
		; Robot
		stretch - robot

		; Person
		icudoctor icupatient nurse patient pharmacist emdoctor labtech  - person
	)
	
	(:init 
		; Robot initial state
		(entity_in stretch nursestation)
		(can_carry stretch)

		;person initial state
		(entity_in icudoctor icu)
		(entity_in icupatient icu)
		(entity_in nurse nursestation)
		(entity_in patient inpatient)
		(entity_in pharmacist pharmacy)
		(entity_in labtech lab)
		(entity_in emdoctor emergencyroom)

		; Surfaces and containers in regions
		(entity_in icutray icu)
		(entity_in bed icu)
		(entity_in labbench lab)
		(entity_in emtray emergencyroom)
		(entity_in medicinecabinet pharmacy)
		(entity_in storagecabinet storage)
		(entity_in kitchencountertop cafeteria)

		; Items in regions (for items on surfaces or in containers)
		(entity_in bloodsample emergencyroom)
		(entity_in meal cafeteria)
		(entity_in xrayfile nursestation)
		(entity_in linen storage)
		(entity_in amoxicillin pharmacy)
		(entity_in ibuprofen pharmacy)
		(entity_in bandages pharmacy)
		(entity_in antacid pharmacy)
		(entity_in insulin pharmacy)

		; Items on surfaces
		(object_at bloodsample emtray)
		(object_at meal kitchencountertop)

		; Items inside containers
		(item_inside linen storagecabinet)
		(item_inside amoxicillin medicinecabinet)
		(item_inside ibuprofen medicinecabinet)
		(item_inside bandages medicinecabinet)
		(item_inside antacid medicinecabinet)

		; person has item
		(agent_has nurse xrayfile)

		(has_supply pharmacist insulin)

		; person accessibility by robot
		; (accessible icudoctor)
		; (accessible icupatient)
		; (accessible nurse)
		; (accessible patient)
		; (accessible pharmacist)
		; (accessible labtech)
		

		; Accessibility of items
		; (accessible bloodsample)
		; (accessible meal)
		; (accessible xrayfile)
		; (not (accessible linen))
		; (not (accessible amoxicillin))
		; (not (accessible ibuprofen))
		; (not (accessible bandages))
		; (not (accessible insulin))
		; (not (accessible antacid))

		; Accessibility of surfaces and containers
		; (accessible icutray)
		; (accessible bed)
		; (accessible labbench)
		; (accessible emtray)
		; (accessible medicinecabinet)
		; (accessible storagecabinet)
		; (accessible kitchencountertop)

		; Container states
		(not (is_open medicinecabinet))
		(not (is_open storagecabinet))
		(not (is_open trashbin))
		(is_openable medicinecabinet)
		(is_openable storagecabinet)
		(is_openable trashbin)
	)
	(:goal (entity_in stretch lab)))