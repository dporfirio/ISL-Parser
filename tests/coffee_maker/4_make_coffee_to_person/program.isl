# Plan A: grind the beans and fill the filter first, then add water, brew, and deliver to the person.

import pddl.coffee_maker

labels

	grounds_ready: [
		  predicate: has_grounds,
		  params: [filter]
		 ],

	water_ready: [
		  predicate: has_water,
		  params: [maker]
		 ],

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

	st: [0: init, 1: grounds_ready, 2: water_ready, 3: coffee_made, 4: delivered];

	[] 0 -> 1;
	[] 1 -> 2;
	[] 2 -> 3;
	[] 3 -> 4;

endmodule
