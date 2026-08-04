import pddl.kitchen

labels
  placed_separately: [
    predicate: object_at, params: [plate, kitchen_countertop]
    & predicate: object_at, params: [mug, kitchen_countertop]
  ]
endlabels

module
  st: [0: init, 1: placed_separately];
  [] 0 -> 1;
endmodule

