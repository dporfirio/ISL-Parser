import pddl.food_assembly
labels

    opening: [
        action: open,
        params: [stretch, fridge, gripper]
    ]

endlabels

module

    st: [0: init, 1: opening];
    [] 0 -> 1;

endmodule

options

	conditional_effects;

endoptions