# Plan B: add water first, then fill the filter with grounds, brew, and add cream (milk), and deliver to the person.

import pddl.coffee_maker

labels

	water_ready: [
		  predicate: has_water,
		  params: [coffee_maker]
		 ],

	grounds_ready: [
		  predicate: has_grounds,
		  params: [filter]
		 ],

	coffee_made: [
		  predicate: has_coffee,
		  params: [mug]
		 ],

	topped: [
		  predicate: has_topping,
		  params: [mug, cream]
		 ],

	delivered: [
		  predicate: item_on,
		  params: [mug, person]
		 ]

endlabels

module

	st: [0: init, 1: water_ready, 2: grounds_ready, 3: coffee_made, 4: topped, 5: delivered];

	[] 0 -> 1;
	[] 1 -> 2;
	[] 2 -> 3;
	[] 3 -> 4;
	[] 4 -> 5;

endmodule
