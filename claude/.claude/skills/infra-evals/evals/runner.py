"""Evaluation runner — runs binary assertions against responses and outputs pass rate.

This is phase 2 of the verify step. Autoresearch reads the printed pass rate
as the single metric to optimize.
"""
import json
import os
import sys
from datetime import datetime, timezone
from assertions import ASSERTIONS


def run_evals(
    response_file: str = "results/responses.jsonl",
    scores_path: str = "results/scores.jsonl",
    latest_path: str = "results/latest_run.json",
) -> float:
    for path in (scores_path, latest_path):
        os.makedirs(os.path.dirname(path) or ".", exist_ok=True)

    now = datetime.now(timezone.utc).isoformat()

    with open(response_file) as f:
        responses = [json.loads(line) for line in f if line.strip()]

    total, passed = 0, 0
    details = []

    for case in responses:
        category = case["category"]
        response = case["response"]
        assertions = ASSERTIONS.get(category, [])

        for assertion in assertions:
            total += 1
            result = assertion(response)
            if result:
                passed += 1
            details.append({
                "case_id": case["id"],
                "assertion": assertion.__name__,
                "passed": result,
                "category": category,
            })

    pass_rate = (passed / total * 100) if total > 0 else 0

    with open(latest_path, "w") as f:
        json.dump({
            "timestamp": now,
            "pass_rate": pass_rate,
            "total": total,
            "passed": passed,
            "details": details,
        }, f, indent=2)

    with open(scores_path, "a") as f:
        entry = {
            "timestamp": now,
            "pass_rate": pass_rate,
            "total": total,
            "passed": passed,
        }
        f.write(json.dumps(entry) + "\n")

    print(f"{pass_rate:.1f}")
    return pass_rate


if __name__ == "__main__":
    run_evals(sys.argv[1] if len(sys.argv) > 1 else "results/responses.jsonl")
