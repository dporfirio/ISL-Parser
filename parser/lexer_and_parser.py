from __future__ import annotations
from enum import Enum
from typing import Tuple, List, Dict, Any
import unified_planning as up  # type: ignore[import-untyped]
from unified_planning.model.fnode import FNode  # type: ignore[import-untyped]
from unified_planning.model.object import Object  # type: ignore[import-untyped]
from ply.lex import lex  # type: ignore[import-untyped]
from ply.yacc import yacc  # type: ignore[import-untyped]
from model.isl_problem import (
    ISLProblemFactory,
    ISLProblem
)
from model.automata import (
    Automaton,
    AutomataFactory
)
from model.state import LabeledFormula, CheckpointFactory, Predicate
from model.transition import Transition
from model.conditionals import Eq, GoalSat, GuardEnum
from util.options import Options


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


tokens = ('IMPORT', 'DOT',
          'LABELS', 'ENDLABELS',
          'MODULE', 'ENDMODULE',
          'OPTIONS', 'ENDOPTIONS',
          'OPTCONDEFFECTS',
          'ACTION', 'PREDICATE', 'PARAMS',
          'ST', 'GUARD', 'INIT',
          'INT', 'ID',
          'AND', 'NOT',
          'EQUAL',
          'COLON', 'SEMICOLON', 'OPENLIST', 'CLOSELIST', 'COMMA', 'ARROW',
          )

t_ignore = ' \t'

reserved = {
    'import': "IMPORT",
    'labels': "LABELS",
    'not': "NOT",
    'action': "ACTION",
    'predicate': "PREDICATE",
    'params': "PARAMS",
    'endlabels': "ENDLABELS",
    'module': "MODULE",
    'st': "ST",
    'guard': "GUARD",
    'init': "INIT",
    'endmodule': "ENDMODULE",
    'options': 'OPTIONS',
    'conditional_effects': 'OPTCONDEFFECTS',  # planner allows condit. effects
    'endoptions': 'ENDOPTIONS'
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


def t_NEWLINE(t):
    r'\n'
    t.lexer.lineno += 1


def t_ID(t):
    r'[a-zA-Z_][a-zA-Z_0-9]*'
    if t.value in reserved:
        t.type = reserved.get(t.value, 'ID')  # Check for reserved words
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
    '''
    program : import labels module options
    '''
    p[0] = ('program', p[1], p[2], p[3])


def p_nil(p):
    '''
    nil :
    '''
    pass


def p_import(p):
    '''
    import : IMPORT path
    '''
    p[0] = p[2]


def p_path(p):
    '''
    path : ID path
         | DOT path
         | nil
    '''
    if len(p) == 3:
        p[0] = p[1] + (p[2] if p[2] is not None else "")


def p_labels(p):
    '''
    labels : LABELS labellist ENDLABELS
    '''
    if p[2] is None:
        p[0] = p[2]
    else:
        p[0] = ('labellist', p[2])


def p_module(p):
    '''
    module : MODULE automata ENDMODULE
    '''
    p[0] = p[2]


def p_options(p):
    '''
    options : OPTIONS optionlist ENDOPTIONS
            | OPTIONS ENDOPTIONS
            | nil
    '''
    pass


def p_optionlist(p):
    '''
    optionlist : option
               | option optionlist
    '''
    pass


def p_option(p):
    '''
    option : OPTCONDEFFECTS SEMICOLON
    '''
    Options.instance().setopt(p[1], True)


def p_labellist(p):
    '''
    labellist : label
              | label COMMA labellist
              | nil
    '''
    if len(p) == 2:
        if p[1] is None:
            p[0] = p[1]
        else:
            p[0] = ('label', p[1])
    else:
        p[0] = ('labels', p[1], p[3])


def p_label(p):
    '''
    label : ID COLON OPENLIST act_or_pred_list CLOSELIST
    '''
    p[0] = ('act_or_pred_list', p[1], p[4])


def p_act_or_pred_list(p):
    '''
    act_or_pred_list : act_or_pred
                     | act_or_pred AND act_or_pred_list
    '''
    if len(p) == 2:
        p[0] = ('act_or_pred', p[1])
    else:
        p[0] = ('act_or_preds', p[1], p[3])


def p_act_or_pred(p):
    '''
    act_or_pred : ACTION COLON ID COMMA PARAMS COLON OPENLIST param_dec CLOSELIST
                | PREDICATE COLON ID COMMA PARAMS COLON OPENLIST param_dec CLOSELIST
                | PREDICATE COLON NOT ID COMMA PARAMS COLON OPENLIST param_dec CLOSELIST
                | nil
    '''
    if p[1] == "action":
        p[0] = ('action', p[3], p[8])
    elif p[1] == "predicate":
        p[0] = ('predicate', p[3], p[8])
    else:
        p[0] = None


def p_param_dec(p):
    '''
    param_dec : ID
              | ID COMMA param_dec
              | nil
    '''
    if len(p) == 2:
        p[0] = ('param', p[1])
    else:
        p[0] = ('params', p[1], p[3])


def p_automata(p):
    '''
    automata : state_dec_wrapper cond_dec_wrapper trel
             | state_dec_wrapper trel
             | nil
    '''
    if len(p) == 4:
        p[0] = ('automata', p[1], p[2], p[3])
    elif len(p) == 3:
        p[0] = ('automata', p[1], None, p[2])
    else:
        p[0] = p[1]


def p_cond_dec_wrapper(p):
    '''
    cond_dec_wrapper : GUARD COLON OPENLIST cond_dec CLOSELIST SEMICOLON
    '''
    p[0] = ('cond_dec', p[4])


def p_cond_dec(p):
    '''
    cond_dec : INT COLON ID
             | INT COLON INIT
             | INT COLON ID COMMA cond_dec
             | INT COLON INIT COMMA cond_dec
             | nil
    '''
    if len(p) == 4:
        p[0] = ('assg', p[1], p[3])
    elif len(p) == 6:
        p[0] = ('assgs', p[1], p[3], p[5])
    else:
        p[0] = p[1]


def p_state_dec_wrapper(p):
    '''
    state_dec_wrapper : ST COLON OPENLIST state_dec CLOSELIST SEMICOLON
    '''
    p[0] = ('state_dec', p[4])


def p_state_dec(p):
    '''
    state_dec : INT COLON ID
              | INT COLON INIT
              | INT COLON ID COMMA state_dec
              | INT COLON INIT COMMA state_dec
              | nil
    '''
    if len(p) == 4:
        p[0] = ('assg', p[1], p[3])
    elif len(p) == 6:
        p[0] = ('assgs', p[1], p[3], p[5])
    else:
        p[0] = p[1]


def p_trel(p):
    '''
    trel : event boolexp ARROW INT SEMICOLON trel
         | nil
    '''
    if len(p) == 7:
        if p[6] is None:
            p[0] = ('trel', p[1], p[2], p[4])
        else:
            p[0] = ('trels', p[1], p[2], p[4], p[6])
    else:
        p[0] = p[1]


def p_event(p):
    '''
    event : OPENLIST CLOSELIST
          | OPENLIST ID CLOSELIST
    '''
    if len(p) == 3:
        p[0] = ("event", None)
    else:
        p[0] = ("event", p[2])


def p_boolexp_wrapper(p):
    '''
    boolexp : INT AND GUARD EQUAL ID
            | INT AND GUARD EQUAL INT
            | INT
    '''
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
        contents = infile.read()
        return parse_string(contents)


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
    pddl_import = ast[1]
    label_list_ast = ast[2]
    automata_ast = ast[3]
    labeled_formulae: List[LabeledFormula] = []
    problem: ISLProblem = ISLProblemFactory.make()
    pddl_path: str = pddl_import.replace(".", "/")
    problem.add_pddl("{}/domain.pddl".format(pddl_path),
                     "{}/problem.pddl".format(pddl_path))
    automaton = AutomataFactory.make(problem)
    automaton.initialize()
    ParseResult.instance().automaton = automaton
    if label_list_ast is not None:
        parse_label_list(label_list_ast, labeled_formulae, automaton)
    if automata_ast is not None:
        parse_automata(automata_ast, labeled_formulae, automaton)
    return ParseResult.instance()


def parse_label_list(ast: Tuple,
                     labeled_formulae: List[LabeledFormula],
                     automaton: Automaton) -> None:
    assert ast[0] == 'labellist', "AST error at label_list."
    labels_ast = ast[1]
    parse_labels(labels_ast, labeled_formulae, automaton)


def parse_labels(ast: Tuple,
                 labeled_formulae: List[LabeledFormula],
                 automaton: Automaton) -> None:
    assert ast[0] == "label" or ast[0] == "labels", \
           "AST error at label/labels."
    parse_label(ast[1], labeled_formulae, automaton)
    if ast[0] == "labels":
        parse_labels(ast[2], labeled_formulae, automaton)


def parse_label(ast: Tuple,
                labeled_formulae: List[LabeledFormula],
                automaton: Automaton) -> None:
    name = ast[1]
    label_data = ast[2]
    predicates: List[Predicate] = []
    actions: List[up.plans.ActionInstance] = []
    parse_act_or_preds(label_data, predicates, automaton, actions)
    action = None
    if len(actions) > 1:
        throw_semantic_error("label \'{}\' has >1 action".format(name))
    if len(actions) > 0:
        action = actions[0]
    labeled_formulae.append(LabeledFormula(name, predicates, action))


def parse_act_or_preds(ast: Tuple,
                       predicates: List[Predicate],
                       automaton: Automaton,
                       actions: List[up.plans.ActionInstance]) -> None:
    header = ast[0]
    label_data = ast[1]
    if label_data is None:
        return
    _type = label_data[0]
    assert _type == "predicate" or _type == "action", \
           "Goal automata must be composed of actions and predicates."
    params: List[FNode] = []
    if _type == "predicate":
        fluent = automaton.problem.get_fluent(label_data[1])
        parse_params(label_data[2], params, automaton)
        if fluent is None:
            throw_semantic_error("no such predicate: \'{}\'".format(label_data[1]))
            return
        predicate = Predicate(fluent(*params))
        automaton.get_predicate_id(predicate)  # adds a new mapping
        predicates.append(predicate)
    elif _type == "action":
        action = automaton.problem.get_action(label_data[1])
        parse_params(label_data[2], params, automaton)
        if action is None:
            throw_semantic_error("no such action: \'{}\'".format(label_data[1]))
            return
        actions.append(up.plans.ActionInstance(action, params))
    if header == "act_or_preds":
        parse_act_or_preds(ast[2], predicates, automaton, actions)


def parse_params(ast: Tuple,
                 params: List[FNode],
                 automaton: Automaton) -> None:
    assert ast[0] == "params" or ast[0] == "param", "AST error at param/params"
    if ast[0] == "param" and ast[1] is None:
        return
    param: Object = automaton.problem.get_object(ast[1])
    if param is None:
        throw_semantic_error("no such entity: \'{}\'".format(ast[1]))
        return
    params.append(param)
    if ast[0] == "params":
        parse_params(ast[2], params, automaton)


def parse_automata(ast: Tuple,
                   labeled_formulae: List[LabeledFormula],
                   automaton: Automaton) -> None:
    assert ast[0] == 'automata', "AST error at automata."
    state_dec_ast = ast[1]
    id_to_guard: Dict[str, Any] = {}
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
    assert ast[0] == 'cond_dec', "AST error at cond dec"
    assg_ast = ast[1]
    if assg_ast is not None:
        parse_cond_assg(assg_ast, labeled_formulae, id_to_guard, automaton)


def parse_cond_assg(ast: Tuple,
                    labeled_formulae: List[LabeledFormula],
                    id_to_guard: Dict[str, Any],
                    automaton: Automaton) -> None:
    assert ast[0] == "assg" or\
           ast[0] == "assgs", "AST error at cond assg/assgs."
    if "assg" in ast[0]:
        _id = ast[1]
        if _id in id_to_guard:
            throw_semantic_error("duplicate guard \'{}\'".format(_id))
            return
        name = ast[2]
        if GoalSat.is_token(name):
            id_to_guard[_id] = GoalSat.get_goalsat(name)
        elif GuardEnum.is_token(name):
            id_to_guard[_id] = GuardEnum.get_guardenum(name)
        else:
            candidates: List[LabeledFormula] = [lf for lf in labeled_formulae
                                                if lf.name == name]
            if len(candidates) == 0:
                throw_semantic_error("no such label \'{}\'".format(name))
                return
            elif len(candidates) > 1:
                throw_semantic_error("more than one label with name \'{}\'"
                                     .format(name))
                return
            lf: LabeledFormula = candidates[0]
            id_to_guard[_id] = lf.copy()
        if ast[0] == "assgs":
            parse_cond_assg(ast[3], labeled_formulae, id_to_guard, automaton)


def parse_state_dec(ast: Tuple,
                    labeled_formulae: List[LabeledFormula],
                    automaton: Automaton) -> None:
    assert ast[0] == 'state_dec', "AST error at state dec."
    assg_ast = ast[1]
    if assg_ast is not None:
        parse_assg(assg_ast, labeled_formulae, automaton)
    if automaton.init is None:
        throw_semantic_error("missing 'init' state")
        return


def parse_assg(ast: Tuple,
               labeled_formulae: List[LabeledFormula],
               automaton: Automaton) -> None:
    assert ast[0] == "assg" or ast[0] == "assgs", "AST error at st assg/assgs."
    if "assg" in ast[0]:
        _id = ast[1]
        name = ast[2]
        if name == "init":
            if automaton.init is not None:
                throw_semantic_error("module contains more than one \'init\'")
                return
            state = CheckpointFactory.make(_id=0,
                                           name="init",
                                           predicates=[],
                                           action=None,
                                           )
            automaton.states.append(state)
            automaton.init = state
        else:
            if _id in [state._id for state in automaton.states]:
                throw_semantic_error("duplicate state \'{}\'".format(_id))
            candidates: List[LabeledFormula] = [lf for lf in labeled_formulae
                                                if lf.name == name]
            if len(candidates) == 0:
                throw_semantic_error("no such label \'{}\'".format(name))
                return
            elif len(candidates) > 1:
                throw_semantic_error("more than one label with name \'{}\'"
                                     .format(name))
                return
            lf: LabeledFormula = candidates[0]
            state = CheckpointFactory.make(_id=_id,
                                           name=name,
                                           predicates=lf.predicates,
                                           action=lf.action)
            automaton.states.append(state)
        if ast[0] == "assgs":
            parse_assg(ast[3], labeled_formulae, automaton)


def parse_trel(ast: Tuple,
               id_to_guard: Dict[str, Any],
               automaton: Automaton) -> None:
    st1, cond = parse_bool_exp(ast[2], id_to_guard)
    st2 = Eq('st', ast[3])
    automaton.transitions.append(Transition(st1.val, st2.val, None, cond))
    if ast[0] == 'trels':
        parse_trel(ast[4], id_to_guard, automaton)


def parse_bool_exp(ast: Tuple,
                   id_to_guard: Dict[str, Any]):
    st: Eq = ast[0]
    guard: Any = None
    if len(ast) > 1:
        val: Any = GuardEnum.DEFAULT
        if isinstance(ast[1], str):
            if GoalSat.is_token(ast[1]):
                val = GoalSat.get_goalsat(ast[1])
            elif GuardEnum.is_token(ast[1]):
                val = GuardEnum.get_guardenum(ast[1])
        else:
            if ast[1] not in id_to_guard:
                throw_semantic_error("guard \'{}\' not assigned"
                                     .format(ast[1]))
            else:
                val = id_to_guard[ast[1]]
        guard = Eq('guard', val)
    return st, guard


def throw_semantic_error(msg: str) -> None:
    ParseResult.instance().status = ParseResultStatus.SEMANTIC_ERROR
    ParseResult.instance().msg += "parser error: " + msg + "\n"
