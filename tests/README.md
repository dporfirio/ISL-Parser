# Test Cases

This is the suite of test cases for the ISL. All test cases have the same directory structure:

```
test_group_name              # the name of the group of tests
|
|-- domain.pddl              # the domain file common to tests within the group
|-- individual_test_1        # the name of an individual test
|   |-- out.txt              # the expected output of the test
|   |-- problem.pddl         # the robot's environment defined for the test
|   |-- program.aut          # the goal automaton
|
|-- individual_test...       # another test...
|   |--...
```

*Example*: `general` is the name of a test group, which comprises numerous individual tests intended to evaluate the general functionality of the backend. Each individual test within the `general` group shares the `domain.pddl` domain, but has its own `problem.pddl`, `program.aut`, and `out.txt` describing its individual test characteristics.

## Before you begin

Do *NOT* modify anything inside of `tests/general/`.

## Creating a new test group

All test groups must "inherit" from `general`. From the top directory, here are the steps to create a new test.

`<group_name>` refers to what you decide to name your test group.

```
cd src/tests
mkdir <group_name>
touch info.json
```

Inside `src/tests/<group_name>/info.json`, you need to denote which PDDL domain file your test group will use. To do so, copy and paste the following code into `src/tests/<group_name>/info.json`, replacing `<domain_name>` with the name of the domain you want your test group to use:

```
{
    "domain": "<domain_name>"
}
```

If you need to make a new domain file, you can do so via the following commands:

```
cd pddl
cp general_domain.pddl <group_name>_domain.pddl
```

In `pddl/<group_name>_domain.pddl`, fill in any fields marked with
```
; =============================
; USER: <instruction>
;  |
;  v
```

## Creating a new test case

You may start creating individual test cases using the following steps _within_ `src/tests/<group_name>`:

1. Create a `program.aut` _or_ `program.json` file that describes the goal automaton.
2. Create a `problem.pddl` file that describes the world and its initial state.
3. Get the test case working with `python3 main.py -d tests/<group_name>/<test_name> -v test`. The `-v test` option outputs test information.
4. Check the test output. Ensure that all output is as expected. Iterate, debug, and re-test if necessary.
5. Run `python3 test.py` to make sure your test has been fully integrated into the test suite.