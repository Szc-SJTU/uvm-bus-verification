from pathlib import Path
import argparse
import subprocess
import sys
import re


PROJECT_ALIAS = {
    "axi_lite": "axi_lite_uvm_sample",
    "apb": "apb_uvm_sample",
    "axi2apb3": "axi2apb3_bridge_uvm",
    "bridge": "axi2apb3_bridge_uvm",
}


DEFAULT_TESTS = {
    "axi_lite_uvm_sample": [
        "axi_lite_write_read_test",
        "axi_lite_wstrb_test",
        "axi_lite_read_before_write_test",
        "axi_lite_random_like_test",
        "axi_lite_aw_w_order_test",
        "axi_lite_backpressure_test",
        "axi_lite_stress_test",
        "axi_lite_error_resp_test",
    ],
    "apb_uvm_sample": [
        # 后面你 APB 想接入时再补
        # "apb_write_read_test",
        # "apb_random_like_test",
    ],
    "axi2apb3_bridge_uvm": [
        "axi2apb_multi_slave_test",
        "axi2apb_multi_slave_boundary_test",
        "axi2apb_illegal_addr_test",
        "axi2apb_mixed_addr_test",
        "axi2apb_multi_slave_timing_test",
        "axi2apb_read_clear_test",
        "axi2apb_pslverr_test",
        "axi2apb_v3_stress_test",
    ],
}


FAIL_KEYWORDS = [
    "UVM_FATAL",
    "UVM_ERROR",
    "RESULT                 : FAIL",
    "AXI2APB3 SCOREBOARD FAIL",
    "COMPARE FAIL",
    "CMP_FAIL",
    "** Fatal:",
]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Run multiple UVM tests and generate regression summary."
    )

    parser.add_argument(
        "--project",
        required=True,
        help="Project name or alias, for example: axi_lite, apb, axi_lite_uvm_sample",
    )

    parser.add_argument(
        "--tests",
        nargs="*",
        default=None,
        help="Optional test list. If not given, use default tests for the project.",
    )

    return parser.parse_args()


def check_log(text: str) -> bool:
    passed = True

    # UVM count is the most reliable failure source.
    uvm_error_match = re.search(r"UVM_ERROR\s*:\s*(\d+)", text)
    if uvm_error_match:
        if int(uvm_error_match.group(1)) != 0:
            passed = False

    uvm_fatal_match = re.search(r"UVM_FATAL\s*:\s*(\d+)", text)
    if uvm_fatal_match:
        if int(uvm_fatal_match.group(1)) != 0:
            passed = False

    # Scoreboard final result.
    if "RESULT                 : PASS" not in text:
        passed = False

    # Real failure markers.
    real_fail_keywords = [
        "RESULT                 : FAIL",
        "AXI2APB3 SCOREBOARD FAIL",
        "CMP_FAIL",
        "** Fatal:",
    ]

    for keyword in real_fail_keywords:
        if keyword in text:
            passed = False

    return passed


def run_one_test(
    sim_dir: Path,
    log_dir: Path,
    test_name: str,
) -> tuple[str, bool, int, Path]:
    log_file = log_dir / f"{test_name}.log"

    cmd = [
        "vsim",
        "-c",
        "-do",
        f"do run_batch.do {test_name}",
    ]

    print("========================================")
    print(f"[RUN]  {test_name}")
    print(f"[CMD]  {' '.join(cmd)}")
    print(f"[LOG]  {log_file}")

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

    passed = pass_by_log and pass_by_return_code

    if passed:
        print(f"[RESULT] {test_name}: PASS")
    else:
        print(f"[RESULT] {test_name}: FAIL")
        print(f"[RETURN_CODE] {result.returncode}")

    return test_name, passed, result.returncode, log_file


def main() -> None:
    args = parse_args()

    ic_root = Path(__file__).resolve().parents[1]

    project_name = PROJECT_ALIAS.get(args.project, args.project)

    project_dir = ic_root / project_name
    sim_dir = project_dir / "sim"

    if not project_dir.exists():
        print(f"[ERROR] Project directory not found: {project_dir}")
        sys.exit(1)

    if not sim_dir.exists():
        print(f"[ERROR] Simulation directory not found: {sim_dir}")
        sys.exit(1)

    run_batch_do = sim_dir / "run_batch.do"
    if not run_batch_do.exists():
        print(f"[ERROR] run_batch.do not found: {run_batch_do}")
        sys.exit(1)

    if args.tests is not None and len(args.tests) > 0:
        tests = args.tests
    else:
        tests = DEFAULT_TESTS.get(project_name, [])

    if len(tests) == 0:
        print(f"[ERROR] No tests specified for project: {project_name}")
        sys.exit(1)

    log_dir = ic_root / "logs" / project_name
    log_dir.mkdir(parents=True, exist_ok=True)

    results = []

    print("========================================")
    print(f"[PROJECT] {project_name}")
    print(f"[SIM_DIR] {sim_dir}")
    print(f"[LOG_DIR] {log_dir}")
    print(f"[TEST_NUM] {len(tests)}")
    print("========================================")

    for test_name in tests:
        result = run_one_test(sim_dir, log_dir, test_name)
        results.append(result)

    print("")
    print("========================================")
    print("REGRESSION SUMMARY")
    print("========================================")

    pass_count = 0
    fail_count = 0

    for test_name, passed, return_code, log_file in results:
        status = "PASS" if passed else "FAIL"

        if passed:
            pass_count += 1
        else:
            fail_count += 1

        print(f"{test_name:<40} {status:<5}  {log_file}")

    print("----------------------------------------")
    print(f"TOTAL : {len(results)}")
    print(f"PASS  : {pass_count}")
    print(f"FAIL  : {fail_count}")
    print("========================================")

    summary_file = log_dir / "summary.txt"

    with summary_file.open("w", encoding="utf-8") as f:
        f.write("REGRESSION SUMMARY\n")
        f.write("========================================\n")

        for test_name, passed, return_code, log_file in results:
            status = "PASS" if passed else "FAIL"
            f.write(f"{test_name:<40} {status:<5}  {log_file}\n")

        f.write("----------------------------------------\n")
        f.write(f"TOTAL : {len(results)}\n")
        f.write(f"PASS  : {pass_count}\n")
        f.write(f"FAIL  : {fail_count}\n")

    print(f"[SUMMARY_FILE] {summary_file}")

    if fail_count == 0:
        sys.exit(0)
    else:
        sys.exit(2)


if __name__ == "__main__":
    main()