# Simple test with one action.
import pddl.general
labels

	go: [
		  action: move_to,
		  params: [stretch, kitchen]
		 ]


endlabels

module

	st: [0: init, 1: go];

	[] 0 -> 1;

endmodule

options

	conditional_effects;

endoptions