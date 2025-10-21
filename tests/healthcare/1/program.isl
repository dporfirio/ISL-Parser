# Healthcare test
import pddl.healthcare

labels

	move1: [
		  action: grab_from_surface,
		  params: [stretch, bloodsample, icutray, icu]
    ],
	move2: [
		  action: move_from_entity_to_entity,
		  params: [stretch, icutray, icu, labbench, lab]
	]

endlabels

module

	st: [0: init, 1: move1, 2: move2];

	[] 0 -> 1;
	[] 1 -> 2;

endmodule