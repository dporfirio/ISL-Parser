from __future__ import annotations
from enum import Enum
from typing import Tuple, List, Dict, Any
import unified_planning as up
from unified_planning.model.fnode import FNode  # type: ignore[import-untyped]
from ply.lex import lex  # type: ignore[import-untyped]
from ply.yacc import yacc  # type: ignore[import-untyped]
from model.isl_problem import (
    ISLProblemFactory,
    ISLProblem
)
from model.automata import (
    Automaton,
    AutomataFactory,
    PredicateKey
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
        self.status = ParseResultStatus.ERROR
        self.msg += "line {}: ".format(lineno) + \
                    "no such object named {}\n".format(name)


class ParseResultStatus(Enum):

    SUCCESS = 0
    WARNING = 1
    ERROR = 2


tokens = ('LABELS', 'ENDLABELS', 'MODULE', 'ENDMODULE', 'OPTIONS',
          'ENDOPTIONS', 'ST', 'GUARD', 'INIT', 'ACTION', 'PREDICATE', 'PARAMS',
          'INT', 'ID',
          'AND', 'NOT',
          'EQUAL',
          'COLON', 'SEMICOLON', 'OPENLIST', 'CLOSELIST', 'COMMA', 'ARROW',
          'IMPORT', 'OPTCONDEFFECTS')

t_ignore = ' \t'

reserved = {
    'labels': "LABELS",
    'endlabels': "ENDLABELS",
    'module': "MODULE",
    'endmodule': "ENDMODULE",
    'options': 'OPTIONS',
    'endoptions': 'ENDOPTIONS',
    'st': "ST",
    'guard': "GUARD",
    'init': "INIT",
    'not': "NOT",
    'action': "ACTION",
    'predicate': "PREDICATE",
    'params': "PARAMS",
    'import': "IMPORT",

    # options
    'conditional_effects': 'OPTCONDEFFECTS'  # planner allows condit. effects
}

t_ARROW = r'->'
t_COLON = r':'
t_SEMICOLON = r';'
t_OPENLIST = r'\['
t_CLOSELIST = r'\]'
t_COMMA = r','
t_AND = r'&'
t_EQUAL = r'='


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
    p[0] = ('program', p[1], p[2], p[3], p[4])


def p_nil(p):
    '''
    nil :
    '''
    pass


def p_import(p):
    '''
    import : IMPORT ID
    '''
    p[0] = p[2]


def p_labels(p):
    '''
    labels : LABELS labellist ENDLABELS
    '''
    if p[2] is None:
        p[0] = p[2]
    else:
        p[0] = ('cmdlist', p[2])


def p_module(p):
    '''
    module : MODULE automata ENDMODULE
    '''
    p[0] = p[2]


def p_options(p):
    '''
    options : OPTIONS optionlist ENDOPTIONS
            | nil
    '''
    if p[1] is None:
        p[0] = tuple('options')
    elif p[1] is not None:
        opts = ['options']
        opts_raw = p[2]
        while True:
            opts.append(opts_raw[1])
            if opts_raw[0] == 'options':
                opts_raw = opts_raw[2]
                continue
            break
        p[0] = tuple(opts)


def p_optionlist(p):
    '''
    optionlist : option
               | option optionlist
               | nil
    '''
    if p[1] is None:
        p[0] = p[1]
    elif len(p) == 2 or (len(p) == 3 and p[2] is None):
        p[0] = ('option', p[1])
    elif len(p) == 3 and p[2] is not None:
        p[0] = ('options', p[1], p[2])


def p_option(p):
    '''
    option : OPTCONDEFFECTS SEMICOLON
    '''
    p[0] = p[1]


def p_labellist(p):
    '''
    labellist : cmd
            | cmd COMMA labellist
            | nil
    '''
    if len(p) == 2:
        if p[1] is None:
            p[0] = p[1]
        else:
            p[0] = ('cmd', p[1])
    else:
        p[0] = ('cmds', p[1], p[3])


def p_cmd(p):
    '''
    cmd : ID COLON OPENLIST act_or_pred_list CLOSELIST
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
    '''
    if p[1] == "action":
        p[0] = ('action', p[3], p[8])
    else:
        p[0] = ('predicate', p[3], p[8])


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
    trel : event boolexp ARROW boolexp SEMICOLON trel
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
    boolexp : boolexp AND boolexp
            | GUARD EQUAL ID
            | GUARD EQUAL INT
            | INT
            | nil
    '''
    if len(p) == 4:
        if p[2] == '&':
            p[0] = ('&', p[1], p[3])
        else:
            p[0] = ('eq', p[1], p[3])
    elif p[1] is None:
        p[0] = p[1]
    else:
        p[0] = ('eq', 'st', p[1])


def p_error(p):
    ParseResult.instance().status = ParseResultStatus.ERROR
    ParseResult.instance().msg += "line {}: ".format(p.lineno) +\
                                  "Unexpected token \'{}\'\n".format(p.value)


def parse_file(arg_domain: str) -> ParseResult:
    # TODO: add import statements into filename containing PDDL info
    aut_filename = "{}/program.aut".format(arg_domain)
    with open(aut_filename) as infile:
        contents = infile.read()
        return parse_string(contents, arg_domain)


def parse_string(to_parse: str, arg_domain: str) -> ParseResult:
    lexer = lex()
    lexer.input(to_parse)
    parser = yacc()
    ParseResult.instance().reset()
    ast = parser.parse(to_parse, tracking=True)
    parse_result: ParseResult = parse_program(ast, arg_domain)
    parse_result.build()
    return parse_result


def parse_program(ast: Tuple, arg_domain: str) -> ParseResult:
    if ast is None:
        return ParseResult.instance()
    assert ast[0] == 'program', "AST error at root."
    domain = ast[1]
    cmd_list_ast = ast[2]
    automata_ast = ast[3]
    options_ast = ast[4]
    labeled_formulae: List[LabeledFormula] = []
    parse_options(options_ast)
    problem: ISLProblem = ISLProblemFactory.make()
    problem.add_pddl("pddl/{}_domain.pddl".format(domain),
                     "{}/problem.pddl".format(arg_domain))
    automaton = AutomataFactory.make(problem)
    automaton.initialize()
    ParseResult.instance().automaton = automaton
    if cmd_list_ast is not None:
        parse_cmd_list(cmd_list_ast, labeled_formulae, automaton)
    if automata_ast is not None:
        parse_automata(automata_ast, labeled_formulae, automaton)
    return ParseResult.instance()


def parse_cmd_list(ast: Tuple,
                   labeled_formulae: List[LabeledFormula],
                   automaton: Automaton) -> None:
    assert ast[0] == 'cmdlist', "AST error at cmd_list."
    cmds_ast = ast[1]
    parse_cmds(cmds_ast, labeled_formulae, automaton)


def parse_cmds(ast: Tuple,
               labeled_formulae: List[LabeledFormula],
               automaton: Automaton) -> None:
    assert ast[0] == "cmd" or ast[0] == "cmds", "AST error at cmd/cmds."
    parse_cmd(ast[1], labeled_formulae, automaton)
    if ast[0] == "cmds":
        parse_cmds(ast[2], labeled_formulae, automaton)


def parse_cmd(ast: Tuple,
              labeled_formulae: List[LabeledFormula],
              automaton: Automaton) -> None:
    name = ast[1]
    cmd_data = ast[2]
    predicates: List[Predicate] = []
    actions: List[up.plans.ActionInstance] = []
    parse_act_or_preds(cmd_data, predicates, automaton, actions)
    assert len(actions) <= 1, "Cannot have more than one action in a state."
    action = None
    if len(actions) > 0:
        action = actions[0]
    labeled_formulae.append(LabeledFormula(name, predicates, action))


def parse_act_or_preds(ast: Tuple,
                       predicates: List[Predicate],
                       automaton: Automaton,
                       actions: List[up.plans.ActionInstance]) -> None:
    header = ast[0]
    cmd_data = ast[1]
    _type = cmd_data[0]
    assert _type == "predicate" or _type == "action", \
           "Goal automata must be composed of actions and predicates."
    params: List[FNode] = []
    if _type == "predicate":
        fluent = automaton.problem.get_fluent(cmd_data[1])
        parse_params(cmd_data[2], params, automaton)
        predicate = Predicate(fluent(*params))
        automaton.get_predicate_id(predicate)  # adds a new mapping
        predicates.append(predicate)
    elif _type == "action":
        action = automaton.problem.get_action(cmd_data[1])
        parse_params(cmd_data[2], params, automaton)
        actions.append(up.plans.ActionInstance(action, params))
    if header == "act_or_preds":
        parse_act_or_preds(ast[2], predicates, automaton, actions)


def parse_params(ast: Tuple,
                 params: List[FNode],
                 automaton: Automaton) -> None:
    assert ast[0] == "params" or ast[0] == "param", "AST error at param/params"
    if ast[0] == "param" and ast[1] is None:
        return
    params.append(automaton.problem.get_object(ast[1]))
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
        name = ast[2]
        if GoalSat.is_token(name):
            id_to_guard[_id] = GoalSat.get_goalsat(name)
        elif GuardEnum.is_token(name):
            id_to_guard[_id] = GuardEnum.get_guardenum(name)
        else:
            lf = [lf for lf in labeled_formulae if lf.name == name][0]
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


def parse_assg(ast: Tuple,
               labeled_formulae: List[LabeledFormula],
               automaton: Automaton) -> None:
    assert ast[0] == "assg" or ast[0] == "assgs", "AST error at st assg/assgs."
    if "assg" in ast[0]:
        _id = ast[1]
        name = ast[2]
        if name == "init":
            state = automaton.query_state_by_name(name)
            state._id = _id
            automaton.init = state
        else:
            lf = [lf for lf in labeled_formulae if lf.name == name][0]
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
    st1 = Eq('st', -1)
    cond = parse_bool_exp(ast[2], st1, id_to_guard, automaton)
    st2 = Eq('st', -1)
    _ = parse_bool_exp(ast[3], st2, id_to_guard, automaton)
    automaton.transitions.append(Transition(st1.val, st2.val, None, cond))
    if ast[0] == 'trels':
        parse_trel(ast[4], id_to_guard, automaton)


def parse_bool_exp(ast: Tuple,
                   st: Eq,
                   id_to_guard: Dict[str, Any],
                   automaton: Automaton):
    op = ast[0]
    if op == 'eq':
        if ast[1] == 'st':        # goal state
            st.val = ast[2]
            return None
        elif ast[1] == 'guard':      # goal sat
            val: Any = GuardEnum.DEFAULT
            if isinstance(ast[2], str):
                if GoalSat.is_token(ast[2]):
                    val = GoalSat.get_goalsat(ast[2])
                elif GuardEnum.is_token(ast[2]):
                    val = GuardEnum.get_guardenum(ast[2])
            else:
                val = id_to_guard[ast[2]]
            return Eq('guard', val)
    elif op == '&':
        _ = parse_bool_exp(ast[1], st, id_to_guard, automaton)
        cond2 = parse_bool_exp(ast[2], st, id_to_guard, automaton)
        return cond2


def parse_options(options: Tuple) -> None:
    Options.instance().clearopt()  # in case options has already been init'd
    for option in options:
        Options.instance().setopt(option, True)
    PredicateKey.instance().clear()
