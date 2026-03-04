import pddl.hri690
labels

	goal: [
		  predicate: is_open,
		  params: [refrigerator]
		 ]


endlabels

module

	st: [0: init, 1: goal];

	[] 0 -> 1;

endmodule