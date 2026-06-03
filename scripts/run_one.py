from pathlib import Path
import argparse
import subprocess
import sys
import re

FAIL_KEYWORDS = [
    "$error",
    "MISMATCH",
    "** Error",
    "Error:"
    "Fatal:",
]

def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Run one UVM test and check simulation log."
    )

    parser.add_argument(
        "--project",
        required=True,
        help="Project name, for example: axi_lite or apb",
    )

    parser.add_argument(
        "--test",
        required=True,
        help="UVM test name, for example: axi_lite_backpressure_test",
    )

    return parser.parse_args()

def check_log(text: str) -> bool:
    passed = True

    for keyword in FAIL_KEYWORDS:
        if keyword in text:
            print(f"[FAIL_KEYWORD] {keyword}")
            passed = False

    uvm_error_match = re.search(r"UVM_ERROR\s*:\s*(\d+)", text)
    if uvm_error_match:
        uvm_error_count = int(uvm_error_match.group(1))
        if uvm_error_count != 0:
            print(f"[FAIL_UVM_ERROR] count = {uvm_error_count}")
            passed = False

    uvm_fatal_match = re.search(r"UVM_FATAL\s*:\s*(\d+)", text)
    if uvm_fatal_match:
        uvm_fatal_count = int(uvm_fatal_match.group(1))
        if uvm_fatal_count != 0:
            print(f"[FAIL_UVM_FATAL] count = {uvm_fatal_count}")
            passed = False

    return passed

def main() -> None:
    args = parse_args()

    ic_root = Path(__file__).resolve().parents[1]
    project_dir = ic_root / args.project
    sim_dir = project_dir / "sim"

    if not project_dir.exists():
        print(f"[ERROR] Project directory not found: {project_dir}")
        sys.exit(1)

    if not sim_dir.exists():
        print(f"[ERROR] Simulation directory not found: {sim_dir}")
        sys.exit(1)

    run_do = sim_dir / "run.do"
    if not run_do.exists():
        print(f"[ERROR] run.do not found: {run_do}")
        sys.exit(1)

    log_dir = ic_root / "logs" / args.project
    log_dir.mkdir(parents=True, exist_ok=True)

    log_file = log_dir / f"{args.test}.log"

    cmd = [
        "vsim",
        "-c",
        "-do",
        f"do run_batch.do {args.test}",
    ]

    print("=======================================")
    print(f"[PROJECT] {args.project}")
    print(f"[TEST]    {args.test}")
    print(f"[SIM_DIR] {sim_dir}")
    print(f"[LOG]     {log_file}")
    print(f"[CMD]     {' '.join(cmd)}")
    print("=======================================")

    result = subprocess.run(
        cmd,
        cwd=sim_dir,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )

    log_file.write_text(result.stdout, encoding="utf-8", errors="ignore")

    pass_by_log = check_log(result.stdout)
    pass_by_return_code = result.returncode == 0

    if pass_by_log and pass_by_return_code:
        print(f"[RESULT] {args.project}/{args.test}: PASS")
        sys.exit(0)
    else:
        print(f"[RESULT] {args.project}/{args.test}: FAIL")
        print(f"[RETURN_CODE] {result.returncode}")
        sys.exit(2)

if __name__ == "__main__":
    main()