# Simple test with a nonexecutable automaton.

import pddl.general

labels

	go: [
		  predicate: entity_in,
		  params: [stretch, kitchen]
		 ]


endlabels

module

	st: [0: init, 1: go];

endmodule

options

endoptions