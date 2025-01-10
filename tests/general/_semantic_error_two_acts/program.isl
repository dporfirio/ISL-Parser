# Simple test with an empty label.

import pddl.general

labels

	two_actions: [action: move_to,
			params: [stretch, home] &
			action: move_to,
			params: [stretch, unknown_region]]

endlabels

module

	st: [0: init, 1: two_actions];
	guard: [];

	[] 0 -> 1;

endmodule

options


endoptions