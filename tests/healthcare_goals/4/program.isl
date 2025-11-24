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
        predicate: is_putting,
		  params: []
          &
          predicate: object_at,
		  params: [bloodsample, labbench]
    ],
    four: [
		  predicate: is_moving,
		  params: []
          &
          predicate: entity_in,
		  params: [stretch, pharmacy]
    ],
    five: [
          predicate: is_grabbing,
		  params: []
          &
          predicate: agent_has,
		  params: [stretch, ibuprofen]
	],
    six: [
        predicate: is_putting,
		  params: []
          &
          predicate: object_at,
		  params: [ibuprofen, icutray]
    ]

endlabels

module

	st: [0: init, 1: one, 2: two, 3: three, 4: four, 5: five, 6: six];

	[] 0 -> 1;
    [] 1 -> 2;
    [] 2 -> 3;
    [] 3 -> 4;
    [] 4 -> 5;
    [] 5 -> 6;

endmodule