# Simple test with one goal.

import pddl.cost_function

labels

	one: [
		  predicate: item_at,
		  params: [bread, locationE]
		 ]


endlabels

cost

	move1: 2
	move2: 1
	grab1: 2
	grab2: 1
	put1: 2
	put2: 1
	
endcost

module

	st: [0: init, 1: one];

	[] 0 -> 1;

endmodule
