# Simple test with a loop.

import pddl.general

labels

	go: [
		  predicate: entity_in,
		  params: [stretch, kitchen]
		 ]


endlabels

module

	st: [0: init, 1: go];

	[] 0 -> 1;
	[] 1 -> 1;

endmodule

options

	conditional_effects;

endoptions