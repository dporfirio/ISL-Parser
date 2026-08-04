import pddl.kitchen

labels
  stacked_in_sink: [
    predicate: item_on_item, params: [mug, plate]
    & predicate: item_inside, params: [plate, sink]
  ]
endlabels

module
  st: [0: init, 1: stacked_in_sink];
  [] 0 -> 1;
endmodule

