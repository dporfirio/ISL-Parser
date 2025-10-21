# Healthcare test
import pddl.healthcare

labels

	deliver1: [
		  action: grab_from_surface,
		  params: [stretch, bloodsample, icutray, icu]
    ],
	deliver2: [
		  action: move_from_entity_to_entity,
		  params: [stretch, icutray, icu, labbench, lab]
    ],
	deliver3: [
		  action: put_on_surface,
		  params: [stretch, bloodsample, labbench, lab]
    ],
    deliver4: [
          action: put_on_surface,
		  params: [stretch, medication, labbench, lab]
	]

endlabels

module

	st: [0: init, 1: deliver1, 2: deliver2, 3: deliver3, 4: deliver4];

	[] 0 -> 1;
    [] 1 -> 2;
	[] 2 -> 3;
    [] 3 -> 4;

endmodule