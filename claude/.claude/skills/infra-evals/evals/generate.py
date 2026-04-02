"""Response generator — sends test case inputs to Claude Code CLI and records responses.

Uses `claude --print` so that all skills, rules, and CLAUDE.md files are
automatically loaded — no API key needed, and responses reflect actual
Claude Code behavior.
"""
import json
import os
import subprocess
import sys
import time

MAX_RETRIES = 3
RETRY_DELAY_SECONDS = 5


def generate_responses(
    test_cases_path: str = "evals/test_cases.jsonl",
    output_path: str = "results/responses.jsonl",
) -> None:
    """Send each test case to Claude Code CLI and record responses."""
    with open(test_cases_path) as f:
        cases = [json.loads(line) for line in f if line.strip()]

    os.makedirs(os.path.dirname(output_path) or ".", exist_ok=True)

    results = []
    for case in cases:
        response_text = None
        for attempt in range(MAX_RETRIES):
            try:
                proc = subprocess.run(
                    ["claude", "--print", "--model", "sonnet", case["input"]],
                    capture_output=True,
                    text=True,
                    timeout=120,
                )
                if proc.returncode == 0 and proc.stdout.strip():
                    response_text = proc.stdout.strip()
                    break
                else:
                    print(f"Attempt {attempt + 1}/{MAX_RETRIES} failed for {case['id']}: "
                          f"exit={proc.returncode} stderr={proc.stderr[:200]}")
            except subprocess.TimeoutExpired:
                print(f"Attempt {attempt + 1}/{MAX_RETRIES} timed out for {case['id']}")
            except Exception as e:
                print(f"Attempt {attempt + 1}/{MAX_RETRIES} failed for {case['id']}: {e}")
                if attempt < MAX_RETRIES - 1:
                    time.sleep(RETRY_DELAY_SECONDS * (attempt + 1))

        if response_text is None:
            print(f"FATAL: {case['id']} failed after {MAX_RETRIES} retries — aborting run")
            sys.exit(1)

        results.append({
            "id": case["id"],
            "input": case["input"],
            "category": case["category"],
            "response": response_text,
        })

    with open(output_path, "w") as f:
        for r in results:
            f.write(json.dumps(r) + "\n")

    print(f"Generated {len(results)}/{len(cases)} responses")


if __name__ == "__main__":
    generate_responses()
