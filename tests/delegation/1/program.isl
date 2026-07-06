# delegation package fetch test
import pddl.delegation_weight

labels

    requester_has_both: [
          predicate: agent_has,
          params: [requester1, package_item1]
          &
          predicate: agent_has,
          params: [requester1, package_item2]
    ]

endlabels

cost

    delegate_task: 1
    
endcost

module

    st: [0: init, 1: requester_has_both];

    [] 0 -> 1;

endmodule
