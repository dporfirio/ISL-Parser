import pddl.food_assembly
labels

    move_countertop: [
        predicate: agent_near,
        params: [stretch, countertop]
    ],

    grabs: [
        predicate: agent_has,
        params: [stretch, bread]
    ],

    move_person: [
        predicate: agent_near,
        params: [stretch, david]
    ],

    takes: [
        predicate: agent_has,
        params: [david, bread]
    ],

    takes_back: [
        predicate: agent_has,
        params: [stretch, bread]
    ],

    move_table: [
        predicate: agent_near,
        params: [stretch, table]
    ],

    dropoff: [
        predicate: object_at,
        params: [bread, table]
    ]

endlabels

module

    st: [0: init, 1: move_countertop, 2: grabs, 
        3: move_person, 5: takes, 
        7: takes_back, 8: move_table,
        9: dropoff];
    [] 0 -> 1;
    [] 1 -> 2;
    [] 2 -> 3;
    [] 3 -> 5;
    [] 5 -> 7;
    [] 7 -> 8;
    [] 8 -> 9;

endmodule

options

	conditional_effects;

endoptions