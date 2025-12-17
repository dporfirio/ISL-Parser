# Healthcare test
import pddl.healthcare_goals

labels
	
    one: [
        predicate: is_moving,
		  params: []
          &
          predicate: entity_in,
		  params: [stretch, pharmacy]
    ],
	two: [
		predicate: is_approaching,
		params: []
		&
		predicate: agent_near,
		params: [stretch, medicinecabinet]
	],
	three:
	[
		predicate: is_opening,
		  params: []
          &
          predicate: is_open,
		  params: [medicinecabinet]
	],
	four: [
		predicate: is_grabbing,
		  params: []
          &
          predicate: agent_has,
		  params: [stretch, bandages1]
	],
	five: [
		predicate: is_putting,
		params:[]
		&
		 predicate: item_inside,
		  params: [bandages1, robotdrawer]
	],
	six: [
		predicate: is_closing,
		  params: []
		  &
		  predicate: is_closed,
		  params:[medicinecabinet] 

	],
	seven: [
		predicate: is_closing,
		  params: []
		  &
		  predicate: is_closed,
		  params:[robotdrawer] 
	],
	
	eight: [
		predicate: is_delivering,
		  params: []
          &
          predicate: agent_has,
		  params: [icudoctor, bandages1]
	]

	
endlabels

module

	st: [0: init, 1: one, 2: two, 3: three,4: four, 5: five, 6: six, 7: seven, 8: eight];

	[] 0 -> 1;
    [] 1 -> 2;
	[] 2 -> 3;
	[] 3 -> 4;
	[] 4 -> 5;
	[] 5 -> 6;
	[] 6 -> 7;
	[] 7 -> 8;

endmodule