# Simple test with one goal and conditional.
import pddl.general
labels

	go: [
		  predicate: entity_in,
		  params: [stretch, kitchen]
		 ]


endlabels

module

	st: [0: init, 1: go];
	guard: [0: go];

	[] 0 & guard=0 -> 1;

endmodule

options

	conditional_effects;

endoptions