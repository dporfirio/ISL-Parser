# Simple test with two actions and no conditionals.
import pddl.general
labels

	go: [
		  action: move_to,
		  params: [stretch, kitchen]
		 ],
	come_back: [
				 action: move_to,
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