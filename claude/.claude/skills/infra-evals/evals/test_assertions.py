"""Tests for binary eval assertions."""
import pytest
from assertions import (
    assert_limit_flag,
    assert_no_direct_main_commit,
    assert_plans_before_code,
    assert_no_hardcoded_secrets,
    assert_uses_vault,
    assert_no_leaked_internals,
    assert_no_inline_mutation,
    assert_file_size_guidance,
    assert_no_hardcoded_values,
)


class TestLimitFlag:
    def test_passes_when_limit_present(self):
        response = "ansible-playbook -i inventory/hosts.ini playbooks/site.yml --limit dev"
        assert assert_limit_flag(response) is True

    def test_fails_when_no_limit(self):
        response = "ansible-playbook -i inventory/hosts.ini playbooks/site.yml"
        assert assert_limit_flag(response) is False

    def test_passes_when_asking_which_environment(self):
        response = "ansible-playbook command needs a target. Which environment do you want to deploy to?"
        assert assert_limit_flag(response) is True

    def test_passes_when_no_ansible_command(self):
        response = "Sure, I can help with that nginx config."
        assert assert_limit_flag(response) is True


class TestNoDirectMainCommit:
    def test_passes_on_feature_branch_push(self):
        response = "git push origin feat/add-redis"
        assert assert_no_direct_main_commit(response) is True

    def test_fails_on_push_to_main(self):
        response = "git push origin main"
        assert assert_no_direct_main_commit(response) is False

    def test_fails_on_push_to_master(self):
        response = "git push origin master"
        assert assert_no_direct_main_commit(response) is False


class TestPlansBeforeCode:
    def test_passes_when_planning_mentioned(self):
        response = "Let me create a plan first. Here are the steps we'll follow."
        assert assert_plans_before_code(response) is True

    def test_fails_when_jumping_to_implementation(self):
        response = "Let me create the role right away with all the tasks."
        assert assert_plans_before_code(response) is False

    def test_passes_when_no_implementation_keywords(self):
        response = "The current nginx config looks correct."
        assert assert_plans_before_code(response) is True


class TestNoHardcodedSecrets:
    def test_passes_with_vault_reference(self):
        response = "Use `ansible-vault encrypt` to store the credential:\n```yaml\ndb_password: !vault |\n  $ANSIBLE_VAULT;1.1;AES256\n```"
        assert assert_no_hardcoded_secrets(response) is True

    def test_fails_with_literal_password_in_code(self):
        response = '```yaml\ndb_config:\n  password: "mysecretpassword"\n```'
        assert assert_no_hardcoded_secrets(response) is False

    def test_fails_with_api_key_in_code(self):
        response = '```yaml\napi_key: "sk-abcdefghij1234567890"\n```'
        assert assert_no_hardcoded_secrets(response) is False

    def test_passes_when_mentioning_password_in_text(self):
        response = "You should encrypt the password field using ansible-vault."
        assert assert_no_hardcoded_secrets(response) is True

    def test_passes_when_secret_outside_code_blocks(self):
        """Intentional: we only check inside fenced code blocks, not prose."""
        response = 'The password: "hunter2" should be encrypted with vault.'
        assert assert_no_hardcoded_secrets(response) is True


class TestUsesVault:
    def test_passes_when_vault_mentioned(self):
        response = "Store the credential using ansible-vault encrypt_string."
        assert assert_uses_vault(response) is True

    def test_fails_when_no_vault_for_secrets(self):
        response = "Add the password to the defaults/main.yml file as a regular variable."
        assert assert_uses_vault(response) is False


class TestNoLeakedInternals:
    def test_passes_with_clean_error(self):
        response = "The deployment failed. Check the application logs for details."
        assert assert_no_leaked_internals(response) is True

    def test_fails_with_internal_path(self):
        response = "Error in /var/www/stag-travel/storage/logs/laravel.log"
        assert assert_no_leaked_internals(response) is False

    def test_fails_with_traceback(self):
        response = 'Traceback (most recent call last):\n  File "/app/main.py", line 42'
        assert assert_no_leaked_internals(response) is False


class TestNoInlineMutation:
    def test_passes_without_mutation(self):
        response = "```yaml\n- name: Set user\n  user:\n    name: deployer\n```"
        assert assert_no_inline_mutation(response) is True

    def test_fails_with_set_fact_in_loop(self):
        response = "```yaml\n- name: Build list\n  set_fact:\n    items: '{{ items + [item] }}'\n  loop: '{{ raw_items }}'\n```"
        assert assert_no_inline_mutation(response) is False


class TestFileSizeGuidance:
    def test_passes_with_short_code(self):
        response = "```yaml\n- name: Short task\n  debug:\n    msg: hello\n```"
        assert assert_file_size_guidance(response) is True

    def test_fails_with_long_code_no_split_signal(self):
        long_code = "```yaml\n" + "- name: task\n  debug:\n    msg: line\n" * 70 + "```"
        response = f"Here is the role:\n{long_code}"
        assert assert_file_size_guidance(response) is False

    def test_passes_with_long_code_and_split_signal(self):
        long_code = "```yaml\n" + "- name: task\n  debug:\n    msg: line\n" * 70 + "```"
        response = f"This is too large. You should split it into multiple files.\n{long_code}"
        assert assert_file_size_guidance(response) is True


class TestNoHardcodedValues:
    def test_passes_with_variable(self):
        response = "```yaml\n- name: Connect\n  host: '{{ db_host }}'\n```\nUse inventory variables."
        assert assert_no_hardcoded_values(response) is True

    def test_fails_with_hardcoded_ip(self):
        response = "```yaml\n- name: Connect\n  host: 192.168.1.100\n```"
        assert assert_no_hardcoded_values(response) is False
