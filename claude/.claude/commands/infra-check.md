Audit infrastructure-as-code files in this repository:

1. **Find IaC files:** scan for `*.tf`, `*.tfvars`, `docker-compose*.yml`, `Dockerfile*`, `k8s/**`, `helm/**`, Ansible playbooks
2. **Terraform review:**
   - Check for hardcoded values that should be variables
   - Verify state backend is configured
   - Look for missing lifecycle rules or ignore_changes
   - Check for deprecated provider syntax
3. **Docker review:**
   - Verify base images use specific tags (not `latest`)
   - Check for multi-stage builds where appropriate
   - Look for secrets in build args or ENV
   - Verify .dockerignore exists
4. **Kubernetes review:**
   - Check resource limits/requests are set
   - Verify health checks (liveness/readiness probes)
   - Look for missing security contexts
   - Check for hardcoded image tags
5. **Report findings** sorted by severity (critical > warning > info)
