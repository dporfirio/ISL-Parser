# Healthcare test
import pddl.healthcare_goals

labels

    one: [
        predicate: is_receiving,
		  params: []
          &
          predicate: agent_has,
		  params: [stretch, xrayfile]
    ],
    two: [
        predicate: is_delivering,
		  params: []
          &
          predicate: agent_has,
		  params: [icudoctor, xrayfile]
    ]

endlabels

module

	st: [0: init, 1: one, 2: two];

	[] 0 -> 1;
    [] 1 -> 2;

endmodule