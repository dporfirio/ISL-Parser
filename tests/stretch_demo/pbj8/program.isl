# Simple test with one goal.

import pddl.stretch_demo

labels

	one: [
		  predicate: item_at,
		  params: [bread, locatione]
		 ],
	two: [
		  predicate: item_at,
		  params: [peanutbutter, locatione]
		 ],	
	three: [
		  predicate: item_at,
		  params: [jelly, locatione]
		 ]


endlabels

module

	st: [0: init, 1: one, 2: two, 3: three];

	[] 0 -> 1;
	[] 1 -> 2;
	[] 2 -> 3;

endmodule