import re
from typing import Dict
from unified_planning.io import (  # type: ignore[import-untyped]
    PDDLReader as UPReader
)
from unified_planning.model.problem import (  # type: ignore[import-untyped]
    Problem
)


def parse_to_unified_planner(domain_filename: str,
                             problem_filename: str) -> Problem:
    """Create UP Problem Object and parse NL data from domain file"""
    reader = UPReader()
    return reader.parse_problem(domain_filename,
                                problem_filename)


def parse_pddl_comments(domain_filename: str,
                        pred_to_nl: Dict[str, str],
                        pred_to_internal: Dict[str, bool],
                        act_to_nl: Dict[str, str],
                        act_to_internal: Dict[str, bool]) -> None:
    """Parse NL data from domain file."""
    with open(domain_filename, "r") as infile:
        pred_flag = False
        for i, line in enumerate(infile):
            line = line.strip()
            if len(line) == 0:  # ignore empty lines
                continue
            if line[0] == ";":  # ignore full-line comments
                continue
            if ":predicates" in line:
                pred_flag = True
                continue
            if ":action" in line:
                pred_flag = False
            nl_regx = re.search(r";\s*NL", line)
            in_regx = re.search(r";\s*INTERNAL", line)
            regx = nl_regx if nl_regx is not None else in_regx
            if pred_flag and line[0] == "(":
                line = line.replace("(", "").replace(")", "")
                assert regx is not None, \
                       "Predicates must have a valid comment."
                pred_name = line.split()[0]
                pred_to_internal[pred_name] = False
                if nl_regx is not None:
                    pred_to_nl[pred_name] = line[regx.span()[1]:].strip()
                else:
                    pred_to_internal[pred_name] = True
            if ":action" in line:
                assert regx is not None, \
                       "Actions must have a valid comment."
                action_name = line.split()[1]
                act_to_internal[action_name] = False
                if nl_regx is not None:
                    act_to_nl[action_name] = line[regx.span()[1]+1:].strip()
                else:
                    act_to_internal[action_name] = True
