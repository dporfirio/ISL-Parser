# Simple test with three goals and a conditional based on success or failure.
import pddl.general
labels

	go: [
		  predicate: entity_in,
		  params: [stretch, kitchen]
		 ],
	approach: [
				 predicate: agent_near,
				 params: [stretch, david]
	           ],
	stop: [
			  predicate: entity_in,
			  params: [stretch, home]
	       ]


endlabels

module

	st: [0: init, 1: go, 2: approach, 3: stop];

	[] 0 -> 1;
	[] 1 & guard=SUCCESS -> 2;
	[] 1 & guard=FAILURE -> 3;

endmodule

options

	conditional_effects;

endoptions