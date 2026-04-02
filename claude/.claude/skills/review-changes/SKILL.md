---
name: review-changes
description: Interactive review of git changes — asks about intent, impact, edge cases, and risks before committing.
---

Review the current git changes (staged + unstaged) and interview me about them using the AskUserQuestion tool.

## Steps

1. Run `git diff` and `git diff --cached` to see all changes.
2. Run `git log --oneline -5` for recent commit context.
3. Group changes by file or logical unit.
4. For each group, ask about:
   - **Intent**: Why was this change made? What problem does it solve?
   - **Impact**: What other parts of the system does this affect?
   - **Edge cases**: Are there scenarios where this could break?
   - **Testing**: How was this tested? What's not covered?
   - **Rollback**: Can this be safely reverted if something goes wrong?
5. Be thorough — don't ask obvious questions. Focus on non-obvious risks, missing validations, and implicit assumptions.
6. After all questions are answered, produce a summary:
   - Changes reviewed
   - Risks identified
   - Suggested improvements (if any)
   - Recommended commit message
