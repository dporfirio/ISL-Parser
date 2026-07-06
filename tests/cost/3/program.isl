# Simple test with one goal.

import pddl.stretch_demo

labels

	one: [
		  predicate: item_at,
		  params: [bread, locatione]
		 ]


endlabels

cost
	move1: 1
	move2: 2
	grab1: 2
	grab2: 1
	put1: 2
	put2: 1
endcost

module

	st: [0: init, 1: one];

	[] 0 -> 1;

endmodule