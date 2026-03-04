import pddl.hri690
labels

	goal: [
		  predicate: item_at,
		  params: [groceries, refrigerator]
		  &
		  predicate: person_has,
		  params: [water]
		 ]


endlabels

module

	st: [0: init, 1: goal];

	[] 0 -> 1;

endmodule