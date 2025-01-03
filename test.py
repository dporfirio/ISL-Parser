import os
import coverage
import time
import argparse


class Args:

    def __init__(self, domain) -> None:
        self.testcase = domain
        self.verbosity = 'silent'


parser = argparse.ArgumentParser()
parser.add_argument("-g", "--group",
                    help="run only a specific group of tests",
                    type=str)
args = parser.parse_args()

# terminal colors
RED = '\033[0;31m'
YELLOW = '\033[1;33m'
GREEN = '\033[0;32m'
NC = '\033[0m'

# counts of correct tests
parser_count = 0
parser_total = 0
planner_count = 0
planner_total = 0

print("\nISL lexing + parsing tests\n")

# start coverage
cov = coverage.Coverage()
cov.start()
import main  # noqa: E402

# track memory profiling
maxmem: float = 0.0

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
    print("-----------------------------------------------------------------")
    print("{: <24}|  {: <7}  |     {: <20}".format("", "", ""))
    print("{: <24}|  {: <7}  |     {: <20}".format("test id", "parser", "test duration"))
    print("{: <24}|  {: <7}  |     {: <20}".format("", "", ""))
    print("-----------------------------------------------------------------")

    folders = os.listdir(fullpath)
    folders.sort()

    # test main.py ability to remove slash from folder name
    folders[0] += "/"

    for _folder in folders:
        _dir = fullpath + "/" + _folder
        if not os.path.isdir(_dir):
            continue

        start = time.time()
        result = main.main(Args(_dir))
        end = time.time()
        runtime = "(" + "%.5f" % (end - start) + " seconds)"
        result_str = _folder
        parser_color = planner_color = YELLOW
        parser_result_str = planner_result_str = "error"
        parser_total += 1
        msg: str = ""
        outfile_name: str
        parsed_oracle = "".join(open(_dir + "/parser_out.txt")
                                .readlines()).strip()
        if parsed_oracle == result.parse_out:
            parser_result_str = "PASS"
            parser_color = GREEN
            parser_count += 1
        else:
            outfile_name = "{}.{}.parse.txt".format(app_scenario,
                                                    _folder.rstrip('/'))
            with open("tests/{}".format(outfile_name), "w") as outfile:
                outfile.write(result.parse_out)
            msg += " parser output written to {}.".format(outfile_name)
            parser_result_str = "FAIL"
            parser_color = RED
        print("{: <24}|  {}{: <7}{}  |     {: <20}{}".format(
                result_str,
                parser_color,
                parser_result_str,
                NC,
                runtime,
                "{}".format(" <" + msg if len(msg) > 0 else ""))
              )
    print("-----------------------------------------------------------------\n\n")

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
                                         .format(parser_count, parser_total)),
      end="")
color = NC
if cov_val > 95:
    color = GREEN
elif cov_val > 90:
    color = YELLOW
else:
    color = RED

print("{}{: <17}{: <50}{}".format(color,
                                  "Coverage:",
                                  " {}%".format("%.2f" % (cov_val)), NC))
