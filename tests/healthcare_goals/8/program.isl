# Healthcare test
import pddl.healthcare_goals

labels

    one: [
          predicate: is_requesting,
		  params: []
          &
          predicate: requested,
		  params: [stretch, xrayfile, nurse]
	],
    two: [
        predicate: is_receiving,
		  params: []
          &
          predicate: agent_has,
		  params: [stretch, xrayfile]
    ],
    three: [
        predicate: is_delivering,
		  params: []
          &
          predicate: person_has,
		  params: [icudoctor, xrayfile]
    ]

endlabels

module

	st: [0: init, 1: one, 2: two, 3: three];

	[] 0 -> 1;
    [] 1 -> 2;
    [] 2 -> 3;

endmodule