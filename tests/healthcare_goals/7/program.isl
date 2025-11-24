# Healthcare test
import pddl.healthcare_goals

labels

	one: [
		  predicate: is_moving,
		  params: []
          &
          predicate: entity_in,
		  params: [stretch, nursestation]
    ],
    two: [
          predicate: is_requesting,
		  params: []
          &
          predicate: requested,
		  params: [stretch, xrayfile, nurse]
	],
    three: [
        predicate: is_receiving,
		  params: []
          &
          predicate: agent_has,
		  params: [stretch, xrayfile]
    ],
    four: [
        predicate: is_delivering,
		  params: []
          &
          predicate: person_has,
		  params: [icudoctor, xrayfile]
    ]

endlabels

module

	st: [0: init, 1: one, 2: two, 3: three, 4: four];

	[] 0 -> 1;
    [] 1 -> 2;
    [] 2 -> 3;
    [] 3 -> 4;

endmodule