import pddl.kitchen

labels
  manually_dried: [
    predicate: is_clean, params: [plate]
    & predicate: is_clean, params: [mug]
    & predicate: object_at, params: [plate, dish_rack]
    & predicate: object_at, params: [mug, dish_rack]
    & predicate: button_pressed, params: [wash_manual_dry]
  ]
endlabels

module
  st: [0: init, 1: manually_dried];
  [] 0 -> 1;
endmodule

