(define (problem cost)
	(:domain cost)

    ; ==============================
    ; ASSIGNMENT: Initialize objects here
    ;  |
    ;  v
	(:objects locationA locationB locationC locationD locationE - location
              bread ham cheese peanutbutter jelly - item)
    
    ; ==============================
    ; ASSIGNMENT: Initialize predicates here
    ;  |
    ;  v
	(:init (robot_at locationA)
		   (item_at bread locationC)
           (item_at ham locationD)
           (item_at cheese locationB)
           (item_at peanutbutter locationD)
           (item_at jelly locationB)
           (gripper_is_free))
    
	(:goal (robot_at locationE))
)
