---
name: autoresearch:predict
description: Multi-persona swarm prediction — pre-analyze code from multiple expert perspectives using file-based knowledge representation. Zero external dependencies.
argument-hint: "[goal/focus] [--scope <glob>] [--chain debug|security|fix|ship|scenario (comma-separated for multi)] [--depth shallow|standard|deep] [--personas N] [--rounds N] [--adversarial] [--budget <dollars>] [--fail-on <severity>]"
---

Load and follow the autoresearch predict workflow protocol.

1. Read the skill file: `.claude/skills/autoresearch/SKILL.md` — understand the overall autoresearch framework
2. Read the predict workflow reference: `.claude/skills/autoresearch/references/predict-workflow.md` — this is the FULL protocol to follow
3. Parse any flags from the user's arguments: $ARGUMENTS
4. Execute the 8-phase predict workflow as defined in `predict-workflow.md`

Follow the predict workflow protocol exactly. Build file-based knowledge representation (codebase-analysis.md, dependency-map.md, component-clusters.md), generate expert personas, run structured debate with Devil's Advocate, produce consensus findings with anti-herd detection, and optionally chain to downstream subcommands via handoff.json.
