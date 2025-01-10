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

    come_back: [
        predicate: entity_in,
        params: [stretch, home]
    ]

endlabels

module

    st: [0: init, 1: moving, 2: carry, 3: come_back];
    [] 0 -> 1;
    [] 1 -> 2;
    [] 2 -> 3;

endmodule

options

	conditional_effects;

endoptions