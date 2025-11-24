# Healthcare test
import pddl.healthcare_goals

labels

	deliver1: [
		  predicate: is_putting,
		  params: []
          &
          predicate: object_at,
		  params: [bloodsample, labbench]
    ],
    deliver2: [
          predicate: is_putting,
		  params: []
          &
          predicate: object_at,
		  params: [ibuprofen, labbench]
	],
    deliver3: [
        predicate: is_putting,
		  params: []
          &
          predicate: object_at,
		  params: [linen, icutray]
    ]

endlabels

module

	st: [0: init, 1: deliver1, 2: deliver2, 3: deliver3];

	[] 0 -> 1;
    [] 1 -> 2;
    [] 2 -> 3;

endmodule