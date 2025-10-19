from model.automata import Automaton
from model.state import Checkpoint, State
from model.transition import Transition
from planner.plan_result import PlanResult
import unified_planning as up  # type: ignore
from unified_planning.shortcuts import (  # type: ignore
    OneshotPlanner,
    Fluent,
    BoolType,
    InstantaneousAction,
    SequentialSimulator
)
from unified_planning.model.problem_kind import ProblemKind
from unified_planning.engines import CompilationKind  # type: ignore
from unified_planning.engines.compilers import Grounder  # type: ignore
from typing import List


def plan(aut: Automaton) -> PlanResult:
    """
    Checks aut for if plan can be created.
    If so, returns a plan.
    """

    # Automata cannot be empty
    if not aut.is_executable():
        return PlanResult.nosat()

    # Classical plans cannot be created if automaton loops
    if aut.contains_loops():
        return PlanResult.nosat()

    # TODO: extend to branching automaton
    if aut.contains_branches():
        return PlanResult.nosat()

    # TODO: extend to dealing with goals
    if aut.contains_goals():
        return PlanResult.nosat()

    # add a sequencing fluent
    # TODO: this needs to be copied. We need an aut copy function
    # aut_temp = aut.copy()  # this will also copy the problem
    # then set aut_temp.problem to be the original problem
    aut_orig = aut
    aut = aut.copy()
    problem = aut.problem.problem
    curr_step = 0
    step = Fluent("step_{}".format(curr_step), BoolType())
    problem.add_fluent(step)
    problem.set_initial_value(step, True)

    # the PDDL file may have contained a goal we need to remove
    problem.clear_goals()

    # get all ground actions
    with Grounder() as grounder:
        cres = grounder.compile(problem, CompilationKind.GROUNDING)
        grounded_problem = cres.problem  # all possible grounded actions

    # add sequencing constraints
    curr: Checkpoint = aut.init
    while len(curr.out_trans):
        curr = curr.out_trans[0].target
        if curr.action is None:
            continue
        name = curr.action.action.name
        params = [param.object().name
                  for param in curr.action.actual_parameters]

        # find the ground action that matches the aut action
        new_act: InstantaneousAction = None
        for act in grounded_problem.actions:
            if len(name) <= len(act.name) and act.name[:len(name)] == name:
                candidate_param_str = act.name[len(name)+1:]
                candidate_params = candidate_param_str.split("_")
                if candidate_params == params:
                    new_act = act
                    break

        # TODO: add error messages
        if new_act is None:
            return PlanResult.nosat()

        # setup the new action
        new_act.name = str(curr._id) + "_" + new_act.name
        new_act.add_precondition(step)
        new_act.add_effect(step, False)
        curr_step += 1
        step = Fluent("step_{}".format(curr_step), BoolType())
        new_act.add_effect(step, True)
        problem.add_fluent(step)
        problem.add_action(new_act)

    # the goal is for the plan to achieve the final step
    problem.add_goal(step)

    # invoke the planner
    planner_name: str = "fast-downward-opt"
    pk: ProblemKind = aut.problem.problem.kind
    if 'CONDITIONAL_EFFECTS' in pk.features or\
       'FORALL_EFFECTS' in pk.features:
        planner_name = "fast-downward"
    pr: PlanResult = PlanResult()
    up.shortcuts.get_environment().credits_stream = None
    with OneshotPlanner(name=planner_name) as planner:
        result = planner.solve(aut.problem.problem)
        if len(result.plan.actions) == 0:
            return PlanResult.nosat()

        # Assemble the plan
        plan = Automaton(aut_orig.problem)
        plan.add_init()
        for i, act in enumerate(result.plan.actions):
            name = act.action.name
            state: State
            if "_" in name and name[:name.index("_")].isdigit():
                _id: int = int(name[:name.index("_")])
                state = aut.query_state_by_id(_id)
                state._id = i + 1
            else:
                state = State(i + 1, "step_{}".format(i + 1))
                state.action = act
            plan.states.append(state)
        for i, _ in enumerate(plan.states[1:]):
            trans: Transition = Transition(i, i+1)
            plan.transitions.append(trans)
        plan.build()
        pr.add_plan(plan)

    return pr
