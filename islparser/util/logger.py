from __future__ import annotations
from enum import IntEnum


class Logger:

    _instance = None
    _verbosity: Verbosity

    def __init__(self, verbosity):
        Logger._verbosity = Verbosity.get_verbosity(verbosity)
        Logger._instance = self

    @classmethod
    def instance(cls, verbosity) -> Logger:
        if cls._instance is None:
            Logger(verbosity)
        else:
            Logger._verbosity = Verbosity.get_verbosity(verbosity)
        return cls._instance

    @classmethod
    def test(cls, s) -> None:
        if Verbosity.TEST <= cls._verbosity:
            print(s)

    @classmethod
    def debug(cls, s) -> None:
        if Verbosity.DEBUG <= cls._verbosity:
            print(s)


class Verbosity(IntEnum):

    SILENT = 0
    TEST = 1
    DEBUG = 2

    @staticmethod
    def get_verbosity(s):
        assert s == "silent" or \
               s == "test" or \
               s == "debug", \
               "Verbosity must be \'silent\', \'test\', or \'debug\'."
        if s == "silent":
            return Verbosity.SILENT
        elif s == "test":
            return Verbosity.TEST
        else:
            return Verbosity.DEBUG
