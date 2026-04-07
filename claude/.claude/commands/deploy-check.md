Review the current branch for deployment readiness:

1. Run `git log --oneline main..HEAD` to see all commits being deployed
2. Check for any TODO/FIXME/HACK comments in changed files: `git diff main..HEAD --name-only` then grep those files
3. Verify no `.env`, secrets, or credentials are staged
4. Check if tests pass (look for test scripts in package.json, Makefile, or similar)
5. Look for any database migrations that need to run
6. Check for breaking API changes in modified files
7. Summarize findings with a go/no-go recommendation

Report format:
- **Commits:** count and summary
- **Risk areas:** any concerns found
- **Migrations:** yes/no
- **Secrets check:** pass/fail
- **Recommendation:** READY / NEEDS REVIEW / BLOCKED
