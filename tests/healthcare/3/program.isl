# Healthcare test
import pddl.healthcare

labels

	deliver1: [
		  action: grab,
		  params: [stretch, bloodsample]
    ],
	deliver2: [
		  action: approach,
		  params: [stretch, labbench]
    ],
	deliver3: [
		  action: put_on_surface,
		  params: [stretch, bloodsample, labbench]
    ],
    deliver4: [
          action: put_on_surface,
		  params: [stretch, medication, labbench]
	]

endlabels

module

	st: [0: init, 1: deliver1, 2: deliver2, 3: deliver3, 4: deliver4];

	[] 0 -> 1;
    [] 1 -> 2;
	[] 2 -> 3;
    [] 3 -> 4;

endmodule