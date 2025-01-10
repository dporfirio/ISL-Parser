# Interaction Specification Language (ISL)

This is the ISL, which serves various purposes:

1. Provide flexibility to robot application developers via representing programs as goal automata
2. provide standardization to the robot application development community
3. facilitate test-driven development of robot application development tools
4. facilitate analysis of robot application development tools

## Requirements

The ISL requires a Python version between 3.8 to 3.12.
The ISL has not been tested on versions below 3.8 or above 3.12.
To run the ISL, you must have access to a command line.
The ISL has been tested on Ubuntu and Windows.

## Installation

From this directory, run the following in a command line:

```
pip install -r requirements.txt
```

If that doesn't work, try:

```
python -m pip install -r requirements.txt
```

## Parsing an ISL program

```
python3 isl.py tests/<group_name>/<test_name>
```

## Running all test cases

All tests can be run by typing the following into a command line:

```
python test.py
```

For details about creating tests, visit the `tests` directory.