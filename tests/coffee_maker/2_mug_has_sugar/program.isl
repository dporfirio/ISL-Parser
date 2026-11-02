# Simple test with one goal.

import pddl.coffee_maker

labels

	final_state: [
		  predicate: has_sugar,
		  params: [mug]
		 ]


endlabels

module

	st: [0: init, 1: final_state];

	[] 0 -> 1;

endmodule