import argparse
import parser.lexer_and_parser as aut_reader
import planner.classical as classical
from planner.plan_result import PlanResult
from parser.lexer_and_parser import (  # type: ignore[import-untyped]
    ParseResult,
    ParseResultStatus
)
from model.automata import Automaton, PredicateKey
from util.logger import Logger
from util.options import Options
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
    arg_verbosity: str = args.verbosity
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
    pr: PlanResult
    if 'plan' in arg_task:
        pr = classical.plan(aut)
        if pr.sat:
            str_aut = str(pr.plan).strip()
            plan_out += str_aut

    if 'distill' in arg_task:
        while True:
            pr = classical.distill(aut)
            if str(pr.plan) == distill_out:
                break
            distill_out = str(pr.plan)
        distill_out = distill_out.strip()

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
    parser.add_argument("-v", "--verbosity",
                        help="Set the level of information to \'silent\'," +
                             "\'test\', or \'debug\'",
                        type=str,
                        default='test')
    args = parser.parse_args()
    if args.file is None and args.testcase is None:
        parser.print_usage()
    else:
        main(args)
