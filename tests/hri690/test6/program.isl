import pddl.hri690
labels

	goal: [
		  predicate: item_at,
		  params: [groceries, refrigerator]
		  &
		  predicate: item_at,
		  params: [water, refrigerator]
		 ]


endlabels

module

	st: [0: init, 1: goal];

	[] 0 -> 1;

endmodule