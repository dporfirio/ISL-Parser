# Two sequential goals: add cream to the mug, then deliver it to the person.

import pddl.coffee_maker

labels

	creamed: [
		  predicate: has_cream,
		  params: [mug]
		 ],

	delivered: [
		  predicate: item_on,
		  params: [mug, person]
		 ]

endlabels

module

	st: [0: init, 1: creamed, 2: delivered];

	[] 0 -> 1;
	[] 1 -> 2;

endmodule
