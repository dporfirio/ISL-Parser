# Healthcare test
import pddl.healthcare

labels

	deliver1: [
		  action: put_on_surface,
		  params: [stretch, bloodsample, labbench, lab]
    ],
    deliver2: [
          action: put_on_surface,
		  params: [stretch, medication, labbench, lab]
	]

endlabels

module

	st: [0: init, 1: deliver1, 2: deliver2];

	[] 0 -> 1;
    [] 1 -> 2;

endmodule