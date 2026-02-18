# Simple test with one goal.

import pddl.gmu_fuse

labels

	delivered: [
		  predicate: item_inside,
		  params: [towels, pantry]
          &
          predicate: item_inside,
		  params: [yogurt, refrigerator]
		 ]


endlabels

module

	st: [0: init, 1: delivered];

	[] 0 -> 1;

endmodule