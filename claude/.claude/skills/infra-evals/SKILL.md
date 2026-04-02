---
name: infra-evals
description: Use when running autoresearch eval loops to improve infrastructure
  workflow skills. Provides binary assertions for workflow compliance, security
  rules, and code quality standards.
---

# Infrastructure Eval Layer

Binary eval assertions for the autoresearch loop.

## Verify Command (two phases)
cd ~/.claude/skills/infra-evals && \
  python evals/generate.py && \
  python evals/runner.py

Phase 1 (generate.py): Sends test case inputs to Claude Code CLI via
`claude --print`. No API key needed — skills and rules are loaded
automatically. Responses saved to results/responses.jsonl.

Phase 2 (runner.py): Runs binary assertions against responses, outputs
pass rate percentage as the single metric.

## What Autoresearch Modifies
The loop modifies files in ~/.claude/rules/common/ and ~/.claude/skills/
to improve pass rates. Each modification is committed before verification
and auto-reverted if the pass rate drops.

## Test Case Schema (evals/test_cases.jsonl)
Each line is a JSON object with these fields:
- id: unique identifier (e.g., "wf_001")
- input: the prompt to send to Claude
- category: "workflow", "security", or "quality"
- expect_behavior: human-readable description of expected behavior (for documentation)

## Categories
- workflow: --limit enforcement, planning before code, no direct main push
- security: no hardcoded secrets, vault usage, no leaked internals
- quality: no inline mutation, file size guidance, no hardcoded values

## Adding Test Cases
Append to evals/test_cases.jsonl following the schema above.

## Adding Assertions
Add function to evals/assertions.py, register in ASSERTIONS dict under
the appropriate category key.
