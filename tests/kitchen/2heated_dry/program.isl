import pddl.kitchen

labels
  heated: [
    predicate: is_clean, params: [plate]
    & predicate: is_clean, params: [mug]
    & predicate: item_inside, params: [plate, dishwasher]
    & predicate: item_inside, params: [mug, dishwasher]
    & predicate: button_pressed, params: [wash_heated_dry]
  ]
endlabels

module
  st: [0: init, 1: heated];
  [] 0 -> 1;
endmodule

