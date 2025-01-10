# Simple test with one goal.
import pddl.general
labels

	go: [
		  predicate: agent_near,
		  params: [stretch, countertop]
		 ]


endlabels

module

	st: [0: init, 1: go];

	[] 0 -> 1;

endmodule

options

	conditional_effects;

endoptions