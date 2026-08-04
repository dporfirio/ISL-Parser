# delegation package fetch test
import pddl.delegation_weight

labels

    recipient_has_package1: [
          predicate: agent_has,
          params: [recipient, package1]
    ]

endlabels

cost

    delegate_task: 1

endcost

module

    st: [0: init, 1: recipient_has_package1];

    [] 0 -> 1;

endmodule
