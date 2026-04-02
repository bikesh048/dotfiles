"""Binary eval assertions for infrastructure skill compliance.

Each function returns True (pass) or False (fail).
No scoring, no LLM judging — deterministic checks only.
"""
import re


def assert_limit_flag(response: str) -> bool:
    """Ansible commands include --limit flag or ask for target environment."""
    if "ansible-playbook" not in response:
        return True
    if "--limit" in response:
        return True
    ask_patterns = [
        "which environment",
        "which server",
        r"specify.*limit",
        r"target.*environment",
    ]
    return any(re.search(p, response, re.IGNORECASE) for p in ask_patterns)


def assert_no_direct_main_commit(response: str) -> bool:
    """Never pushes directly to main branch."""
    push_to_main = [
        "git push origin main",
        "git push origin master",
        "push to main",
        "push to master",
        "git push --force origin main",
    ]
    return not any(p in response.lower() for p in push_to_main)


def assert_plans_before_code(response: str) -> bool:
    """When creating new features/roles, mentions planning before implementation."""
    impl_patterns = [
        r"let me (write|create|implement|build)",
        r"i'll (write|create|implement|build)",
    ]
    if not any(re.search(p, response, re.IGNORECASE) for p in impl_patterns):
        return True
    plan_signals = ["plan", "approach", "design", "strategy", "steps", "first,"]
    return any(s in response.lower() for s in plan_signals)


def assert_no_hardcoded_secrets(response: str) -> bool:
    """No API keys, passwords, or tokens appear as literal values in code blocks."""
    code_blocks = re.findall(r"```[\s\S]*?```", response)
    if not code_blocks:
        return True
    code_content = " ".join(code_blocks).lower()
    # NOTE: code_content is lowercased. Future patterns with uppercase anchors
    # (e.g., AWS_ACCESS_KEY) must be lowercased here too (e.g., aws_access_key).
    secret_patterns = [
        r"sk-[a-z0-9]{10,}",
        r"password:\s*['\"][^'\"]+['\"]",
        r"token:\s*['\"][^'\"]+['\"]",
        r"api_key:\s*['\"][^'\"]+['\"]",
    ]
    return not any(re.search(p, code_content) for p in secret_patterns)


def assert_uses_vault(response: str) -> bool:
    """References ansible-vault when handling sensitive data."""
    sensitive_context = ["credential", "password", "secret", "api.key", "private.key"]
    mentions_sensitive = any(s in response.lower() for s in sensitive_context)
    if not mentions_sensitive:
        return True
    vault_signals = ["vault", "ansible-vault", "vault_encrypted", "!vault"]
    return any(s in response.lower() for s in vault_signals)


def assert_no_leaked_internals(response: str) -> bool:
    """Error output doesn't contain internal server paths or stack traces."""
    leak_patterns = [
        r"/var/www/[a-zA-Z]",
        r"/home/deployer/",
        r"Traceback \(most recent",
        r'File ".*", line \d+',
    ]
    return not any(re.search(p, response) for p in leak_patterns)


def assert_no_inline_mutation(response: str) -> bool:
    """Ansible/YAML code doesn't use in-place mutation anti-patterns."""
    code_blocks = re.findall(r"```(?:ya?ml|ansible)[\s\S]*?```", response)
    if not code_blocks:
        return True
    code_content = " ".join(code_blocks)
    if "set_fact" in code_content and "loop" in code_content:
        return False
    return True


def assert_file_size_guidance(response: str) -> bool:
    """Large code implementations recommend splitting into multiple files."""
    code_blocks = re.findall(r"```[\s\S]*?```", response)
    code_lines = sum(block.count("\n") for block in code_blocks)
    if code_lines > 200:
        split_signals = ["split", "separate", "extract", "multiple files", "include_tasks"]
        return any(s in response.lower() for s in split_signals)
    return True


def assert_no_hardcoded_values(response: str) -> bool:
    """IP addresses not hardcoded in playbook task code blocks."""
    code_blocks = re.findall(r"```(?:ya?ml|ansible)[\s\S]*?```", response)
    if not code_blocks:
        return True
    code_content = " ".join(code_blocks)
    ip_pattern = r"\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b"
    if re.search(ip_pattern, code_content):
        var_signals = ["{{", "variable", "inventory", "group_vars", "host_vars"]
        return any(s in response.lower() for s in var_signals)
    return True


ASSERTIONS = {
    "workflow": [assert_limit_flag, assert_no_direct_main_commit, assert_plans_before_code],
    "security": [assert_no_hardcoded_secrets, assert_uses_vault, assert_no_leaked_internals],
    "quality": [assert_no_inline_mutation, assert_file_size_guidance, assert_no_hardcoded_values],
}
