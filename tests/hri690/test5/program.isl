import pddl.hri690
labels

	goal: [
		  predicate: item_at,
		  params: [groceries, dining_table]
		  &
		  predicate: item_at,
		  params: [water, dining_table]
		 ]


endlabels

module

	st: [0: init, 1: goal];

	[] 0 -> 1;

endmodule