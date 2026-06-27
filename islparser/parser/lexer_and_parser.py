from __future__ import annotations
from enum import Enum
from typing import Tuple, List, Dict, Any
import unified_planning as up  # type: ignore[import-untyped]
from unified_planning.model.fnode import FNode  # type: ignore[import-untyped]
from unified_planning.model.object import Object  # type: ignore[import-untyped]
from ply.lex import lex  # type: ignore[import-untyped]
from ply.yacc import yacc  # type: ignore[import-untyped]
from islparser.model.isl_problem import (
    ISLProblemFactory,
    ISLProblem
)
from islparser.model.automata import (
    Automaton,
    AutomataFactory
)
from islparser.model.state import LabeledFormula, CheckpointFactory, Predicate
from islparser.model.transition import Transition
from islparser.model.conditionals import Eq, GoalSat, GuardEnum


class ParseResult:

    _instance: ParseResult | None = None
    automaton: Automaton | None
    status: ParseResultStatus
    msg: str

    @classmethod
    def instance(cls) -> ParseResult:
        if cls._instance is None:
            cls._instance = ParseResult()
        return cls._instance

    def build(self) -> None:
        if self.status == ParseResultStatus.SUCCESS and\
           self.automaton is not None:
            self.automaton.build()

    def reset(self) -> None:
        self.status = ParseResultStatus.SUCCESS
        self.msg = ""
        self.automaton = None

    # Common parser errors below
    def add_obj_not_found_error(self, name, lineno) -> None:
        self.status = ParseResultStatus.SYNTAX_ERROR
        self.msg += "line {}: ".format(lineno) + \
                    "no such object named {}\n".format(name)


class ParseResultStatus(Enum):

    SUCCESS = 0
    WARNING = 1
    SYNTAX_ERROR = 2
    SEMANTIC_ERROR = 3


tokens = (
    'IMPORT',
    'DOT',
    'LABELS',
    'ENDLABELS',
    'MODULE',
    'ENDMODULE',
    'OPTIONS',
    'ENDOPTIONS',
    'ACTION',
    'PREDICATE',
    'PARAMS',
    'ST',
    'GUARD',
    'INIT',
    'INT',
    'ID',
    'AND',
    'NOT',
    'EQUAL',
    'COLON',
    'SEMICOLON',
    'OPENLIST',
    'CLOSELIST',
    'COMMA',
    'ARROW',
)

t_ignore = ' \t'

reserved = {
    'import': 'IMPORT',
    'labels': 'LABELS',
    'not': 'NOT',
    'action': 'ACTION',
    'predicate': 'PREDICATE',
    'params': 'PARAMS',
    'endlabels': 'ENDLABELS',
    'module': 'MODULE',
    'st': 'ST',
    'guard': 'GUARD',
    'init': 'INIT',
    'endmodule': 'ENDMODULE',
    'options': 'OPTIONS',
    'endoptions': 'ENDOPTIONS',
}

t_ARROW = r'->'
t_COLON = r':'
t_SEMICOLON = r';'
t_OPENLIST = r'\['
t_CLOSELIST = r'\]'
t_COMMA = r','
t_AND = r'&'
t_EQUAL = r'='
t_DOT = r'\.'


def _node(tag: str, *children: Any) -> Tuple[Any, ...]:
    return (tag, *children)


def _assignment_node(p) -> Tuple | None:
    if len(p) == 4:
        return _node('assg', p[1], p[3])
    if len(p) == 6:
        return _node('assgs', p[1], p[3], p[5])
    return p[1]


def t_NEWLINE(t):
    r'\n'
    t.lexer.lineno += 1


def t_ID(t):
    r'[a-zA-Z_][a-zA-Z_0-9]*'
    t.type = reserved.get(t.value, 'ID')
    return t


def t_COMMENT(t):
    r'\#.*\n'
    t.lexer.lineno += 1


def t_INT(t):
    r'\d+'
    t.value = int(t.value)
    return t


def t_error(t):
    print('line {}: Illegal character {}'.format(t.lineno, t.value[0]))
    t.lexer.skip(1)


def p_program(p):
    """
    program : import labels module options
    """
    p[0] = _node('program', p[1], p[2], p[3])


def p_nil(p):
    """
    nil :
    """
    pass


def p_import(p):
    """
    import : IMPORT path
    """
    p[0] = p[2]


def p_path(p):
    """
    path : ID path
         | DOT path
         | nil
    """
    if len(p) == 3:
        p[0] = p[1] + (p[2] or "")


def p_labels(p):
    """
    labels : LABELS labellist ENDLABELS
    """
    p[0] = None if p[2] is None else _node('labellist', p[2])


def p_module(p):
    """
    module : MODULE automata ENDMODULE
    """
    p[0] = p[2]


def p_options(p):
    """
    options : OPTIONS ENDOPTIONS
            | nil
    """
    pass


def p_labellist(p):
    """
    labellist : label
              | label COMMA labellist
              | nil
    """
    if len(p) == 2:
        p[0] = None if p[1] is None else _node('label', p[1])
    else:
        p[0] = _node('labels', p[1], p[3])


def p_label(p):
    """
    label : ID COLON OPENLIST act_or_pred_list CLOSELIST
    """
    p[0] = _node('act_or_pred_list', p[1], p[4])


def p_act_or_pred_list(p):
    """
    act_or_pred_list : act_or_pred
                     | act_or_pred AND act_or_pred_list
    """
    if len(p) == 2:
        p[0] = _node('act_or_pred', p[1])
    else:
        p[0] = _node('act_or_preds', p[1], p[3])


def p_act_or_pred(p):
    """
    act_or_pred : ACTION COLON ID COMMA PARAMS COLON OPENLIST param_dec CLOSELIST
                | PREDICATE COLON ID COMMA PARAMS COLON OPENLIST param_dec CLOSELIST
                | PREDICATE COLON NOT ID COMMA PARAMS COLON OPENLIST param_dec CLOSELIST
                | nil
    """
    if p[1] in ('action', 'predicate'):
        p[0] = _node(p[1], p[3], p[8])


def p_param_dec(p):
    """
    param_dec : ID
              | ID COMMA param_dec
              | nil
    """
    if len(p) == 2:
        p[0] = _node('param', p[1])
    else:
        p[0] = _node('params', p[1], p[3])


def p_automata(p):
    """
    automata : state_dec_wrapper cond_dec_wrapper trel
             | state_dec_wrapper trel
             | nil
    """
    if len(p) == 4:
        p[0] = _node('automata', p[1], p[2], p[3])
    elif len(p) == 3:
        p[0] = _node('automata', p[1], None, p[2])
    else:
        p[0] = p[1]


def p_cond_dec_wrapper(p):
    """
    cond_dec_wrapper : GUARD COLON OPENLIST cond_dec CLOSELIST SEMICOLON
    """
    p[0] = _node('cond_dec', p[4])


def p_cond_dec(p):
    """
    cond_dec : INT COLON ID
             | INT COLON INIT
             | INT COLON ID COMMA cond_dec
             | INT COLON INIT COMMA cond_dec
             | nil
    """
    p[0] = _assignment_node(p)


def p_state_dec_wrapper(p):
    """
    state_dec_wrapper : ST COLON OPENLIST state_dec CLOSELIST SEMICOLON
    """
    p[0] = _node('state_dec', p[4])


def p_state_dec(p):
    """
    state_dec : INT COLON ID
              | INT COLON INIT
              | INT COLON ID COMMA state_dec
              | INT COLON INIT COMMA state_dec
              | nil
    """
    p[0] = _assignment_node(p)


def p_trel(p):
    """
    trel : event boolexp ARROW INT SEMICOLON trel
         | nil
    """
    if len(p) == 7:
        if p[6] is None:
            p[0] = _node('trel', p[1], p[2], p[4])
        else:
            p[0] = _node('trels', p[1], p[2], p[4], p[6])
    else:
        p[0] = p[1]


def p_event(p):
    """
    event : OPENLIST CLOSELIST
          | OPENLIST ID CLOSELIST
    """
    p[0] = _node('event', None if len(p) == 3 else p[2])


def p_boolexp_wrapper(p):
    """
    boolexp : INT AND GUARD EQUAL ID
            | INT AND GUARD EQUAL INT
            | INT
    """
    if len(p) == 6:
        p[0] = (Eq('st', p[1]), p[5])
    else:
        p[0] = (Eq('st', p[1]),)


def p_error(p):
    ParseResult.instance().status = ParseResultStatus.SYNTAX_ERROR
    ParseResult.instance().msg += "syntax error line {}: ".format(p.lineno) +\
                                  "Unexpected token \'{}\'\n".format(p.value)


def parse_file(aut_filename: str) -> ParseResult:
    with open(aut_filename) as infile:
        return parse_string(infile.read())


def parse_string(to_parse: str) -> ParseResult:
    lexer = lex()
    lexer.input(to_parse)
    parser = yacc()
    ParseResult.instance().reset()
    ast = parser.parse(to_parse, tracking=True)
    parse_result: ParseResult = parse_program(ast)
    if parse_result.status == ParseResultStatus.SUCCESS:
        parse_result.build()
    return parse_result


def parse_program(ast: Tuple) -> ParseResult:
    if ast is None:
        return ParseResult.instance()
    assert ast[0] == 'program', "AST error at root."
    _, pddl_import, label_list_ast, automata_ast = ast
    labeled_formulae: List[LabeledFormula] = []
    problem: ISLProblem = ISLProblemFactory.make()
    pddl_path: str = pddl_import.replace(".", "/")
    problem.add_pddl("islparser/{}/domain.pddl".format(pddl_path),
                     "islparser/{}/problem.pddl".format(pddl_path))
    automaton = AutomataFactory.make(problem)
    automaton.initialize()
    ParseResult.instance().automaton = automaton
    if label_list_ast is not None:
        parse_label_list(label_list_ast, labeled_formulae, automaton)
    if automata_ast is not None:
        parse_automata(automata_ast, labeled_formulae, automaton)
    return ParseResult.instance()


def expect_ast(ast: Tuple, *tags: str, context: str = "AST") -> None:
    assert ast[0] in tags, "{} error at {}.".format(context, "/".join(tags))


def find_label(name: str,
               labeled_formulae: List[LabeledFormula]) -> LabeledFormula | None:
    candidates: List[LabeledFormula] = [lf for lf in labeled_formulae
                                        if lf.name == name]
    if len(candidates) == 0:
        throw_semantic_error("no such label \'{}\'".format(name))
        return None
    if len(candidates) > 1:
        throw_semantic_error("more than one label with name \'{}\'".format(name))
        return None
    return candidates[0]


def parse_label_list(ast: Tuple,
                     labeled_formulae: List[LabeledFormula],
                     automaton: Automaton) -> None:
    expect_ast(ast, 'labellist', context="AST")
    parse_labels(ast[1], labeled_formulae, automaton)


def parse_labels(ast: Tuple,
                 labeled_formulae: List[LabeledFormula],
                 automaton: Automaton) -> None:
    while ast is not None:
        expect_ast(ast, 'label', 'labels', context="AST")
        parse_label(ast[1], labeled_formulae, automaton)
        ast = ast[2] if ast[0] == 'labels' else None


def parse_label(ast: Tuple,
                labeled_formulae: List[LabeledFormula],
                automaton: Automaton) -> None:
    name = ast[1]
    predicates: List[Predicate] = []
    actions: List[up.plans.ActionInstance] = []
    parse_act_or_preds(ast[2], predicates, automaton, actions)
    if len(actions) > 1:
        throw_semantic_error("label \'{}\' has >1 action".format(name))
    action = actions[0] if len(actions) > 0 else None
    labeled_formulae.append(LabeledFormula(name, predicates, action))


def parse_act_or_preds(ast: Tuple,
                       predicates: List[Predicate],
                       automaton: Automaton,
                       actions: List[up.plans.ActionInstance]) -> None:
    while ast is not None:
        header, label_data = ast[0], ast[1]
        if label_data is None:
            return
        _type, name, params_ast = label_data
        assert _type in ("predicate", "action"), \
               "Goal automata must be composed of actions and predicates."
        params = parse_params(params_ast, automaton)
        if _type == "predicate":
            fluent = automaton.problem.get_fluent(name)
            if fluent is None:
                throw_semantic_error("no such predicate: \'{}\'".format(name))
                return
            predicate = Predicate(fluent(*params))
            automaton.get_predicate_id(predicate)  # adds a new mapping
            predicates.append(predicate)
        else:
            action = automaton.problem.get_action(name)
            if action is None:
                throw_semantic_error("no such action: \'{}\'".format(name))
                return
            actions.append(up.plans.ActionInstance(action, params))
        ast = ast[2] if header == "act_or_preds" else None


def parse_params(ast: Tuple,
                 automaton: Automaton) -> List[FNode]:
    params: List[FNode] = []
    while ast is not None:
        expect_ast(ast, 'param', 'params', context="AST")
        name = ast[1]
        if name is None:
            break
        param: Object = automaton.problem.get_object(name)
        if param is None:
            throw_semantic_error("no such entity: \'{}\'".format(name))
            break
        params.append(param)
        ast = ast[2] if ast[0] == "params" else None
    return params


def parse_automata(ast: Tuple,
                   labeled_formulae: List[LabeledFormula],
                   automaton: Automaton) -> None:
    expect_ast(ast, 'automata', context="AST")
    id_to_guard: Dict[str, Any] = {}
    state_dec_ast = ast[1]
    if state_dec_ast is not None:
        parse_state_dec(state_dec_ast, labeled_formulae, automaton)
    cond_dec_ast = ast[2]
    if cond_dec_ast is not None:
        parse_cond_dec(cond_dec_ast, labeled_formulae, id_to_guard, automaton)
    trel_ast = ast[3]
    if trel_ast is not None:
        parse_trel(trel_ast, id_to_guard, automaton)


def parse_cond_dec(ast: Tuple,
                   labeled_formulae: List[LabeledFormula],
                   id_to_guard: Dict[str, Any],
                   automaton: Automaton) -> None:
    expect_ast(ast, 'cond_dec', context="AST")
    assg_ast = ast[1]
    if assg_ast is not None:
        parse_cond_assg(assg_ast, labeled_formulae, id_to_guard, automaton)


def parse_cond_assg(ast: Tuple,
                    labeled_formulae: List[LabeledFormula],
                    id_to_guard: Dict[str, Any],
                    automaton: Automaton) -> None:
    while ast is not None:
        expect_ast(ast, 'assg', 'assgs', context="AST")
        _id, name = ast[1], ast[2]
        if _id in id_to_guard:
            throw_semantic_error("duplicate guard \'{}\'".format(_id))
            return
        if GoalSat.is_token(name):
            id_to_guard[_id] = GoalSat.get_goalsat(name)
        elif GuardEnum.is_token(name):
            id_to_guard[_id] = GuardEnum.get_guardenum(name)
        else:
            lf = find_label(name, labeled_formulae)
            if lf is None:
                return
            id_to_guard[_id] = lf.copy()
        ast = ast[3] if ast[0] == 'assgs' else None


def parse_state_dec(ast: Tuple,
                    labeled_formulae: List[LabeledFormula],
                    automaton: Automaton) -> None:
    expect_ast(ast, 'state_dec', context="AST")
    assg_ast = ast[1]
    if assg_ast is not None:
        parse_assg(assg_ast, labeled_formulae, automaton)
    if automaton.init is None:
        throw_semantic_error("missing 'init' state")
        return


def parse_assg(ast: Tuple,
               labeled_formulae: List[LabeledFormula],
               automaton: Automaton) -> None:
    while ast is not None:
        expect_ast(ast, 'assg', 'assgs', context="AST")
        _id, name = ast[1], ast[2]
        if name == "init":
            if automaton.init is not None:
                throw_semantic_error("module contains more than one \'init\'")
                return
            automaton.add_init()
        else:
            if _id in [state._id for state in automaton.states]:
                throw_semantic_error("duplicate state \'{}\'".format(_id))
            lf = find_label(name, labeled_formulae)
            if lf is None:
                return
            state = CheckpointFactory.make(_id=_id,
                                           name=name,
                                           predicates=lf.predicates,
                                           action=lf.action)
            automaton.states.append(state)
        ast = ast[3] if ast[0] == 'assgs' else None


def parse_trel(ast: Tuple,
               id_to_guard: Dict[str, Any],
               automaton: Automaton) -> None:
    while ast is not None:
        st1, cond = parse_bool_exp(ast[2], id_to_guard)
        st2 = Eq('st', ast[3])
        automaton.transitions.append(Transition(st1.val, st2.val, None, cond))
        ast = ast[4] if ast[0] == 'trels' else None


def parse_bool_exp(ast: Tuple,
                   id_to_guard: Dict[str, Any]) -> Tuple[Eq, Eq | None]:
    st: Eq = ast[0]
    if len(ast) == 1:
        return st, None
    return st, Eq('guard', parse_guard_value(ast[1], id_to_guard))


def parse_guard_value(value: str | int, id_to_guard: Dict[str, Any]) -> Any:
    if isinstance(value, str):
        if GoalSat.is_token(value):
            return GoalSat.get_goalsat(value)
        if GuardEnum.is_token(value):
            return GuardEnum.get_guardenum(value)
        return GuardEnum.DEFAULT
    if value not in id_to_guard:
        throw_semantic_error("guard \'{}\' not assigned".format(value))
        return GuardEnum.DEFAULT
    return id_to_guard[value]


def throw_semantic_error(msg: str) -> None:
    ParseResult.instance().status = ParseResultStatus.SEMANTIC_ERROR
    ParseResult.instance().msg += "parser error: " + msg + "\n"
