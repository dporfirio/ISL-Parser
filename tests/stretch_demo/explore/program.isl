# Simple test with one goal.

import pddl.stretch_demo

labels

	first: [
		  predicate: robot_at,
		  params: [locatione]
	],
	second: [
          predicate: robot_at,
		  params: [locationb]
	],
	third: [
          predicate: robot_at,
		  params: [locationc]
		 ]


endlabels

module

	st: [0: init, 1: first, 2: second, 3: third];

	[] 0 -> 1;
	[] 1 -> 2;
	[] 2 -> 3;

endmodule