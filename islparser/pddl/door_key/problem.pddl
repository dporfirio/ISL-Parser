(define (problem stretch_demo)
	(:domain stretch_demo)

    ; ==============================
    ; ASSIGNMENT: Initialize objects here
    ;  |
    ;  v
	(:objects b1 b2 b3 b4 b5 b6 l1 l2 l3 l4 l5 l6 l7 r1 r2 r3 r4 r5 r6 r7 t1 t2 t3 t4 t5 t6 - location
              cube bin - item)
    
    ; ==============================
    ; ASSIGNMENT: Initialize predicates here
    ;  |
    ;  v
	(:init (robot_at b5)
		   (item_at bread locationC)
           (item_at ham locationD)
           (item_at cheese locationB)
           (item_at peanutbutter locationD)
           (item_at jelly locationB)
           (gripper_is_free))
    
	(:goal (robot_at locationE)))