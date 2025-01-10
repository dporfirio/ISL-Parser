# Simple test with two goals and a conditional.
import pddl.general
labels

	go: [
		  predicate: entity_is_in,
		  params: [stretch, kitchen]
		 ],
	approach: [
				 predicate: agent_is_near,
				 params: [stretch, davi]
	           ],
	someone_home: [
					predicate: entity_in_here,
					params: [david, kitchen]
	              ],
	bad_action: [action: moveto, params: [stretch, kitchen_counter]]


endlabels

module

	st: [0: init, 1: go, 2: approach];
	guard: [0: someone_home];

	[] 0 -> 1;
	[] 1 & guard=0 -> 2;

endmodule

options

	conditional_effects;

endoptions