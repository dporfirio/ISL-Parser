import pddl.kitchen

labels
  stacked_on_countertop: [
    predicate: item_on_item, params: [mug, plate]
    & predicate: object_at, params: [plate, kitchen_countertop]
  ],
  mug_in_sink: [
    predicate: item_inside, params: [mug, dishwasher]
    & predicate: is_clean, params: [mug]
  ]

endlabels

module
  st: [0: init, 1: stacked_on_countertop, 2: mug_in_sink];
  [] 0 -> 1;
  [] 1 -> 2;
endmodule

