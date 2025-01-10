# Simple test with an empty label.

import pddl.general

labels

	empty: []

endlabels

module

	st: [0: init, 1: empty];
	guard: [];

	[] 0 -> 1;

endmodule

options


endoptions