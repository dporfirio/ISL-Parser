import pddl.kitchen

labels
  stacked_on_countertop: [
    predicate: item_on_item, params: [mug, plate]
    & predicate: object_at, params: [plate, kitchen_countertop]
  ]
endlabels

module
  st: [0: init, 1: stacked_on_countertop];
  [] 0 -> 1;
endmodule

