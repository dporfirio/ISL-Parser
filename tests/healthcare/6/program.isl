# Healthcare test
import pddl.healthcare

labels

	move: [
		  action: approach,
		  params: [stretch, bloodsample]
	]

endlabels

module

	st: [0: init, 1: move];

	[] 0 -> 1;

endmodule