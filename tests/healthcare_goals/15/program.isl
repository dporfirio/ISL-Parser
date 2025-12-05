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
          predicate: person_has,
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
		  params: [stretch, insulin, pharmacist]
	],
	six: [
		  predicate: is_receiving,
		  params: []
          &
          predicate: agent_has,
		  params: [stretch, insulin]
	],
    seven: [
          predicate: is_putting,
		  params: []
          &
          predicate: object_at,
		  params: [amoxicillin, icutray]
	]
    

endlabels

module

	st: [0: init, 1: one, 2: two, 3: three, 4: four, 5: five, 6: six, 7: seven];

	[] 0 -> 1;
    [] 1 -> 2;
	[] 2 -> 3;
    [] 3 -> 4;
    [] 4 -> 5; 
    [] 5 -> 6;
    [] 6 -> 7;

endmodule
