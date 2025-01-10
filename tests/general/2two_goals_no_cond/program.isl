# Simple test with two goals and no conditionals.
import pddl.general
labels

	go: [
		  predicate: entity_in,
		  params: [stretch, kitchen]
		 ],
	come_back: [
				 predicate: entity_in,
				 params: [stretch, home]
	           ]


endlabels

module

	st: [0: init, 1: go, 2: come_back];

	[] 0 -> 1;
	[] 1 -> 2;

endmodule

options

	conditional_effects;

endoptions