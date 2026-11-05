# Coffee with sugar: make coffee, then add sugar.

import pddl.coffee_maker

labels

	coffee_made: [
		  predicate: has_coffee,
		  params: [mug]
		 ],

	topped: [
		  predicate: has_sugar,
		  params: [mug]
		 ]

endlabels

module

	st: [0: init, 1: coffee_made, 2: topped];

	[] 0 -> 1;
	[] 1 -> 2;

endmodule
