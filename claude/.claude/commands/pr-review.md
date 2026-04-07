Perform a thorough code review of the current branch against main:

1. `git diff main..HEAD` to see all changes
2. Review each changed file for:
   - **Correctness:** logic errors, edge cases, off-by-one errors
   - **Security:** injection risks, auth bypasses, exposed secrets, OWASP top 10
   - **Performance:** N+1 queries, unnecessary loops, missing indexes
   - **Maintainability:** naming, complexity, dead code, missing error handling
   - **Tests:** are new code paths covered? any broken tests?
3. Check for:
   - Breaking changes to public APIs
   - Missing or outdated documentation
   - Dependency changes and their implications
4. Output a structured review with:
   - **Must fix:** blocking issues
   - **Should fix:** important but non-blocking
   - **Nit:** style/preference suggestions
   - **Praise:** things done well
