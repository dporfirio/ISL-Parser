import os
import coverage
import time
import argparse
from multiprocessing import Lock
from multiprocessing import Pool
from functools import partial
from typing import List, Any
import islparser.isl as isl  # noqa: E402
import warnings
warnings.filterwarnings("ignore", category=UserWarning)


class Args:

    def __init__(self, file, task=['parse'], exec_dir=".",) -> None:
        self.file = file
        self.task = task
        self.exec_dir = exec_dir
        self.verbosity = 'silent'


def islwrapper(args: Args) -> Any:
    return isl.main(args)


def run(_folder: str, fullpath: str, app_scenario: str, RED: str, YELLOW: str,
        GREEN: str, GRAY: str, NC: str, i: int) -> Any:
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

    # decide on ISL tasks
    tasks: List[str] = []
    if os.path.exists(_dir + "/planner_out.txt"):
        tasks.append('plan')
    if os.path.exists(_dir + "/distiller_out.txt"):
        tasks.append('distill')

    # execute the ISL tasks
    start = time.time()
    result = islwrapper(Args(_file, tasks, "tmp_test_store/{}".format(i)))
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

    # counts of correct tests
    parser_count = 0
    parser_total = 0
    planner_count = 0
    planner_total = 0
    distiller_count = 0
    distiller_total = 0

    print("\nISL tests: parser, planner, & distiller\n")

    # track memory profiling
    maxmem: float = 0.0

    # get the number of cores (for parallelization)
    num_cores: int = max(1, min(args.cores, os.cpu_count()))

    # start coverage if running on one core
    if num_cores == 1:
        cov = coverage.Coverage()
        cov.start()

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

        # apply_async callback adds results to an array
        results: Results = Results()

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
                                               GRAY, NC, i))
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
                             RED, YELLOW, GREEN, GRAY, NC, i)
                print(result[-1])

        print("------------------------------------------------------------------------\n\n")

    if num_cores == 1:
        cov.stop()
        cov.save()
        print("-----------------------------------------------------")
        print("Coverage analysis:")
        cov.html_report()
        cov_val = cov.report()

    color = NC
    if parser_count == parser_total:
        if parser_total > 0:
            color = GREEN
    elif parser_count == 0:
        color = RED
    else:
        color = YELLOW
    print("\n\n{}{: <17}{} {: <50}\n".format(color,
                                             "Parser Result:", NC,
                                             "{} out of {} tests passed."
                                             .format(parser_count,
                                                     parser_total)),
          end="")

    if num_cores == 1:
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
