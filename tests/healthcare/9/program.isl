# Healthcare test
import pddl.healthcare

labels

	receive1: [
		action: receive,
		params: [stretch, xrayfile, nurse]
	],
	deliver1: [
		  action: deliver,
		  params: [stretch, xrayfile, icudoctor]
    ]

endlabels

module

	st: [0: init, 1: receive1, 2: deliver1];

	[] 0 -> 1;
    [] 1 -> 2;

endmodule