# Simple test with one goal.
import pddl.waterbot
labels

	ready: [
		  predicate: agent_has,
		  params: [stretch, cup]
		 ],

	delivered: [
		  predicate: agent_has,
		  params: [passenger, cup]
	],

	athome: [
		  predicate: entity_in,
		  params: [stretch, charging]
	]


endlabels

module

	st: [0: init, 1: ready, 2: delivered, 3: athome];

	[] 0 -> 1;
	[] 1 -> 2;
	[] 2 -> 3;

endmodule

options

	conditional_effects;

endoptions