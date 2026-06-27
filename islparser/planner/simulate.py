from __future__ import annotations

from unified_planning.shortcuts import SequentialSimulator  # type: ignore[import-untyped]
import threading
import time
from typing import TYPE_CHECKING, Any

if TYPE_CHECKING:
    from islparser.model.automata import Automaton

try:
    import rclpy
    from rclpy.node import Node
    from std_msgs.msg import String
except ModuleNotFoundError:
    rclpy = None  # type: ignore[assignment]
    Node = object  # type: ignore[misc,assignment]
    String = Any  # type: ignore[misc,assignment]


def _require_ros() -> None:
    if rclpy is None:
        raise RuntimeError(
            "ROS 2 support requires the optional dependencies 'rclpy' and "
            "'std_msgs'. Install/source ROS 2 before using execution mode."
        )


class SimulatorNode(Node):

    def __init__(self, simulator) -> None:
        super().__init__('isl_simulator')
        self.simulator = simulator
        print("[ROS2] Creating publisher on topic '/isl_send'")
        self.publisher = self.create_publisher(String, '/isl_send', 10)
        print("[ROS2] Creating subscriber on topic '/isl_receive'")
        self.subscriber = self.create_subscription(String, '/isl_receive', self.finished_action, 10)
        print("[ROS2] Node initialized successfully")

    def publish_message(self, message: str) -> None:
        """Publish a message to the isl_send topic."""
        msg = String()
        msg.data = message
        self.publisher.publish(msg)
        print(f"[ROS2] Published message: {message}")
        self.get_logger().info(f'Published: {message}')

    def finished_action(self, msg: String) -> None:
        """Callback for messages received on isl_receive topic."""
        print(f"[ROS2] Callback triggered! Received: {msg.data}")
        self.get_logger().info(f'Received: {msg.data}')
        self.simulator.next_action(msg.data)


class Simulator:

    def __init__(self) -> None:
        _require_ros()
        print("[Simulator] Initializing ROS2...")
        rclpy.init()
        print("[Simulator] Creating SimulatorNode...")
        self.node = SimulatorNode(self)
        self.aut: Automaton | None = None
        self.plan_result = None

        # Start spinning the node in a background thread (non-daemon so it doesn't die)
        print("[Simulator] Starting background thread for ROS2 spinning...")
        self.spin_thread = threading.Thread(target=self._spin_node, daemon=False)
        self.spin_thread.start()
        print("[Simulator] Initialization complete. Waiting for messages...")

    def _spin_node(self) -> None:
        """Spin the ROS2 node in a background thread to listen for messages."""
        print("[ROS2 Thread] Starting rclpy.spin()...")
        try:
            rclpy.spin(self.node)
        except Exception as e:
            print(f"[ROS2 Thread] Error during spin: {e}")

    def simulate(self, aut: Automaton) -> None:
        from islparser.planner.classical import plan

        print("[Simulator] Starting simulation...")
        self.aut = aut
        pr = plan(aut)
        self.plan_result = pr
        action = pr.plan.init.out_trans[0].target.action
        print(f"[Simulator] Initial action: {action}")
        # Publish the action to ROS2
        self.publish_action(str(action))
        # Keep the main thread alive to allow ROS2 to receive messages
        print("[Simulator] Entering main loop. Waiting for ROS2 messages...")
        try:
            while True:
                time.sleep(0.5)
        except KeyboardInterrupt:
            print("\n[Simulator] Keyboard interrupt received. Shutting down...")
            self.shutdown()

    def publish_action(self, action_str: str) -> None:
        """Publish an action to the isl_send topic."""
        print(f"[Simulator] Publishing action: {action_str}")
        self.node.publish_message(action_str)

    def next_action(self, action_data: str) -> None:
        """Process the next action received from isl_receive topic."""
        print(f"[Simulator] Processing next action: {action_data}")

        if self.aut is None or self.plan_result is None:
            print('Error: No automaton or plan result available')
            return

        # Get the action that was executed
        current_action = self.plan_result.plan.init.out_trans[0].target.action
        print(f"[Simulator] Current action executed: {current_action}")

        # Use the UP simulator to apply the action and get the resulting state
        print("[Simulator] Creating UP simulator and applying action...")
        try:
            simulator = SequentialSimulator(self.aut.problem.problem)
            # Get the initial state from the simulator (this is the full state)
            current_state = simulator.get_initial_state()

            # Build a complete state dict starting with current values
            complete_state = dict(current_state._values)
            print(f"[Simulator] Complete state before action: {complete_state}")

            # Apply the action to get the resulting state
            next_state = simulator.apply(current_state, current_action)
            print(f"[Simulator] Action applied, delta values: {next_state._values}")

            # Merge the delta values into the complete state
            complete_state.update(next_state._values)
            print(f"[Simulator] Complete state after action: {complete_state}")

            # Condense the state to clean it up
            next_state._condense_state()

            # Update the automaton's problem initial state with all values
            self.aut.problem.replace_initial_state(complete_state)

        except Exception as e:
            print(f"[Simulator] Error applying action: {e}")
            import traceback
            traceback.print_exc()
            return

        # Check if the current checkpoint's goals are already satisfied
        # and advance the automaton past achieved checkpoints
        while self.aut.init is not None and len(self.aut.init.out_trans) > 0:
            next_checkpoint = self.aut.init.out_trans[0].target
            if not next_checkpoint.predicates:
                break
            initial_values = self.aut.problem.problem.initial_values
            all_satisfied = True
            for pred in next_checkpoint.predicates:
                if pred.fnode in initial_values:
                    if not initial_values[pred.fnode].is_true():
                        all_satisfied = False
                        break
                else:
                    all_satisfied = False
                    break
            if all_satisfied:
                print(f"[Simulator] Checkpoint '{next_checkpoint.name}' already achieved, advancing...")
                self.aut.init = next_checkpoint
            else:
                break

        # Replan from the new state
        print("[Simulator] Replanning from new state...")
        try:
            from islparser.planner.classical import plan

            pr = plan(self.aut)
            self.plan_result = pr

            if pr.plan.init.out_trans:
                next_act = pr.plan.init.out_trans[0].target.action
                print(f'[Simulator] Next action: {next_act}')
                time.sleep(4)
                self.publish_action(str(next_act))
            else:
                print('[Simulator] No more actions available')
        except Exception as e:
            print(f"[Simulator] Error during replanning: {e}")
            import traceback
            traceback.print_exc()

    def shutdown(self) -> None:
        """Clean up ROS2 resources."""
        print("[Simulator] Shutting down...")
        self.node.destroy_node()
        rclpy.shutdown()
