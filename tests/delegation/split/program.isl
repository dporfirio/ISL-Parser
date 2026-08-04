# delegation package fetch test: robot and staff deliver one package each
import pddl.delegation_weight

labels

    robot_has_package1: [
          predicate: agent_has,
          params: [temi, package1]
    ],

    recipient_has_both_with_staff_assigned: [
          predicate: agent_has,
          params: [recipient, package1]
          &
          predicate: agent_has,
          params: [recipient, package2]
          &
          predicate: task_assigned,
          params: [staff, could_you_please_deliver_package_1_and_package_2_to_recipient_in_robotic_lab]
    ]

endlabels

cost

    delegate_task: 0

endcost

module

    st: [0: init, 1: robot_has_package1, 2: recipient_has_both_with_staff_assigned];

    [] 0 -> 1;
    [] 1 -> 2;

endmodule
