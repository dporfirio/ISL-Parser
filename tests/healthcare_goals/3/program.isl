# Healthcare test
import pddl.healthcare_goals

labels

	one: [
		  predicate: is_grabbing,
		  params: []
          &
          predicate: agent_has,
		  params: [stretch, bloodsample]
    ],
    two: [
          predicate: is_approaching,
		  params: []
          &
          predicate: agent_near,
		  params: [stretch, labbench]
	],
    three: [
        predicate: is_putting,
		  params: []
          &
          predicate: object_at,
		  params: [bloodsample, labbench]
    ],
    four: [
        predicate: is_putting,
		  params: []
          &
          predicate: object_at,
		  params: [antacid1, labbench]
    ]

endlabels

module

	st: [0: init, 1: one, 2: two, 3: three, 4: four];

	[] 0 -> 1;
    [] 1 -> 2;
    [] 2 -> 3;
    [] 3 -> 4;

endmodule