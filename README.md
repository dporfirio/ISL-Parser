### Installation

Make sure build and python3-venv is installed, in which X is your python version:

```
python -m pip install build
apt-get install python3-venv
```

Clone the code. In the top directory, setup as normal.

```
python -m build
pip install .
```

### Running a single test case

```
python3 main.py -d tests/<group_name>/<test_name> -v 'test'
```

### Running all test cases

All tests can be run by typing the following into a command line:

```
cd src
python test.py
```

For details about creating tests, visit the tests directory.