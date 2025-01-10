# Simple test with one goal.

import pddl.waterbot

labels

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

	st: [0: init, 1: delivered, 2: athome];

	[] 0 -> 1;
	[] 1 -> 2;

endmodule

options

	conditional_effects;

endoptions