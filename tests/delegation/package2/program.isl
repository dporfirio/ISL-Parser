# delegation package fetch test
import pddl.delegation_weight

labels

    recipient_has_package2: [
          predicate: agent_has,
          params: [recipient, package2]
    ]

endlabels

cost

    delegate_task: 1

endcost

module

    st: [0: init, 1: recipient_has_package2];

    [] 0 -> 1;

endmodule
