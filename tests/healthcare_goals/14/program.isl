# Healthcare test
import pddl.healthcare_goals

labels

	one: [
		predicate: is_moving,
		  params: []
          &
          predicate: entity_in,
		  params: [stretch, emergencyroom]
    ],
    two: [
          predicate: is_grabbing,
		  params: []
          &
          predicate: agent_has,
		  params: [stretch, bloodsample]
	],
	three: [
		  predicate: is_delivering,
		  params: []
          &
		  predicate: agent_has,
		  params: [labtech, bloodsample]
	],
    four: [
		predicate: is_moving,
		  params: []
          &
          predicate: entity_in,
		  params: [stretch, pharmacy]
    ],
    five: [
          predicate: is_requesting,
		  params: []
          &
          predicate: requested,
		  params: [stretch, insulin1, pharmacist]
	],
	six: [
		  predicate: is_receiving,
		  params: []
          &
          predicate: agent_has,
		  params: [stretch, insulin1]
	],
    seven: [
		predicate: is_moving,
		  params: []
          &
          predicate: entity_in,
		  params: [stretch, icu]
    ],
    eight: [
          predicate: is_putting,
		  params: []
          &
          predicate: object_at,
		  params: [ibuprofen1, icutray]
	],
	nine: [
		  predicate: is_delivering,
		  params: []
          &
          predicate: agent_has,
		  params: [labtech, bloodsample]
	]
    
endlabels

module

	st: [0: init, 1: one, 2: two, 3: three, 4: four, 5: five, 6: six, 7: seven, 8: eight, 9: nine];

	[] 0 -> 1;
    [] 1 -> 2;
	[] 2 -> 3;
    [] 3 -> 4;
    [] 4 -> 5; 
    [] 5 -> 6;
    [] 6 -> 7;
    [] 7 -> 8;
    [] 8 -> 9;

endmodule
