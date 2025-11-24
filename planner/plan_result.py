from __future__ import annotations
from model.automata import Automaton
from typing import List


class PlanResult:

    sat: bool
    plan: Automaton | None
    checkpoints: List | None

    def __init__(self) -> None:
        self.sat = True
        self.plan = None

    @classmethod
    def nosat(cls) -> PlanResult:
        pr: PlanResult = PlanResult()
        pr.sat = False
        return pr

    def add_plan(self, plan: Automaton) -> None:
        self.plan = plan

    def add_checkpoints(self, checkpoints: List) -> None:
        self.checkpoints = checkpoints
