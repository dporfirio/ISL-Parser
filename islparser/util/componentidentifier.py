from typing import Any


class ComponentIdentifier(dict):

    t: type

    def __init__(self, t: type):
        self.t = t

    def __setitem__(self, key: Any, val: Any):
        assert (isinstance(key, int) and isinstance(val, self.t)) or \
               (isinstance(val, int) and isinstance(key, self.t)), \
               "Pair {}/{} not allowed in component identifier."\
               .format(type(key), type(val))
        assert not (key in self or val in self), \
               "Cannot overwrite existing component identifier."
        dict.__setitem__(self, key, val)
        dict.__setitem__(self, val, key)

    def __getitem__(self, key: Any) -> Any:
        assert isinstance(key, int) or isinstance(key, self.t), \
               "Type {} not allowed in component identifier.".format(type(key))

        if key in self:
            return dict.__getitem__(self, key)
        if isinstance(key, int):
            if key not in self:
                raise KeyError("ID {} is not recognized.".format(key))
        elif isinstance(key, self.t):
            if key not in self:
                highest_ID = 0 if len(self.keys()) == 0 \
                               else max([i for i in self.keys()
                                         if isinstance(i, int)])
                self.__setitem__(highest_ID + 1, key)
                return highest_ID + 1

    def __delitem__(self, key):
        dict.__delitem__(self, self[key])
        dict.__delitem__(self, key)

    def __len__(self):
        return int(dict.__len__(self) / 2)

    def __str__(self) -> str:
        s = ""
        for k, v in self.items():
            if isinstance(k, int):
                s += "{} - {}\n".format(k, v)
        return s
