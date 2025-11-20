# Healthcare test
import pddl.healthcare

labels

	request1: [
		action: request,
		params: [stretch, xrayfile, nurse]
	],
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

	st: [0: init, 1: request1, 2: receive1, 3: deliver1];

	[] 0 -> 1;
    [] 1 -> 2;
	[] 2 -> 3;

endmodule