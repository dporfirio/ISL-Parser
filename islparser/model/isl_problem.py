from __future__ import annotations
from typing import Dict, Iterable, List, Set
import inflect
from islparser.model.state import Predicate
from islparser.parser.pddl_parser import (
    parse_to_unified_planner,
    parse_pddl_comments,
    parse_pddl_constants
)
import unified_planning as up  # type: ignore[import-untyped]
from unified_planning.model import (  # type: ignore[import-untyped]
    Problem,
    Fluent,
    Action,
    FNode,
    Object
)
from unified_planning.plans import (  # type: ignore[import-untyped]
    ActionInstance
)


class ISLProblem:

    problem: Problem

    # Convenience variables;
    # mostly for readability of plans and user interface.
    action_to_nl: Dict[str, str]
    action_to_internal: Dict[str, bool]
    predicate_to_nl: Dict[str, str]
    predicate_to_internal: Dict[str, bool]
    constants: List[str]

    def __init__(self) -> None:
        """Polaris Problem wraps the unified-planning problem class."""
        self.action_to_nl = {}
        self.action_to_internal = {}
        self.predicate_to_nl = {}
        self.predicate_to_internal = {}
        self.chkpt_gen = inflect.engine()

    def add_nl(self, action_to_nl, predicate_to_nl) -> None:
        self.action_to_nl = action_to_nl
        self.predicate_to_nl = predicate_to_nl

    def add_problem(self, problem) -> None:
        self.problem = problem

    def add_pddl(self, domain_fn, problem_fn):
        self.problem = parse_to_unified_planner(domain_fn, problem_fn)
        parse_pddl_comments(domain_fn, self)
        self.constants = parse_pddl_constants(domain_fn)

    def replace_initial_state(self, state_dict: Dict[FNode, FNode]) -> None:
        self.problem.explicit_initial_values.clear()
        for k, v in state_dict.items():
            self.problem.set_initial_value(k, v)

    def get_fluent(self, name: str) -> Fluent:
        """Get problem fluent matching name."""
        to_return = None
        for fluent in self.problem._fluents:
            if fluent.name == name or fluent.name.lower() == name.lower():
                to_return = fluent
                break
        return to_return

    def get_object(self, name: str) -> up.model.Object:
        """Get problem object matching the name."""
        for _type in self.problem.user_types:
            for obj in self.problem.objects(_type):
                if obj.name == name or obj.name.lower() == name.lower():
                    return obj

    def get_action(self, name) -> Action:
        """Get problem action matching the name."""
        for action in self.problem.actions:
            if action.name == name or action.name.lower() == name.lower():
                return action

    def action_nl(self, action: ActionInstance) -> str:
        """Converts ActionInstance to natural language."""
        s = self.action_to_nl[action.action.name]
        for i in range(len(action.actual_parameters)):
            s = s.replace("[{}]".format(i),
                          action.actual_parameters[i].object().name.upper())
        return s

    def predicate_nl(self, pred: Predicate) -> str:
        """Converts grounded fluent fnode to natural language."""
        if pred.fnode.is_fluent_exp():
            if pred.fnode.fluent().name in self.predicate_to_nl:
                s = self.predicate_to_nl[pred.fnode.fluent().name]
                for i, arg in enumerate(pred.fnode.args):
                    s = s.replace("[{}]".format(i), str(pred.fnode.args[i]))
                s = "       <<{}>>".format(s)
                return s
        return str(pred.fnode)

    def _objects_in_expr(self, expr: FNode) -> Set[Object]:
        """Collect all Objects appearing as OBJECT_EXP nodes in an expression DAG."""
        seen: Set[int] = set()
        stack = [expr]
        out: Set[Object] = set()

        while stack:
            n = stack.pop()
            if n.node_id in seen:
                continue
            seen.add(n.node_id)

            if n.is_object_exp():
                out.add(n.object())  # object() is defined for OBJECT_EXP nodes
                continue

            # Recurse into children
            stack.extend(n.args)

        return out

    def rebuild_problem_pruning_objects(
            self,
            keep_objects: Iterable[Object]) -> None:
        """
        Rebuilds a new Problem:
        - same environment
        - copies user types, fluents, actions
        - keeps only keep_objects
        - copies explicit initial values that don't mention removed objects (in key or value)
        """
        problem = self.problem
        keep_objects = set(keep_objects)

        # Collect all objects from the original problem
        all_objects: Set[Object] = set(problem.all_objects)
        removed = all_objects - keep_objects

        # Create new problem in the SAME environment
        p2 = up.model.Problem(problem.name, environment=problem.environment)

        # Copy fluents and actions (this implicitly registers types)
        for fluent in problem.fluents:
            p2.add_fluent(fluent, default_initial_value=False)
        p2.add_actions(problem.actions)

        # Add only the desired objects
        p2.add_objects(sorted(keep_objects, key=lambda o: o.name))

        # Copy initial values that do not mention removed objects
        for lhs, rhs in problem.explicit_initial_values.items():
            if (self._objects_in_expr(lhs) & removed) or (self._objects_in_expr(rhs) & removed):
                continue
            p2.set_initial_value(lhs, rhs)

        self.problem = p2

    def clone(self) -> ISLProblem:
        new_problem = ISLProblem()
        new_problem.add_nl(self.action_to_nl, self.predicate_to_nl)
        new_problem.add_problem(self.problem.clone())
        return new_problem


class ISLProblemFactory:

    @classmethod
    def make(cls) -> ISLProblem:
        return ISLProblem()
