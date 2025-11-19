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
		  action: put_on_surface,
		  params: [stretch, bloodsample, labbench]
    ],
	move2: [
		  action: move_to,
		  params: [stretch, pharmacy]
	],
	grab2: [
		  action: grab,
		  params: [stretch, ibuprofen]
    ],
	deliver2: [
		  action: put_on_surface,
		  params: [stretch, ibuprofen, icutray]
    ]

endlabels

module

	st: [0: init, 1: move1, 2: grab1, 3: deliver1, 4: move2, 5: grab2, 6: deliver2];

	[] 0 -> 1;
    [] 1 -> 2;
	[] 2 -> 3;
    [] 3 -> 4;
	[] 4 -> 5;
	[] 5 -> 6;


endmodule