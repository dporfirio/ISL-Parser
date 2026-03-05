import argparse
import os
import islparser.parser.lexer_and_parser as aut_reader
import islparser.planner.classical as classical
from islparser.planner.plan_result import PlanResult
from islparser.parser.lexer_and_parser import (  # type: ignore[import-untyped]
    ParseResult,
    ParseResultStatus
)
from islparser.model.automata import Automaton, PredicateKey
from islparser.util.logger import Logger
from islparser.util.options import Options
from typing import List, cast


class TestOutput:

    parser: str
    planner: str

    def __init__(self, parse_out, plan_out="", distill_out="") -> None:
        self.parse_out = parse_out
        self.plan_out = plan_out
        self.distill_out = distill_out

    def print_parse_out(self) -> None:
        Logger.test("\n{}{}".format(
                    "Parser output\n",
                    "-------------------------------------------")
                    )
        Logger.test(self.parse_out)
        Logger.test("-------------------------------------------")

    def print_plan_out(self) -> None:
        Logger.test("\n{}{}".format(
                    "Planner output\n",
                    "-------------------------------------------")
                    )
        Logger.test(self.plan_out)
        Logger.test("-------------------------------------------")

    def print_distill_out(self) -> None:
        Logger.test("\n{}{}".format(
                    "Distiller output\n",
                    "-------------------------------------------")
                    )
        Logger.test(self.distill_out)
        Logger.test("-------------------------------------------")


def main(args) -> TestOutput:
    arg_file: str = args.file
    arg_task: List[str] = args.task
    arg_plan_dir: str = args.exec_dir
    arg_verbosity: str = args.verbosity
    arg_execute: bool = args.execute
    Logger.instance(arg_verbosity)

    # outputs
    parse_out: str = ""
    plan_out: str = ""
    distill_out: str = ""

    # parse
    Options.instance().clearopt()
    PredicateKey.instance().clear()
    parse_result: ParseResult = aut_reader.parse_file(arg_file)
    if parse_result.status == ParseResultStatus.SYNTAX_ERROR or\
       parse_result.status == ParseResultStatus.SEMANTIC_ERROR:
        out = TestOutput(parse_result.msg.strip())
        out.print_parse_out()
        return out
    elif parse_result.status == ParseResultStatus.WARNING:
        parse_out += parse_result.msg
    aut: Automaton = cast(Automaton, parse_result.automaton)

    # parser output
    str_aut = str(aut).strip()
    parse_out += str_aut

    # planner output
    curr_dir: str = os.getcwd()
    os.chdir(arg_plan_dir)
    pr: PlanResult | None = None
    classical._planner_cache.clear()
    if 'plan' in arg_task:
        pr = classical.plan(aut)
        if pr.sat:
            str_aut = str(pr.plan).strip()
            plan_out += str_aut

    if 'distill' in arg_task:
        try:
            # we cannot distill goals, so convert to plan if needed
            if aut.contains_goals():
                if pr is None:
                    pr = classical.plan(aut)
                chkpts = pr.checkpoints if pr.checkpoints is not None else []
                plan = Automaton(aut.problem)
                plan.add_init()
                classical.create_trace(plan, chkpts)
                plan.build()
                # Prune problem objects to only those used in the classical plan
                # Gather object names used in the plan actions
                used_objs = set()
                if pr is not None and getattr(pr, 'plan', None) is not None:
                    for st in pr.plan.states:
                        act = getattr(st, 'action', None)
                        # action actual parameters may be on the action wrapper
                        params = getattr(act, 'actual_parameters', None)
                        if params is None:
                            params = getattr(act, 'action', None)
                        if params is None:
                            continue
                        for p in params:
                            used_objs.add(p.object())
                for const in plan.problem.constants:
                    used_objs.add(plan.problem.get_object(const))

                # Remove unused objects
                plan.problem.rebuild_problem_pruning_objects(used_objs)
                aut = plan
            while True:
                pr = classical.distill(aut)
                if str(pr.plan) == distill_out:
                    break
                distill_out = str(pr.plan)
            distill_out = distill_out.strip()
        except classical.DistillerException:
            distill_out = "Distillation failed."
    os.chdir(curr_dir)

    # assemble result
    out = TestOutput(parse_out, plan_out, distill_out)
    out.print_parse_out()
    if len(plan_out) > 0:
        out.print_plan_out()
    if len(distill_out) > 0:
        out.print_distill_out()
    return out


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("file", nargs="?", default=None)
    parser.add_argument("-t", "--task",
                        help="ISL task: \'plan\', or \'distill\'",
                        type=str,
                        nargs='+',
                        default=['parse'])
    parser.add_argument("-d", "--exec_dir",
                        help="plan solver directory",
                        type=str,
                        default=".")
    parser.add_argument("-v", "--verbosity",
                        help="Set the level of information to \'silent\'," +
                             "\'test\', or \'debug\'",
                        type=str,
                        default='test')
    parser.add_argument("-e", "--execute",
                        help="Execute the plan",
                        action='store_true')
    args = parser.parse_args()
    if args.file is None and args.testcase is None:
        parser.print_usage()
    else:
        main(args)
