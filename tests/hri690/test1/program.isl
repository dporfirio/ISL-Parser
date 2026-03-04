import pddl.hri690
labels

	goal: [
		  predicate: robot_at,
		  params: [refrigerator]
		 ]


endlabels

module

	st: [0: init, 1: goal];

	[] 0 -> 1;

endmodule