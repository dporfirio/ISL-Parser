# delegation package fetch test
import pddl.delegation_weight

labels

    recipient_has_both: [
          predicate: agent_has,
          params: [recipient, package1]
          &
          predicate: agent_has,
          params: [recipient, package2]
    ]

endlabels

cost

    delegate_task: 100
    
endcost

module

    st: [0: init, 1: recipient_has_both];

    [] 0 -> 1;

endmodule
