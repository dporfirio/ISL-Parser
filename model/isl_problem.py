from __future__ import annotations
from typing import Dict
import inflect
from model.state import Predicate
from parser.pddl_parser import parse_to_unified_planner, parse_pddl_comments
import unified_planning as up  # type: ignore[import-untyped]
from unified_planning.model import (  # type: ignore[import-untyped]
    Problem,
    Fluent,
    Action
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

    def __init__(self) -> None:
        """Polaris Problem wraps the unified-planning problem class."""
        self.action_to_nl = {}
        self.action_to_internal = {}
        self.predicate_to_nl = {}
        self.predicate_to_internal = {}
        self.chkpt_gen = inflect.engine()

    def add_pddl(self, domain_fn, problem_fn):
        self.problem = parse_to_unified_planner(domain_fn, problem_fn)
        parse_pddl_comments(domain_fn,
                            self.predicate_to_nl,
                            self.predicate_to_internal,
                            self.action_to_nl,
                            self.action_to_internal)

    def get_fluent(self, name: str) -> Fluent:
        """Get problem fluent matching name."""
        to_return = None
        for fluent in self.problem._fluents:
            if fluent.name == name:
                to_return = fluent
                break
        return to_return

    def get_object(self, name: str) -> up.model.Object:
        """Get problem object matching the name."""
        for _type in self.problem.user_types:
            for obj in self.problem.objects(_type):
                if obj.name == name:
                    return obj

    def get_action(self, name) -> Action:
        """Get problem action matching the name."""
        for action in self.problem.actions:
            if action.name == name:
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


class ISLProblemFactory:

    @classmethod
    def make(cls) -> ISLProblem:
        return ISLProblem()
