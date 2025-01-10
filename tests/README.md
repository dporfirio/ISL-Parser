# Test Cases

This is the suite of test cases for the ISL. All test cases have the same directory structure:

```
test_group_name              # the name of the group of tests
|
|-- individual_test_1        # the name of an individual test
|   |-- parser_out.txt       # the expected output of the test
|   |-- program.isl          # the goal automaton
|
|-- individual_test...       # another test...
|   |--...
```

*Example*: `general` is the name of a test group, which comprises numerous individual tests intended to evaluate the general functionality of the backend. Each individual test within the `general` group shares the `pddl/general/domain.pddl` domain and `pddl/general/problem.pddl` problem description. Each individual test has its own `program.isl`, and `pasrser_out.txt`, which describe the individual test characteristics.


## Creating a new test group

All test groups currently must "inherit" from `general`. From the top directory, here are the steps to create a new test.

`<group_name>` refers to what you decide to name your test group.

```
cd src/tests
mkdir <group_name>
```

If you need to make new domain and problem files, you can do so via the following commands:

```
cd pddl
mkdir <group_name>
cp general/domain.pddl <group_name>/domain.pddl
```

In `pddl/<group_name>/domain.pddl`, fill in any fields marked with
```
; =============================
; USER: <instruction>
;  |
;  v
```

You will also need to create the problem file:

```
mkdir <group_name>/problem.pddl
```

## Creating a new test case

You may start creating individual test cases using the following steps _within_ `src/tests/<group_name>`:

1. Create a `tests/<group>/program.isl` file that describes the goal automaton.
2. Create a `pddl/<group>/problem.pddl` file that describes the world and its initial state.
3. Get the test case working with `python3 isl.py tests/<group_name>/<test_name>/program.isl -v test`. The `-v test` option outputs test information.
4. Check the test output. Ensure that all output is as expected. Iterate, debug, and re-test if necessary.
5. Run `python3 test.py` to make sure your test has been fully integrated into the test suite.