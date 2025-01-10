import pddl.waterbot

labels

	ready: [
		  predicate: agent_has,
		  params: [stretch, cup] &
		  predicate: is_full,
		  params: [cup] &
		  predicate: agent_near,
		  params: [stretch, passenger]
		 ],
	
	delivered: [
		  predicate: agent_has,
		  params: [passenger, cup]
		 ],

	athome: [
		action: move_to,
		params: [stretch, charging]
	]


endlabels

module

	st: [0: init, 1: ready, 2: athome];
	guard: [0: delivered]; 

	[] 0 -> 1;
	[] 1 & guard=0 -> 2;

endmodule

options

	conditional_effects;

endoptions
