import pddl.food_assembly
labels

    move_plate: [
        predicate: object_at,
        params: [plate, table]
    ],

    move_cup: [
        predicate: object_at,
        params: [cup, table]
    ]

endlabels

module

    st: [0: init, 1: move_plate, 2: move_cup];
    [] 0 -> 1;
    [] 1 -> 2;

endmodule

options

	conditional_effects;

endoptions