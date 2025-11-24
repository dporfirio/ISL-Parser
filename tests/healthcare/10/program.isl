# Healthcare test
import pddl.healthcare

labels

	move: [
		action: put_on_surface,
		params: [stretch, bloodsample, labbench]
	],
	place: [
		action: grab,
		params: [stretch, amoxicillin]
	]

endlabels

module

	st: [0: init, 1: move, 2: place];

	[] 0 -> 1;
	[] 1 -> 2;

endmodule