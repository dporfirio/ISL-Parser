(define (problem healthcare)
	(:domain healthcare)
	(:objects 
		; Regions
		icu lab nursestation emergencyroom cafeteria birthcenter pharmacy inpatient storage - region
		
		; Surfaces
		icutray bed labbench emtray kitchencountertop - surface

		; Containers
		medicinecabinet storagecabinet trashbin - container

		; Items
		linen amoxicillin bandages insulin ibuprofen antacid meal - consumableitem
		bloodsample xrayfile - uniqueitem 

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
		(entity_in vacuum storage)
		(entity_in wiper storage)
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

		;Cleanning tool inside container
		(item_inside vacuum storagecabinet)
		(item_inside wiper storagecabinet)

		; Mark which items are tools ← SET IT HERE!
        (is_tool vacuum)
        (is_tool wiper)

		; person has item
		(agent_has nurse xrayfile)

		(agent_has pharmacist insulin)

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
		(is_openable medicinecabinet)
		(is_openable storagecabinet)
		(is_openable trashbin)
	)
	(:goal (entity_in stretch lab)))