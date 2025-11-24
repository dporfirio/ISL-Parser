# Healthcare test
import pddl.healthcare_goals

labels

	one: [
		  predicate: is_approaching,
		  params: []
          &
          predicate: agent_near,
		  params: [stretch, bloodsample ]
    ]

endlabels

module

	st: [0: init, 1: one];

	[] 0 -> 1;

endmodule