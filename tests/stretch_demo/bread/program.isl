# Simple test with one goal.

import pddl.stretch_demo

labels

	one: [
		  predicate: item_at,
		  params: [bread, locatione]
		 ]


endlabels

module

	st: [0: init, 1: one];

	[] 0 -> 1;

endmodule