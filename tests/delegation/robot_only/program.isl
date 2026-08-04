# delegation package fetch test: the robot delivers both packages
import pddl.delegation_weight

labels

    robot_has_package1: [
          predicate: agent_has,
          params: [temi, package1]
    ],

    recipient_has_package1: [
          predicate: agent_has,
          params: [recipient, package1]
    ],

    robot_has_package2: [
          predicate: agent_has,
          params: [temi, package2]
    ],

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

    st: [0: init, 1: robot_has_package1, 2: recipient_has_package1, 3: robot_has_package2, 4: recipient_has_both];

    [] 0 -> 1;
    [] 1 -> 2;
    [] 2 -> 3;
    [] 3 -> 4;

endmodule
