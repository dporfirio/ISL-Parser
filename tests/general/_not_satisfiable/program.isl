# Simple test with an unsatisfiable goal.

import pddl.general

labels

	go: [
		  predicate: entity_in,
		  params: [stretch, kitchen]
		  &
		  predicate: entity_in,
		  params: [stretch, home]
		 ]


endlabels

module

	st: [0: init, 1: go];

	[] 0 -> 1;

endmodule

options

	conditional_effects;

endoptions