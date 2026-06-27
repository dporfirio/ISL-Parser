import pddl.food_assembly
labels

    person_get: [
        action: offer,
        params: [stretch, bread, david]
    ],
    robot_get: [
        action: grab,
        params: [stretch, apple, gripper]
    ]


endlabels

module

    st: [0: init, 1: person_get, 2: robot_get];
    [] 0 -> 1;
    [] 1 -> 2;

endmodule

options


endoptions