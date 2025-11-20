# Healthcare test
import pddl.healthcare

labels


	move1: [
		  action: move_to,
		  params: [stretch, nursestation]
	],
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

	st: [0: init, 1: move1, 2: request1, 3: receive1, 4: deliver1];

	[] 0 -> 1;
    [] 1 -> 2;
	[] 2 -> 3;
	[] 3 -> 4;

endmodule