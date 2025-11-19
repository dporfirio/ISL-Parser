# Healthcare test
import pddl.healthcare

labels


	move1: [
		  action: move_to,
		  params: [stretch, emergencyroom]
	],
	grab1: [
		  action: grab,
		  params: [stretch, bloodsample]
    ],
	deliver1: [
		  action: deliver,
		  params: [stretch, bloodsample, labtech]
    ]

endlabels

module

	st: [0: init, 1: move1, 2: grab1, 3: deliver1];

	[] 0 -> 1;
    [] 1 -> 2;
	[] 2 -> 3;

endmodule