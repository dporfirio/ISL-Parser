# Healthcare test
import pddl.healthcare

labels

	move1: [
		  action: grab,
		  params: [stretch, bloodsample]
    ],
	move2: [
		  action: move_to,
		  params: [stretch, lab]
	]

endlabels

module

	st: [0: init, 1: move1, 2: move2];

	[] 0 -> 1;
	[] 1 -> 2;

endmodule