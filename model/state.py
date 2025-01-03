from __future__ import annotations
import copy
from typing import (
    List,
    Dict,
    Any
)
from unified_planning.model import (  # type: ignore[import-untyped]
    FNode,
    Problem,
    Fluent
)
from unified_planning.plans import (  # type: ignore[import-untyped]
    ActionInstance
)
import model.transition as transition


class LabeledFormula:
    '''
    A labeled formula is a conjunction of one or more ground predicates.
    An atomic proposition may be positive or negated.
    '''

    def __init__(self,
                 name,
                 predicates: List[Predicate] = [],
                 action: ActionInstance = None) -> None:
        self.name = name
        self.predicates = predicates
        self.action = action

    def copy(self) -> LabeledFormula:
        '''
        Create a deep-copied version of this LabeledFormula object.
        '''
        return LabeledFormula(self.name,
                              copy.copy(self.predicates),
                              self.action)

    def pretty_stringify_params(self,
                                domain: Problem,
                                s: str,
                                predicates: List[Predicate],
                                negate: bool = False) -> str:
        if self.action is not None:
            nl = domain.action_nl(self.action)
            if nl is not None:
                s += "  -->  " + nl
            else:
                s += "  " + self.action.short_str().replace("\n", "\n  ")
        for i, fnode in enumerate(predicates):
            s += domain.predicate_nl(fnode) +\
                 ("\n" if i < len(predicates) - 1 else "")
        return s

    def pretty_str(self, problem: Problem) -> str:
        s = "labeled formula \"{}\":\n".format(self.name)
        s = self.pretty_stringify_params(problem, s, self.predicates)
        return s.strip() + "\n"

    def __str__(self) -> str:
        return self.name


class State(LabeledFormula):
    '''
    A state can be thought of as a unique labeled formula that
    describes a goal for the robot to achieve.

    States extend labeled formulae.
    In contrast to a labeled formula, states are unique and
    cannot be duplicated. Each state thus has a unique ID.
    '''
    _id: int

    # built fields
    in_trans: List[transition.Transition]
    out_trans: List[transition.Transition]

    # optional stored fields
    final_state:  Dict[FNode, Any] | None
    is_action: bool

    def __init__(self,
                 _id: int,
                 name: str,
                 predicates: List[Predicate] = [],
                 action: ActionInstance = None):
        super().__init__(name, predicates, action)
        self._id = _id

        # built fields
        self.in_trans = []
        self.out_trans = []

        # OPTIONAL stored fields
        self.final_state = None
        self.is_action = True


class Checkpoint(State):
    '''
    A checkpoint is a user-defined state.
    '''

    def __init___(self,
                  _id: int,
                  name: str,
                  predicates: List[FNode] = [],
                  action: ActionInstance = None):
        super().__init__(_id, name, predicates, action)

    def copy(self) -> State:
        '''
        Create a new deep-copied version of this Checkpoint object.
        '''
        return CheckpointFactory.make(_id=self._id,
                                      name=self.name,
                                      predicates=copy.copy(self.predicates),
                                      action=self.action)

    def pretty_str(self, domain: Problem) -> str:
        s = "checkpoint {} ({}):\n".format(self._id, self.name)
        s = self.pretty_stringify_params(domain, s, self.predicates)
        return s.strip() + "\n"

    def __str__(self) -> str:
        s = "checkpoint {} ({}):\n".format(self._id, self.name)
        s = self.stringify_params(s, self.predicates)
        return s.strip() + "\n"


class StateFactory:

    @classmethod
    def make(cls, **kwargs) -> State:
        return State(kwargs["_id"],
                     kwargs["name"],
                     kwargs["predicates"],
                     kwargs["action"])


class CheckpointFactory:

    @classmethod
    def make(cls, **kwargs) -> State:
        return Checkpoint(kwargs["_id"],
                          kwargs["name"],
                          kwargs["predicates"],
                          kwargs["action"])


class Predicate:
    fnode: FNode

    def __init__(self, fnode: FNode):
        self.fnode = fnode

