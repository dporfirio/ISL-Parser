import argparse
import json
import os
from pathlib import Path
import sys

if __package__ is None or __package__ == "":
    sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import islparser.parser.lexer_and_parser as aut_reader
import islparser.planner.classical as classical
from islparser.planner.simulate import Simulator
from islparser.planner.plan_result import PlanResult
from islparser.parser.lexer_and_parser import (  # type: ignore[import-untyped]
    ParseResult,
    ParseResultStatus
)
from islparser.model.automata import Automaton, PredicateKey
from islparser.util.logger import Logger
from islparser.util.options import Options
from typing import List, cast
from unified_planning.model.metrics import (  # type: ignore[import-untyped]
    MinimizeActionCosts,
)


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


def _normalize_token(token: str) -> str:
    return str(token or "").strip().lower()


def _extract_live_plan_payload(plan: Automaton) -> dict:
    detailed_plan = []

    for st in plan.states[1:]:
        act = getattr(st, "action", None)
        if act is None:
            continue

        action_obj = getattr(act, "action", None)
        action_name = getattr(action_obj, "name", str(action_obj))

        params = []
        raw_params = getattr(act, "actual_parameters", []) or []
        for p in raw_params:
            try:
                obj = p.object()
                params.append(_normalize_token(obj.name))
            except Exception:
                params.append(_normalize_token(str(p)))

        try:
            description = str(plan.problem.action_nl(act))
        except Exception:
            description = f"{action_name.upper()} {' '.join([x.upper() for x in params])}".strip()

        detailed_plan.append(
            {
                "id": getattr(st, "name", ""),
                "label": getattr(st, "name", ""),
                "action": _normalize_token(action_name),
                "params": params,
                "title": description,
            }
        )

    return {"planSteps": detailed_plan}


def _normalize_cost_key(name: str) -> str:
    return "".join(ch.lower() for ch in str(name or "") if ch.isalnum())


def _cost_key_aliases(name: str) -> set[str]:
    base = _normalize_cost_key(name)
    aliases = {base}
    aliases.add(base.replace("one", "1").replace("two", "2"))
    aliases.add(base.replace("1", "one").replace("2", "two"))
    return {alias for alias in aliases if alias}


def _apply_runtime_costs(aut: Automaton, costs: dict[str, int]) -> None:
    if not costs:
        return

    up_problem = aut.problem.problem
    normalized_costs = {_normalize_cost_key(key): value for key, value in costs.items()}
    action_costs = {}
    for action in up_problem.actions:
        chosen_cost = None
        for alias in _cost_key_aliases(action.name):
            if alias in normalized_costs:
                chosen_cost = normalized_costs[alias]
                break
        if chosen_cost is None:
            continue
        action_costs[action] = chosen_cost

    # Replace any parsed metric with a true action-cost metric.
    # This keeps the problem in the "action costs" family instead of the
    # broader numeric-fluent family that Fast Downward rejects here.
    up_problem.clear_quality_metrics()
    up_problem.add_quality_metric(MinimizeActionCosts(action_costs, default=0))


def _delegation_weight_costs_from_args(args) -> dict[str, int]:
    action_costs: dict[str, int] = {}

    def set_cost(action_names: list[str], value) -> None:
        if value is None:
            return
        for action_name in action_names:
            action_costs[action_name] = int(value)

    set_cost(["delegate_task"], args.delegate_cost)
    set_cost(["robot_move_from_reg_to", "robot_move_from_ent_to"], args.robot_move_cost)
    set_cost(["staff_move_from_reg_to", "staff_move_from_ent_to"], args.staff_move_cost)
    set_cost(["robot_deliver"], args.robot_deliver_cost)
    set_cost(["staff_grab"], args.staff_grab_cost)
    set_cost(["robot_receive"], args.robot_receive_cost)
    set_cost(["staff_deliver"], args.staff_deliver_cost)
    set_cost(["say"], args.say_cost)
    set_cost(["approach_from_region", "approach_from_entity"], args.approach_cost)
    return action_costs


def _runtime_costs_from_args(pddl_import: str | None, args) -> dict[str, int]:
    if pddl_import == "pddl.delegation_weight":
        return _delegation_weight_costs_from_args(args)
    return {}


def main(args) -> TestOutput:
    project_root = Path(__file__).resolve().parents[1]
    arg_file: str = args.file
    arg_task: List[str] = args.task
    arg_plan_dir: str = args.exec_dir
    arg_verbosity: str = args.verbosity
    arg_execute: bool = args.execute
    Logger.instance(arg_verbosity)

    if arg_file is not None and not os.path.isabs(arg_file):
        arg_file = str((project_root / arg_file).resolve())
    if not os.path.isabs(arg_plan_dir):
        arg_plan_dir = str((project_root / arg_plan_dir).resolve())

    # The ISL parser resolves imported PDDL paths like
    # "islparser/pddl/.../domain.pddl" relative to the current working
    # directory, so anchor execution at the ISL-Parser project root first.
    os.chdir(project_root)

    pddl_import, parsed_costs = aut_reader.parse_metadata_file(arg_file)

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
    effective_costs = dict(parsed_costs)
    if parse_result.costs:
        effective_costs.update(parse_result.costs)
    runtime_costs = _runtime_costs_from_args(parse_result.pddl_import, args)
    if runtime_costs:
        effective_costs.update(runtime_costs)
    _apply_runtime_costs(aut, effective_costs)

    # if execute, do only that
    if arg_execute:
        sim = Simulator()
        sim.simulate(aut)
        return TestOutput("Execution completed.")

    # parser output
    str_aut = str(aut).strip()
    parse_out += str_aut

    # planner output
    curr_dir: str = os.getcwd()
    os.chdir(arg_plan_dir)
    try:
        pr: PlanResult | None = None
        classical._planner_cache.clear()
        if 'plan' in arg_task:
            pr = classical.plan(aut)
            if pr.sat:
                str_aut = str(pr.plan).strip()
                plan_out += str_aut
                if pr.plan is not None:
                    live_payload = _extract_live_plan_payload(pr.plan)
                    Logger.test("LIVE_PLAN_JSON_START")
                    Logger.test(json.dumps(live_payload))
                    Logger.test("LIVE_PLAN_JSON_END")

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
    finally:
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
    parser.add_argument("--delegate-cost", type=int, default=None,
                        help="Runtime cost for delegate_task in pddl.delegation_weight.")
    parser.add_argument("--robot-move-cost", type=int, default=None,
                        help="Runtime cost for robot movement actions in pddl.delegation_weight.")
    parser.add_argument("--staff-move-cost", type=int, default=None,
                        help="Runtime cost for staff movement actions in pddl.delegation_weight.")
    parser.add_argument("--robot-deliver-cost", type=int, default=None,
                        help="Runtime cost for robot_deliver in pddl.delegation_weight.")
    parser.add_argument("--staff-grab-cost", type=int, default=None,
                        help="Runtime cost for staff_grab in pddl.delegation_weight.")
    parser.add_argument("--robot-receive-cost", type=int, default=None,
                        help="Runtime cost for robot_receive in pddl.delegation_weight.")
    parser.add_argument("--staff-deliver-cost", type=int, default=None,
                        help="Runtime cost for staff_deliver in pddl.delegation_weight.")
    parser.add_argument("--say-cost", type=int, default=None,
                        help="Runtime cost for say in pddl.delegation_weight.")
    parser.add_argument("--approach-cost", type=int, default=None,
                        help="Runtime cost for approach actions in pddl.delegation_weight.")
    args = parser.parse_args()
    if args.file is None:
        parser.print_usage()
    else:
        main(args)
