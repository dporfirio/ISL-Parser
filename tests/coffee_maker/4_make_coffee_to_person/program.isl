# Make coffee, then deliver the mug to the person.

import pddl.coffee_maker

labels

	coffee_made: [
		  predicate: has_coffee,
		  params: [mug]
		 ],

	delivered: [
		  predicate: item_on,
		  params: [mug, person]
		 ]

endlabels

module

	st: [0: init, 1: coffee_made, 2: delivered];

	[] 0 -> 1;
	[] 1 -> 2;

endmodule
