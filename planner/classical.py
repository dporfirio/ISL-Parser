from model.automata import Automaton
from model.state import Checkpoint, State, Predicate
from model.transition import Transition
from planner.plan_result import PlanResult
import unified_planning as up  # type: ignore
from unified_planning.shortcuts import (  # type: ignore
    OneshotPlanner,
    Fluent,
    FNode,
    BoolType,
    SequentialSimulator
)
from unified_planning.engines.compilers import (  # type: ignore
    Grounder,
    GrounderHelper
)
from typing import List


def get_planner_name(problem: up.model.Problem) -> str:
    planner_name: str = "fast-downward-opt"
    if problem.kind.has_conditional_effects():
        planner_name = "symk-opt"
    return planner_name


def create_trace(plan, chkpts) -> None:
    for i, cp in enumerate(chkpts):
        new_chkpt = State(i+1, cp.name)
        new_chkpt.action = cp.action
        plan.states.append(new_chkpt)
    for i, _ in enumerate(plan.states[1:]):
        trans: Transition = Transition(i, i+1)
        plan.transitions.append(trans)


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

    # declare and/or instantiate some variables
    plan: Automaton
    pr: PlanResult
    planner_name: str
    checkpoints: List[State] = []

    # add sequencing constraints
    if not aut.contains_goals():
        curr: Checkpoint = aut.init
        while len(curr.out_trans):
            curr = curr.out_trans[0].target
            name = curr.action.action.name
            params = [param for param in curr.action.actual_parameters]
            g: Grounder = Grounder()
            grounder_helper: GrounderHelper = GrounderHelper(
                problem, g._grounding_actions_map, g._prune_actions
            )
            new_act = grounder_helper.ground_action(curr.action.action, params)

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
        pr = PlanResult()
        planner_name = get_planner_name(problem)
        up.shortcuts.get_environment().credits_stream = None
        with OneshotPlanner(name=planner_name) as planner:
            result = planner.solve(aut.problem.problem)
            if len(result.plan.actions) == 0:
                return PlanResult.nosat()

            # Assemble the plan
            plan = Automaton(aut_orig.problem)
            plan.add_init()
            i: int = 0
            for act in result.plan.actions:
                name = act.action.name
                state: State
                if name.startswith("TEMP_"):
                    checkpoints.append(plan.states[-1])
                    continue
                elif "_" in name and name[:name.index("_")].isdigit():
                    _id: int = int(name[:name.index("_")])
                    state = aut.query_state_by_id(_id)
                    state._id = i + 1
                    i += 1
                else:
                    state = State(i + 1, "step_{}".format(i + 1))
                    state.action = act
                    i += 1
                plan.states.append(state)
    else:
        plan = Automaton(aut_orig.problem)
        plan.add_init()
        curr = aut.init
        while len(curr.out_trans):
            problem.clear_goals()
            curr = curr.out_trans[0].target
            for pred in curr.predicates:
                problem.add_goal(pred.fnode)
            planner_name = get_planner_name(problem)
            pr = PlanResult()
            up.shortcuts.get_environment().credits_stream = None
            with OneshotPlanner(name=planner_name) as planner:
                result = planner.solve(aut.problem.problem)
                if len(result.plan.actions) == 0:
                    return PlanResult.nosat()

                # update the initial state
                simulator = SequentialSimulator(problem)
                curr_st = simulator.get_initial_state()
                for st in result.plan.actions:
                    curr_st = simulator.apply(curr_st, st)
                curr_st._condense_state()
                aut.problem.replace_initial_state(curr_st._values)

                curr_plan_len: int = len(plan.states)
                for i, act in enumerate(result.plan.actions):
                    name = act.action.name
                    state: State
                    _id = i + curr_plan_len
                    if "_" in name and name[:name.index("_")].isdigit():
                        _id: int = int(name[:name.index("_")])
                        state = aut.query_state_by_id(_id)
                        state._id = _id
                    else:
                        state = State(_id, "step_{}".format(_id))
                        state.action = act
                    plan.states.append(state)
                state.name = curr.name
                checkpoints.append(state)

    for i, _ in enumerate(plan.states[1:]):
        trans: Transition = Transition(i, i+1)
        plan.transitions.append(trans)
    plan.build()
    pr.add_plan(plan)
    pr.add_checkpoints(checkpoints)

    return pr


def distill(aut: Automaton) -> PlanResult:
    """
    Checks aut for if plan can be distilled to its underlying checkpoints.
    If so, returns a goal automaton.
    """

    # Automata cannot be empty
    if not aut.is_executable():
        return PlanResult.nosat()

    # Distilled plans cannot be created if automaton loops
    if aut.contains_loops():
        return PlanResult.nosat()

    # TODO: extend to branching automaton
    if aut.contains_branches():
        return PlanResult.nosat()

    # Automata must have at least 2 non-init checkpoints
    if len(aut) < 3:
        pr: PlanResult = PlanResult()
        pr.add_plan(aut)
        return pr

    initial_st = aut.problem.problem.initial_values
    initial_chkpt = aut.init
    curr: State = aut.init.out_trans[0].target
    curr = curr.out_trans[0].target
    while True:
        # Set the initial and final states.
        # The final state must be the end effects of curr.
        temp_aut = Automaton(aut.problem.clone())
        temp_aut.problem.replace_initial_state(initial_st)
        temp_init: State = initial_chkpt.copy()
        temp_init.name = "temp_" + temp_init.name
        temp_aut.init = temp_init

        temp_curr: State = State(curr._id, curr.name, predicates=[])
        subs = {p: v for p, v in zip(curr.action.action.parameters, curr.action.actual_parameters)}
        for eff in curr.action.action.effects:
            f = eff.fluent
            v = eff.value
            if isinstance(f, FNode) and f.is_forall() or\
               isinstance(v, FNode) and v.is_forall():
                continue
            gf = eff.fluent.substitute(subs)        # grounded fluent
            gv = eff.value.substitute(subs)         # grounded assigned value
            if gv.is_true():
                temp_curr.predicates.append(Predicate(gf))

        temp_curr.name = "temp_" + temp_curr.name
        temp_trans: Transition = Transition(temp_init._id, temp_curr._id)
        temp_aut.states.append(temp_init)
        temp_aut.states.append(temp_curr)
        temp_aut.transitions.append(temp_trans)
        temp_aut.build()

        # plan and extract to a list
        pr: PlanResult = plan(temp_aut)
        plan_list: List[State] = []
        plan_curr = pr.plan.init
        while len(plan_curr.out_trans) > 0:
            plan_list.append(plan_curr)
            plan_curr = plan_curr.out_trans[0].target
        plan_list.reverse()
        plan_list_with_prev_st = [st for st in plan_list]

        # extract the original plan to a list
        orig_list: List[State] = []
        orig_curr = initial_chkpt
        while orig_curr != curr:
            orig_list.append(orig_curr)
            orig_curr = orig_curr.out_trans[0].target
        orig_list.reverse()

        # 1. remove as much as we can, starting from the final action and moving backwards
        # 2. stop removing when we get to an action that can't be removed
        # 3. actually do the removal
        # 4. if anything was removed, set init to the head and add another state
        # 5. else just add another state
        plan_idx = 0
        flagged_for_removal: List[State] = []
        for orig_st in orig_list:
            if orig_st == aut.init:
                continue
            found = False
            for i in range(plan_idx, len(plan_list_with_prev_st)):
                plan_st = plan_list_with_prev_st[i]
                if str(plan_st.action) == str(orig_st.action):
                    flagged_for_removal.append(orig_st)
                    plan_idx = i
                    found = True
                    break
            if not found:
                break

        # 3.
        for flagged in flagged_for_removal:
            source: State = flagged.in_trans[0].source
            target: State = flagged.out_trans[0].target
            new_trans: Transition = Transition(source._id, target._id)
            aut.states.remove(flagged)
            aut.transitions.remove(flagged.in_trans[0])
            aut.transitions.remove(flagged.out_trans[0])
            aut.transitions.append(new_trans)
            aut.build()

        # 4.
        if len(curr.out_trans) == 0:
            break
        elif len(flagged_for_removal) > 0:
            curr = curr.out_trans[0].target
            simulator = SequentialSimulator(temp_aut.problem.problem)
            curr_st = simulator.get_initial_state()
            plan_list.reverse()
            plan_list.append(plan_curr)
            for st in plan_list:
                if st.action is None:
                    continue
                curr_st = simulator.apply(curr_st, st.action)
            curr_st._condense_state()
            initial_st = curr_st._values
        # 5.
        else:
            curr = curr.out_trans[0].target

    pr = PlanResult()
    pr.plan = aut
    return pr
