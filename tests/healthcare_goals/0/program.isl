# Healthcare test
import pddl.healthcare_goals

labels

	one: [
		  predicate: is_putting,
		  params: []
          &
          predicate: object_at,
		  params: [bloodsample, labbench]
    ],
    two: [
          predicate: is_putting,
		  params: []
          &
          predicate: object_at,
		  params: [amoxicillin1, labbench]
	]

endlabels

module

	st: [0: init, 1: one, 2: two];

	[] 0 -> 1;
    [] 1 -> 2;

endmodule