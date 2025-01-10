# Simple test with a nondetermistic automaton.
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
	someone_home: [
					predicate: entity_in,
					params: [david, kitchen]
	              ],
	abort: [
			  predicate: entity_in,
			  params: [stretch, home]
	       ]


endlabels

module

	st: [0: init, 1: go, 2: approach, 3: abort];
	guard: [0: someone_home];

	[] 0 -> 1;
	[] 1 & guard=0 -> 2;
	[] 1 & guard=0 -> 3;

endmodule

options

	conditional_effects;

endoptions