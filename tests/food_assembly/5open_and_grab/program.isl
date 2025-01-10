import pddl.food_assembly
labels

    moving: [
        predicate: entity_in,
        params: [stretch, kitchen]
    ],

    opening: [
        predicate: is_open,
        params: [fridge]
    ],

    grabs: [
        predicate: agent_has,
        params: [stretch, apple]
    ],

    moving_final: [
        predicate: agent_near,
        params: [stretch, table]
    ],

    drop_off: [
        predicate: object_at,
        params: [apple, table]
    ]

endlabels

module

    st: [0: init, 1: moving, 2: opening, 3: grabs, 4: moving_final, 5: drop_off];
    [] 0 -> 1;
    [] 1 -> 2;
    [] 2 -> 3;
    [] 3 -> 4;
    [] 4 -> 5;

endmodule

options

	conditional_effects;

endoptions