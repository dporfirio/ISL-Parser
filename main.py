import argparse
import os
import parser.lexer_and_parser as aut_reader
from parser.lexer_and_parser import (  # type: ignore[import-untyped]
    ParseResult,
    ParseResultStatus
)
from model.automata import Automaton
from util.logger import Logger
from typing import cast


class TestOutput:

    parser: str
    planner: str

    def __init__(self, parse_out) -> None:
        self.parse_out = parse_out

    def print_parse_out(self) -> None:
        Logger.test("\n{}{}".format(
                    "Parser test output begins below this line.\n",
                    "-------------------------------------------")
                    )
        Logger.test(self.parse_out)
        Logger.test("-------------------------------------------")


def main(args) -> TestOutput:
    arg_test: str = args.testcase
    arg_verbosity: str = args.verbosity
    Logger.instance(arg_verbosity)

    # remove trailing slashes
    if len(arg_test) > 0 and arg_test[-1] == "/":
        arg_test = arg_test[:-1]

    # parse
    parse_out: str = ""
    assert os.path.isfile("{}/program.aut".format(arg_test)), "No such test case."
    parse_result: ParseResult = aut_reader.parse_file(arg_test)
    if parse_result.status == ParseResultStatus.ERROR:
        out = TestOutput(parse_result.msg.strip())
        out.print_parse_out()
        return out
    elif parse_result.status == ParseResultStatus.WARNING:
        parse_out += parse_result.msg
    aut: Automaton = cast(Automaton, parse_result.automaton)

    # parser output
    str_aut = str(aut).strip()
    parse_out += str_aut
    out = TestOutput(parse_out)
    out.print_parse_out()
    return out


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("-t", "--testcase",
                        help="parse a test case",
                        type=str)
    parser.add_argument("-v", "--verbosity",
                        help="Set the level of information to \'silent\'," +
                             "\'test\', or \'debug\'",
                        type=str,
                        default='test')
    args = parser.parse_args()
    if args.testcase is None:
        parser.print_usage()
    else:
        main(args)
