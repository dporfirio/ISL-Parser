# Healthcare test
import pddl.healthcare_goals

labels

	one: [
		predicate: is_moving,
		  params: []
          &
          predicate: entity_in,
		  params: [stretch, storage]
    ],
    two: [
          predicate: is_grabbing,
		  params: []
          &
          predicate: agent_has,
		  params: [stretch, wiper]
	],
	three: [
		  predicate: is_wiping,
		  params: []
          &
          predicate: is_clean,
		  params: [kitchencountertop]
	]


endlabels

module

	st: [0: init, 1: one, 2: two, 3: three];

	[] 0 -> 1;
    [] 1 -> 2;
	[] 2 -> 3;

endmodule