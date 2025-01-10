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
	              ]


endlabels

module

	st: [0: init, 0: go, 2: go, 2: approach];
	guard: [0: someone_home];

	[] 0 -> 1;
	[] 1 & guard=0 -> 2;

endmodule

options

	conditional_effects;

endoptions