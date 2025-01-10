from __future__ import annotations
from typing import List, cast
from model.state import (
    State,
    CheckpointFactory,
    LabeledFormula,
    Predicate
)
from model.transition import Transition
from model.conditionals import (  # type: ignore[import-not-found]
    get_list_of_conditional_values
)
from util.componentidentifier import ComponentIdentifier
from unified_planning.plans import (  # type: ignore[import-untyped]
    ActionInstance
)
from unified_planning.model import (  # type: ignore[import-untyped]
    Problem,
    FNode
)


class Automaton:

    states: List[State]
    transitions: List[Transition]
    init: State | None
    id_to_state: ComponentIdentifier
    predicate_key: PredicateKey

    def __init__(self, problem: Problem, unsat=False) -> None:
        '''
        Stores a finite transition system.
        '''
        self.reset()

        # store the pddl domain and problem
        self.problem = problem

        # flags
        self.unsat = unsat
        self.parsat = False

        # storing branch points that could not be satisfied
        self.unsat_branch_points: List[State] = []
        self.unsat_trans: List[Transition] = []

        # bookkeeping
        self.predicate_key = PredicateKey.instance()

    def is_unsatisfiable(self) -> bool:
        """ A goal within the automaton is unsatisfiable. """
        return self.unsat

    def is_valid(self) -> bool:
        '''
        Is neither unsatisfiable nor unsupported nor executable.
        '''
        return not (self.is_unsatisfiable() or not self.is_executable())

    def initialize(self) -> None:
        """Create an empty automaton"""
        self.reset()
        '''
        self.states.append(CheckpointFactory.make(_id=0,
                                                  name="init",
                                                  predicates=[],
                                                  action=None,
                                                  )
                           )
        '''

    def build(self) -> None:
        '''
        0. Assemble the id to state dictionary
        1. Complete the transitions
        2. Complete the states
        '''
        self.id_to_state.clear()
        for state in self.states:
            self.id_to_state[state._id] = state
            state.in_trans = []
            state.out_trans = []
        for trans in self.transitions:
            source_id = trans.source_id
            target_id = trans.target_id
            trans.source = self.id_to_state[source_id]
            trans.target = self.id_to_state[target_id]
            cast(State, trans.source).out_trans.append(trans)
            cast(State, trans.target).in_trans.append(trans)

    def reset(self) -> None:
        self.states = []
        self.init = None
        self.id_to_state = ComponentIdentifier(State)
        self.transitions = []

    def get_predicate_id(self, predicate: Predicate) -> int:
        return self.predicate_key.get_predicate_id(predicate)

    def get_predicate_from_id(self, _id: int) -> Predicate:
        return self.predicate_key.get_predicate_from_id(_id)

    def query_state_by_name(self, name: str) -> State:
        '''
        TODO: decide if names are non-unique, and if not, break upon
              finding a match.
        '''
        to_return: State | None = None
        for state in self.states:
            if state.name == name:
                to_return = state
        assert to_return is not None, \
               "State query must have valid name."
        return to_return

    def contains_branches(self) -> bool:
        '''
        Returns True if the automaton is branching.
        Returns False else.
        '''
        return len(self.get_branches()) > 0

    def is_executable(self) -> bool:
        '''
        Returns True if the automaton can progress beyond the init state.
        Returns False if the init state is disconnected.
        (essentially, this method checks if any other state is reachable
          beyond the init state.)
        '''
        if self.init is None:
            return False
        if len(self.init.out_trans) > 0:
            return True
        return False

    # + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + +
    # Other helpful methods
    #
    def __str__(self) -> str:
        s = "Automata.\n\n"
        if self.is_valid():
            for state in self.states:
                st_str = "  " + state.pretty_str(self.problem)
                s += st_str.replace("\n", "\n  ")
                s = s.strip() + "\n\n"
            declared_guards = []
            for trans in self.transitions:
                tr_str = "  " + str(trans)
                s += tr_str.replace("\n", "\n  ")
                s = s.strip() + "\n"
                conds: List = []
                get_list_of_conditional_values(trans.condition, conds)
                declared_guards.extend([cond for cond in conds
                                        if type(cond) is LabeledFormula])
                declared_guards = list({cond.name: cond
                                        for cond in declared_guards}.values())
            for guard in declared_guards:
                s += "\n{}".format(guard.pretty_str(self.problem))
        elif not self.is_executable():
            s += "Not executable.\n"
        else:
            s += "Unknown error.\n"

        if self.is_valid() and\
           (len(self.unsat_branch_points) > 0 or len(self.unsat_trans) > 0):
            s += "\nPartially satisfiable. " +\
                 "No paths to the following goals:\n\n"
            for unsat_s in self.unsat_branch_points:
                s += str(unsat_s)
            s += "\nNo paths to the following original transitions:\n\n"
            for unsat_t in self.unsat_trans:
                s += str(unsat_t) + "\n"
        return s


class PredicateKey:

    _instance = None
    key: ComponentIdentifier

    def __init__(self):
        PredicateKey._instance = self
        self.key = ComponentIdentifier(Predicate)

    @classmethod
    def instance(cls) -> PredicateKey:
        if cls._instance is None:
            PredicateKey()
            assert cls._instance is not None, \
                   "Error initializing predicate key."
        return cls._instance

    def set_predicate_id(self, predicate: Predicate, _id: int) -> None:
        self.key[predicate] = _id

    def get_predicate_id(self, predicate: Predicate) -> int:
        return self.key[predicate]

    def get_predicate_from_id(self, _id: int) -> FNode:
        return self.key[_id]

    def clear(self) -> None:
        self.key.clear()

    def __str__(self) -> str:
        return str(self.key)


class AutomataFactory:

    @classmethod
    def make(cls, problem: Problem, unsat=False) -> Automaton:
        return Automaton(problem, unsat)
