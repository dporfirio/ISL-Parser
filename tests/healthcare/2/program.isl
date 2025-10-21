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
	],
	deliver3: [
          action: put_on_surface,
		  params: [stretch, linen, icutray, icu]
	]

endlabels

module

	st: [0: init, 1: deliver1, 2: deliver2, 3: deliver3];

	[] 0 -> 1;
    [] 1 -> 2;
	[] 2 -> 3;

endmodule