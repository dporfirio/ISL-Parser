import pddl.food_assembly
labels

    moving: [
        predicate: agent_near,
        params: [stretch, table]
    ],

    carry: [
        predicate: agent_has,
        params: [stretch, apple]
    ],

    moving_final: [
        predicate: agent_near,
        params: [stretch, countertop]
    ],

    dropping_off: [
        predicate: object_at,
        params: [apple, countertop]
    ]

endlabels

module

    st: [0: init, 1: moving, 2: carry, 3: moving_final, 4: dropping_off];
    [] 0 -> 1;
    [] 1 -> 2;
    [] 2 -> 3;
    [] 3 -> 4;

endmodule

options

	conditional_effects;

endoptions