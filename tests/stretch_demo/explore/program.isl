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
	],
	fourth: [
          predicate: robot_at,
		  params: [locationd]
	],
	fifth: [
          predicate: robot_at,
		  params: [locationa]
	]


endlabels

module

	st: [0: init, 1: first, 2: second, 3: third, 4: fourth, 5: fifth];

	[] 0 -> 1;
	[] 1 -> 2;
	[] 2 -> 3;
	[] 3 -> 4;
	[] 4 -> 5;

endmodule