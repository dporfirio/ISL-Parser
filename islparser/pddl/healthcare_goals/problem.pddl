(define (problem healthcare)
	(:domain healthcare)
	(:objects 
		; Regions
		icu lab nursestation emergencyroom cafeteria birthcenter pharmacy inpatient storage robotdock - region
		
		; Surfaces
		icutray bed labbench emtray kitchencountertop - surface

		; Containers
		medicinecabinet storagecabinet trashbin - container

		; Items
		linen1 linen2 linen3 amoxicillin1 amoxicillin2 amoxicillin3 bandages1 bandages2 bandages3 insulin1 insulin2 insulin3 ibuprofen1 ibuprofen2 ibuprofen3 antacid1 antacid2 antacid3 meal1 meal2 meal3 bloodsample xrayfile - item

		; Cleaning tools
		vacuum - vacuum_tool 
		wiper - wiper_tool
		
		; Robot
		stretch - robot

		; Person
		icudoctor icupatient nurse patient pharmacist emdoctor labtech  - person
	)
	
	(:init 
		; Robot initial state
		(entity_in stretch robotdock)
		(agent_has_drawer stretch robotdrawer)
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
		(entity_in xrayfile nursestation)
		(entity_in meal1 cafeteria)
		(entity_in meal2 cafeteria)
		(entity_in meal3 cafeteria)
		(entity_in linen1 storage)
		(entity_in linen2 storage)
		(entity_in linen3 storage)
	
		(entity_in amoxicillin1 pharmacy)
		(entity_in amoxicillin2 pharmacy)
		(entity_in amoxicillin3 pharmacy)
		(entity_in ibuprofen1 pharmacy)
		(entity_in ibuprofen2 pharmacy)
		(entity_in ibuprofen3 pharmacy)
		(entity_in bandages1 pharmacy)
		(entity_in bandages2 pharmacy)
		(entity_in bandages3 pharmacy)
		(entity_in antacid1 pharmacy)
		(entity_in antacid2 pharmacy)
		(entity_in antacid3 pharmacy)

		(entity_in insulin1 pharmacy)
		(entity_in insulin2 pharmacy)
		(entity_in insulin3 pharmacy)

		(entity_in vacuum storage)
		(entity_in wiper storage)
	
		; Items on surfaces
		(object_at bloodsample emtray)
		(object_at meal1 kitchencountertop)
		(object_at meal2 kitchencountertop)
		(object_at meal3 kitchencountertop)

		; Items inside containers
		(item_inside linen1 storagecabinet)
		(item_inside linen2 storagecabinet)
		(item_inside linen3 storagecabinet)
		(item_inside amoxicillin1 medicinecabinet)
		(item_inside amoxicillin2 medicinecabinet)
		(item_inside amoxicillin3 medicinecabinet)
		(item_inside ibuprofen1 medicinecabinet)
		(item_inside ibuprofen2 medicinecabinet)
		(item_inside ibuprofen3 medicinecabinet)
		(item_inside bandages1 medicinecabinet)
		(item_inside bandages2 medicinecabinet)
		(item_inside bandages3 medicinecabinet)
		(item_inside antacid1 medicinecabinet)
		(item_inside antacid2 medicinecabinet)
		(item_inside antacid3 medicinecabinet)
		;Cleanning tool inside container
		(item_inside vacuum storagecabinet)
		(item_inside wiper storagecabinet)

		; Mark which items are tools ← SET IT HERE!
        (is_tool vacuum)
        (is_tool wiper)

		; person has item
		(agent_has nurse xrayfile)

		(agent_has pharmacist insulin1)
		(agent_has pharmacist insulin2)
		(agent_has pharmacist insulin3)

		(not (is_clean lab))
		(not (is_clean icu))
		(not (is_clean inpatient))
		(not (is_clean emergencyroom))
		(not (is_clean nursestation))
		(not (is_clean birthcenter))
		(not (is_clean pharmacy))
		(not (is_clean cafeteria))
		(not (is_clean storage))


		; surfaces are not clean
		(not(is_clean icutray))
		(not(is_clean bed))
		(not(is_clean labbench))
		(not(is_clean emtray))
		(not(is_clean kitchencountertop))

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

		; Container states
		(not (is_open medicinecabinet))
		(not (is_open storagecabinet))
		(not (is_open trashbin))
		(not (is_open robotdrawer))
		(not (agent_near stretch robotdrawer))
		(is_openable medicinecabinet)
		(is_openable storagecabinet)
		(is_openable trashbin)
		(is_openable robotdrawer)
	)
	(:goal (entity_in stretch lab)))