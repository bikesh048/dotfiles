Help triage and respond to an incident. The user will describe the symptoms.

1. **Classify severity:** P1 (service down), P2 (degraded), P3 (minor impact), P4 (no user impact)
2. **Identify blast radius:** which services/users are affected?
3. **Check recent changes:**
   - `git log --oneline --since="24 hours ago"` for recent deploys
   - Look for config changes, dependency updates, infrastructure modifications
4. **Generate investigation checklist:**
   - Relevant logs to check
   - Metrics/dashboards to monitor
   - Services to inspect
   - Database queries to run
5. **Suggest immediate mitigation:** rollback steps, feature flags, scaling actions
6. **Draft comms:** internal status update template

Output a structured incident response doc with all findings.
