from __future__ import annotations
from typing import Dict


class Options:

    _instance = None
    _options: Dict[str, bool] = {}

    def __init__(self):
        Options._instance = self
        self.clearopt()

    @classmethod
    def instance(cls) -> Options:
        if cls._instance is None:
            Options()
            assert cls._instance is not None, \
                   "Error initializing Options."
        return cls._instance

    def setopt(self, opt: str, val: bool) -> None:
        self._options[opt] = val

    def getopt(self, opt) -> bool:
        return self._options[opt]

    def clearopt(self) -> None:
        self._options.clear()
        self._options = {
            "maintenance_goals": False,
            "uncertain_item_locations": False,
            "conditional_effects": False
        }
