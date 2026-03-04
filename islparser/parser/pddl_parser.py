import re
from typing import List
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


def parse_pddl_constants(domain_filename: str) -> List[str]:
    """Parse constants from domain file."""
    constants: List[str] = []
    with open(domain_filename, "r") as infile:
        const_flag = False
        for i, line in enumerate(infile):
            line = line.strip()
            if len(line) == 0:  # ignore empty lines
                continue
            if line[0] == ";":  # ignore full-line comments
                continue
            if ":constants" in line:
                const_flag = True
                line = line.replace(":constants", "").strip()
            if const_flag:
                if ":" in line:  # end of constants section
                    const_flag = False
                    line = line.split(":")[0].strip()
                line = line.replace("(", "").replace(")", "")
                parts = line.split("-")
                if len(parts) < 2:
                    const_names = parts[0].strip().split()
                else:
                    const_names = parts[0].strip().split()
                for name in const_names:
                    constants.append(name.strip())
    return constants


def parse_pddl_comments(domain_filename: str,
                        problem) -> None:
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
            if ":functions" in line:
                pred_flag = False
                continue
            if "(:action" in line:
                pred_flag = False
            nl_regx = re.search(r";\s*NL", line)
            in_regx = re.search(r";\s*INTERNAL", line)
            regx = nl_regx if nl_regx is not None else in_regx
            if pred_flag and line[0] == "(":
                line = line.replace("(", "").replace(")", "")
                pred_name = line.split()[0]
                problem.predicate_to_internal[pred_name] = False
                if regx is None:
                    problem.predicate_to_nl[pred_name] =\
                        pred_name + " " +\
                        " ".join('[{}]'.format(i) for i in range(
                                problem.get_fluent(pred_name).arity))
                if nl_regx is not None:
                    problem.predicate_to_nl[pred_name] = line[nl_regx.span()[1]:].strip()
                else:
                    problem.predicate_to_internal[pred_name] = True
            if "(:action" in line:
                action_name = line.split()[1]
                problem.action_to_internal[action_name] = False
                if nl_regx is None:
                    problem.action_to_nl[action_name] =\
                        action_name + " " +\
                        " ".join('[{}]'.format(i) for i in range(
                                len(problem.get_action(action_name).parameters)))
                elif nl_regx is not None:
                    problem.action_to_nl[action_name] = line[nl_regx.span()[1]+1:].strip()
                else:
                    problem.action_to_internal[action_name] = True
