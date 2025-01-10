# Simple test with one goal.
import pddl.food_assembly
labels

	moving: [
		  predicate: entity_in,
		  params: [stretch, dining_area]
		 ]


endlabels

module

	st: [0: init, 1: moving];

	[] 0 -> 1;

endmodule

options

	conditional_effects;

endoptions