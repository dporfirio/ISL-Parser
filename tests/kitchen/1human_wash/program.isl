import pddl.kitchen

labels
  washed: [
    predicate: is_clean, params: [plate]
    & predicate: is_clean, params: [mug]
    & predicate: item_inside, params: [plate, sink]
    & predicate: item_inside, params: [mug, sink]
  ]
endlabels

module
  st: [0: init, 1: washed];
  [] 0 -> 1;
endmodule

