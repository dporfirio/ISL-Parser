(define (problem hri)
	(:domain hri)

    ; ==============================
    ; NOTE: You don't need to modify
    ; the objects.
	(:objects living_room passage entry - location
		      entry_closet stove refrigerator - storage
              entry_table dining_table coffee_table end_table - surface
              water groceries - item)
    
	(:init
		   (person_at refrigerator)
           (connected living_room coffee_table)
           (connected living_room end_table)
           (connected living_room passage)
           (connected passage dining_table)
           (connected dining_table refrigerator)
           (connected dining_table stove)
           (connected dining_table entry)
           (connected entry entry_table)
           (connected entry entry_closet)

           ; ==============================
           ; ASSIGNMENT: Initialize predicates here
           ;  |
           ;  v
           )
    
    ; ==============================
    ; NOTE: the test code will automatically
    ; replace the goal, so it's not important
    ; what you put here unless you want to
    ; test outside of the ISL.
	(:goal (robot_at refrigerator)))