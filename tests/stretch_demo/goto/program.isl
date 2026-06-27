# Simple test with one goal.

import pddl.stretch_demo

labels

	first: [
		  predicate: robot_at,
		  params: [locationb]
	]


endlabels

module

	st: [0: init, 1: first];

	[] 0 -> 1;

endmodule