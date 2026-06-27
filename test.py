import os
import coverage
import time
import argparse
import traceback
from multiprocessing import Lock
from multiprocessing import Pool
from functools import partial
from typing import List, Any
import warnings
warnings.filterwarnings("ignore", category=UserWarning)

PROJECT_ROOT = os.path.dirname(os.path.abspath(__file__))


def start_coverage(data_suffix: bool = False) -> coverage.Coverage:
    cov = coverage.Coverage(data_suffix=data_suffix)
    cov.start()
    return cov


def stop_coverage(cov: coverage.Coverage | None) -> None:
    if cov is not None:
        cov.stop()
        cov.save()


def erase_parallel_coverage_files() -> None:
    for filename in os.listdir("."):
        if filename.startswith(".coverage."):
            path = os.path.join(".", filename)
            if os.path.isfile(path):
                os.remove(path)


class Args:

    def __init__(self, file, task=['parse'], exec_dir=".",) -> None:
        self.file = file
        self.task = task
        self.exec_dir = exec_dir
        self.execute = False
        self.verbosity = 'silent'


def islwrapper(args: Args) -> Any:
    import islparser.isl as isl

    return isl.main(args)


def planner_engine_diagnostics() -> str:
    try:
        from unified_planning.shortcuts import get_environment

        engines = get_environment().factory.engines
        return "\nRegistered Unified Planning engines:\n{}\n".format(engines)
    except Exception:
        return ""


def error_output_path(app_scenario: str, folder: str) -> str:
    filename = "{}.{}.error.txt".format(app_scenario, folder.rstrip('/'))
    return os.path.join(PROJECT_ROOT, "tests", filename)


def run(_folder: str, fullpath: str, app_scenario: str, RED: str, YELLOW: str,
        GREEN: str, GRAY: str, NC: str, i: int, parallel: bool,
        collect_coverage: bool) -> Any:
    os.chdir(PROJECT_ROOT)
    # Import application modules before coverage to preserve the old worker
    # initialization order, including any planner plugin registration side effects.
    import islparser.isl  # noqa: F401
    from unified_planning.shortcuts import get_environment

    get_environment()

    cov = start_coverage(data_suffix=True) if collect_coverage else None
    try:
        return run_test_case(_folder, fullpath, app_scenario, RED, YELLOW,
                             GREEN, GRAY, NC, i, parallel)
    finally:
        stop_coverage(cov)


def run_test_case(_folder: str, fullpath: str, app_scenario: str, RED: str,
                  YELLOW: str, GREEN: str, GRAY: str, NC: str, i: int,
                  parallel: bool) -> Any:
    parsetot = 0
    parsecount = 0
    plancount = 0
    distillcount = 0
    _dir = fullpath + "/" + _folder
    _file = _dir + "/program.isl"
    if not os.path.isdir(_dir):
        return ("", 0, 0, 0, 0)
    if not os.path.isfile(_file):
        return ("", 0, 0, 0, 0)

    stale_error = error_output_path(app_scenario, _folder)
    if os.path.isfile(stale_error):
        os.remove(stale_error)

    # decide on ISL tasks
    tasks: List[str] = []
    if os.path.exists(_dir + "/planner_out.txt"):
        tasks.append('plan')
    if os.path.exists(_dir + "/distiller_out.txt"):
        tasks.append('distill')

    # execute the ISL tasks
    start = time.time()
    try:
        if parallel:
            result = islwrapper(Args(_file, tasks,
                                     "tmp_test_store/{}".format(i)))
        else:
            result = islwrapper(Args(_file, tasks))
    except Exception as e:
        os.chdir(PROJECT_ROOT)
        end = time.time()
        runtime = "(" + "%.5f" % (end - start) + " seconds)"
        error_name = type(e).__name__
        outfile_name = os.path.basename(error_output_path(app_scenario,
                                                          _folder))
        with open(error_output_path(app_scenario, _folder), "w") as outfile:
            outfile.write(traceback.format_exc())
            outfile.write(planner_engine_diagnostics())
        result_str = "{: <24}| {}{: <7}{} | {}{: <7}{} | {}{: <7}{} | {: <20}{}"\
            .format(_folder,
                    RED,
                    "ERROR",
                    NC,
                    RED,
                    "ERROR" if 'plan' in tasks else "no test",
                    NC,
                    RED if 'distill' in tasks else GRAY,
                    "ERROR" if 'distill' in tasks else "no test",
                    NC,
                    runtime,
                    " < {} written to {}.".format(error_name, outfile_name))
        return (1, 0, 0, 0, result_str)
    end = time.time()
    runtime = "(" + "%.5f" % (end - start) + " seconds)"
    result_str = _folder
    parser_color = planner_color = YELLOW
    parser_result_str = planner_result_str = "error"
    parsetot = 1
    msg: str = ""
    outfile_name: str
    parsed_oracle = "".join(open(_dir + "/parser_out.txt")
                            .readlines()).strip()
    if parsed_oracle == result.parse_out:
        parser_result_str = "PASS"
        parser_color = GREEN
        parsecount = 1
    else:
        outfile_name = "{}.{}.parse.txt".format(app_scenario,
                                                _folder.rstrip('/'))
        with open("tests/{}".format(outfile_name), "w") as outfile:
            outfile.write(result.parse_out)
        msg += " parser output written to {}.".format(outfile_name)
        parser_result_str = "FAIL"
        parser_color = RED
    if 'plan' in tasks:
        planned_oracle = "".join(open(_dir + "/planner_out.txt")
                                 .readlines()).strip()
        if planned_oracle == result.plan_out:
            planner_result_str = "PASS"
            planner_color = GREEN
            plancount = 1
        else:
            outfile_name = "{}.{}.plan.txt".format(app_scenario,
                                                   _folder.rstrip('/'))
            with open("tests/{}".format(outfile_name), "w") as outfile:
                outfile.write(result.plan_out)
            msg += " planner output written to {}.".format(outfile_name)
            planner_result_str = "FAIL"
            planner_color = RED
    else:
        planner_result_str = "no test"
        planner_color = GRAY
    if 'distill' in tasks:
        distilled_oracle = "".join(open(_dir + "/distiller_out.txt")
                                   .readlines()).strip()
        if distilled_oracle == result.distill_out:
            distiller_result_str = "PASS"
            distiller_color = GREEN
            distillcount = 1
        else:
            outfile_name = "{}.{}.distill.txt".format(app_scenario,
                                                      _folder.rstrip('/'))
            with open("tests/{}".format(outfile_name), "w") as outfile:
                outfile.write(result.distill_out)
            msg += " distiller output written to {}.".format(outfile_name)
            distiller_result_str = "FAIL"
            distiller_color = RED
    else:
        distiller_result_str = "no test"
        distiller_color = GRAY
    result_str = "{: <24}| {}{: <7}{} | {}{: <7}{} | {}{: <7}{} | {: <20}{}"\
        .format(result_str,
                parser_color,
                parser_result_str,
                NC,
                planner_color,
                planner_result_str,
                NC,
                distiller_color,
                distiller_result_str,
                NC,
                runtime,
                "{}".format(" <" + msg if len(msg) > 0 else ""))
    return (parsetot, parsecount, plancount, distillcount, result_str)


class Results:

    def __init__(self):
        self.curr_idx = 0
        self.parser_count = 0
        self.parser_total = 0
        self.planner_count = 0
        self.planner_total = 0
        self.distiller_count = 0
        self.distiller_total = 0
        self.results = []
        self.lock = Lock()


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("-g", "--group",
                        help="run only a specific group of tests",
                        type=str)
    parser.add_argument("-c", "--cores",
                        help="number of cores to use for parallelization",
                        type=int,
                        default=1)
    args = parser.parse_args()

    # terminal colors
    RED = '\033[0;31m'
    YELLOW = '\033[1;33m'
    GREEN = '\033[0;32m'
    GRAY = '\033[90m'
    NC = '\033[0m'

    print("\nISL tests: parser, planner, & distiller\n")

    # track memory profiling
    maxmem: float = 0.0

    # get the number of cores (for parallelization)
    num_cores: int = max(1, min(args.cores, os.cpu_count()))

    # start coverage; parallel runs write worker data with unique suffixes
    erase_parallel_coverage_files()
    cov = coverage.Coverage()
    cov.erase()
    if num_cores == 1:
        cov.start()

    # apply_async callback adds results to an array
    results: Results = Results()

    def callback(result, index, results) -> None:
        with results.lock:
            results.parser_total += result[0]
            results.parser_count += result[1]
            results.planner_count += result[2]
            results.distiller_total += result[3]
            results.results.append((index, result))
            results.results.sort(key=lambda x: x[0])
            # prnt & remove any buff'd results starting at `curr_idx` in order
            while results.results and\
                    results.results[0][0] == results.curr_idx:
                _, res = results.results.pop(0)
                print(res[-1], flush=True)
                results.curr_idx += 1

    for app_scenario in os.listdir("tests"):
        results.curr_idx = 0

        # possibly run just one test
        if args.group is not None and \
           len(args.group) > 0 and \
           app_scenario != args.group:
            continue

        fullpath = "tests/" + app_scenario
        if not os.path.isdir(fullpath):
            continue

        print("\nBATCH NAME: {}".format(app_scenario))
        print("------------------------------------------------------------------------")
        print("{: <24}| {: <7} | {: <7} | {: <7} | {: <20}".format("", "", "", "", ""))
        print("{: <24}| {: <7} | {: <7} | {: <7} | {: <20}".format("test id", "parse", "plan", "distill", "test duration"))
        print("{: <24}| {: <7} | {: <7} | {: <7} | {: <20}".format("", "", "", "", ""))
        print("------------------------------------------------------------------------")

        folders = os.listdir(fullpath)
        folders.sort()

        # test main.py ability to remove slash from folder name
        folders[0] += "/"

        if num_cores > 1:
            if not os.path.isdir("tmp_test_store"):
                os.mkdir("tmp_test_store")
            for i in range(len(folders)):
                subdir = "tmp_test_store/{}".format(str(i))
                if not os.path.isdir(subdir):
                    os.mkdir(subdir)

            with Pool(processes=num_cores, maxtasksperchild=1) as p:
                # submit all tasks
                reslist = [p.apply_async(run,
                                         callback=partial(callback,
                                                          index=i,
                                                          results=results),
                                         args=(_folder, fullpath,
                                               app_scenario,
                                               RED, YELLOW, GREEN,
                                               GRAY, NC, i, True, True))
                           for i, _folder in enumerate(folders)]

                # make sure that each task has finished
                for res in reslist:
                    res.get()

            # sort results by index
            results_list: List = results.results
            results_list.sort(key=lambda x: x[0])
            for result in results_list:
                print(result[1][-1])
        else:
            for i, _folder in enumerate(folders):
                result = run(_folder, fullpath, app_scenario,
                             RED, YELLOW, GREEN, GRAY, NC, i, False, False)
                print(result[-1])

        print("------------------------------------------------------------------------\n\n")

    if num_cores > 1:
        cov.combine(data_paths=[PROJECT_ROOT])
        cov.save()
    else:
        cov.stop()
        cov.save()
    print("-----------------------------------------------------")
    print("Coverage analysis:")
    cov.html_report()
    cov_val = cov.report()

    color = NC
    if cov_val > 95:
        color = GREEN
    elif cov_val > 90:
        color = YELLOW
    else:
        color = RED

    print("{}{: <17}{: <50}{}".format(color,
                                      "Coverage:",
                                      " {}%".format("%.2f" % (cov_val)),
                                      NC))
    erase_parallel_coverage_files()
