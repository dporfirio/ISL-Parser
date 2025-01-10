# Simple test with one goal.
import pddl.food_assembly
labels

	one: [
		  predicate: agent_near,
		  params: [stretch, plate]
		 ],
	two: [
		  predicate: agent_has,
		  params: [stretch, plate]
		 ],
	three: [
		  predicate: object_at,
		  params: [plate, kitchen_table]
		 ]


endlabels

module

	st: [0: init, 1: one, 2: two, 3: three];

	[] 0 -> 1;
	[] 1 -> 2;
	[] 2 -> 3;

endmodule

options

	conditional_effects;

endoptions