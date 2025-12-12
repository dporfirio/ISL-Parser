from __future__ import annotations
from enum import Enum


def get_list_of_conditional_values(cond, lst):
    if type(cond) is Eq:
        lst.append(cond.val)


class Eq:

    def __init__(self, var, val):
        self.var = var
        self.val = val

    def __str__(self):
        return "[{}={}]".format(self.var, self.val)


class GoalSat(Enum):
    SUCCESS = 1
    FAILURE = 0

    @staticmethod
    def is_token(s: str) -> bool:
        return s == "SUCCESS" or s == "FAILURE"

    @staticmethod
    def get_goalsat(s: str) -> GoalSat:
        assert GoalSat.is_token(s), "Unrecognizable goal sat."
        if s == "SUCCESS":
            return GoalSat.SUCCESS
        else:
            return GoalSat.FAILURE


class GuardEnum(Enum):
    DEFAULT = 0

    @staticmethod
    def is_token(s: str) -> bool:
        return s == "default"

    @staticmethod
    def get_guardenum(s: str) -> GuardEnum:
        assert GuardEnum.is_token(s), "Unrecognizable guard."
        return GuardEnum.DEFAULT
