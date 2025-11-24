# Healthcare test
import pddl.healthcare_goals

labels

	one: [
		  predicate: is_grabbing,
		  params: []
          &
          predicate: agent_has,
		  params: [stretch, bloodsample]
    ],
    two: [
          predicate: is_moving,
		  params: []
          &
          predicate: entity_in,
		  params: [stretch, lab]
	]

endlabels

module

	st: [0: init, 1: one, 2: two];

	[] 0 -> 1;
    [] 1 -> 2;

endmodule