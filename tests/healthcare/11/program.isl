# Healthcare test
import pddl.healthcare

labels

	one: [
		action: approach,
		params: [stretch, xrayfile]
	],
	two: [
		action: grab,
		params: [stretch, xrayfile]
	],
    three: [
		action: move_to,
		params: [stretch, lab]
	],
	four: [
		action: approach,
		params: [stretch, labbench]
	],
    five: [
		action: put_on_surface,
		params: [stretch, xrayfile, labbench]
	]

endlabels

module

	st: [0: init, 1: one, 2: two, 3: three, 4: four, 5: five];

	[] 0 -> 1;
	[] 1 -> 2;
    [] 2 -> 3;
	[] 3 -> 4;
    [] 4 -> 5;

endmodule