# Simple test with one goal.
import pddl.food_assembly
labels

	one: [
		  predicate: agent_near,
		  params: [stretch, cup]
		 ],
	two: [
		  predicate: object_at,
		  params: [cup, kitchen_table]
		 ],
	three: [
		  predicate: object_at,
		  params: [plate, kitchen_table]
		 ]


endlabels

module

	st: [0: init, 1: one, 2: two, 3: three];

	[] 0 -> 1;
	[] 1 -> 3;
	[] 3 -> 2;

endmodule

options

	conditional_effects;

endoptions