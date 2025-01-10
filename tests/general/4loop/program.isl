# Simple test with two goals and a conditional.
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
	stop: [
			  predicate: entity_in,
			  params: [stretch, home]
	       ]


endlabels

module

	st: [0: init, 1: go, 2: approach, 3: stop];
	guard: [0: someone_home];

	[] 0 -> 1;
	[] 1 & guard=0 -> 2;
	[] 2 & guard=0 -> 2;
	[] 2 & guard=default -> 3;

endmodule

options

	conditional_effects;

endoptions