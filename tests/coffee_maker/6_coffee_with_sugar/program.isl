# Plan C: put the mug on the coffee maker first, then grounds, then water, brew, and add sugar, and deliver to the person.

import pddl.coffee_maker

labels

	mug_placed: [
		  predicate: item_on,
		  params: [mug, maker]
		 ],

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

	topped: [
		  predicate: has_topping,
		  params: [mug, sugar]
		 ],

	delivered: [
		  predicate: item_on,
		  params: [mug, person]
		 ]

endlabels

module

	st: [0: init, 1: mug_placed, 2: grounds_ready, 3: water_ready, 4: coffee_made, 5: topped, 6: delivered];

	[] 0 -> 1;
	[] 1 -> 2;
	[] 2 -> 3;
	[] 3 -> 4;
	[] 4 -> 5;
	[] 5 -> 6;

endmodule
