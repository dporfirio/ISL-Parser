import pddl.food_assembly
labels

    moving: [
        predicate: entity_in,
        params: [stretch, kitchen]
    ],

    grabs: [
        predicate: agent_has,
        params: [stretch, apple]
    ],

    approaches: [
        predicate: agent_near,
        params: [stretch, david]
    ],

    gives: [
        predicate: agent_has,
        params: [david, apple]
    ]

endlabels

module

    st: [0: init, 1: moving, 2: grabs, 3: approaches, 4: gives];
    [] 0 -> 1;
    [] 1 -> 2;
    [] 2 -> 3;
    [] 3 -> 4;

endmodule

options

	conditional_effects;

endoptions