# Healthcare test
import pddl.healthcare_goals

labels
	
    one: [
        predicate: is_moving,
		  params: []
          &
          predicate: entity_in,
		  params: [stretch, pharmacy]
    ],
	two: [
		predicate: is_approaching,
		params: []
		&
		predicate: agent_near,
		params: [stretch, medicinecabinet]
	],
	three: [
		predicate: is_grabbing,
		  params: []
          &
          predicate: agent_has,
		  params: [stretch, bandages1]
	],

	four: [
		predicate: is_closing,
		  params: []
	],
	five: [
		predicate: is_delivering,
		  params: []
          &
          predicate: agent_has,
		  params: [icudoctor, bandages1]
	]

	
endlabels

module

	st: [0: init, 1: one, 2: two, 3: three,4: four, 5: five];

	[] 0 -> 1;
    [] 1 -> 2;
	[] 2 -> 3;
	[] 3 -> 4;
	[] 4 -> 5;

endmodule