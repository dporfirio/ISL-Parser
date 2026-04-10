# Simple test with one goal.

import pddl.stretch_demo

labels

	delivered: [
		  predicate: item_at,
		  params: [peanutbutter, locatione]
          &
          predicate: item_at,
		  params: [jelly, locatione]
		  &
          predicate: item_at,
		  params: [bread, locatione]
		 ]


endlabels

module

	st: [0: init, 1: delivered];

	[] 0 -> 1;

endmodule