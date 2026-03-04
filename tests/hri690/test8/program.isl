import pddl.hri690
labels

	goal: [
		  predicate: is_open,
		  params: [refrigerator]
		  &
		  predicate: is_open,
		  params: [entry_closet]
		  &
		  predicate: is_open,
		  params: [stove]
		 ]


endlabels

module

	st: [0: init, 1: goal];

	[] 0 -> 1;

endmodule