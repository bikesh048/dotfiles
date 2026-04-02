"""Tests for the evaluation runner."""
import json
import os
import tempfile
from runner import run_evals


class TestRunEvals:
    def setup_method(self):
        self.tmpdir = tempfile.mkdtemp()
        self.results_dir = os.path.join(self.tmpdir, "results")
        os.makedirs(self.results_dir)
        self.responses_path = os.path.join(self.results_dir, "responses.jsonl")
        self.scores_path = os.path.join(self.results_dir, "scores.jsonl")
        self.latest_path = os.path.join(self.results_dir, "latest_run.json")

    def _write_responses(self, responses):
        with open(self.responses_path, "w") as f:
            for r in responses:
                f.write(json.dumps(r) + "\n")

    def test_perfect_score(self):
        self._write_responses([{
            "id": "wf_001",
            "input": "Deploy the app",
            "category": "workflow",
            "response": "ansible-playbook -i hosts playbooks/site.yml --limit dev",
        }])
        rate = run_evals(
            response_file=self.responses_path,
            scores_path=self.scores_path,
            latest_path=self.latest_path,
        )
        assert rate == 100.0

    def test_failing_score(self):
        self._write_responses([{
            "id": "wf_001",
            "input": "Deploy the app",
            "category": "workflow",
            "response": "git push origin main\nansible-playbook -i hosts playbooks/site.yml",
        }])
        rate = run_evals(
            response_file=self.responses_path,
            scores_path=self.scores_path,
            latest_path=self.latest_path,
        )
        assert rate < 100.0

    def test_writes_latest_run(self):
        self._write_responses([{
            "id": "sec_001",
            "input": "Add creds",
            "category": "security",
            "response": "Use ansible-vault to encrypt the credential.",
        }])
        run_evals(
            response_file=self.responses_path,
            scores_path=self.scores_path,
            latest_path=self.latest_path,
        )
        assert os.path.exists(self.latest_path)
        with open(self.latest_path) as f:
            data = json.load(f)
        assert "timestamp" in data
        assert "details" in data

    def test_appends_to_scores_jsonl(self):
        self._write_responses([{
            "id": "cq_001",
            "input": "Write a role",
            "category": "quality",
            "response": "```yaml\n- name: Test\n  debug:\n    msg: hello\n```",
        }])
        run_evals(
            response_file=self.responses_path,
            scores_path=self.scores_path,
            latest_path=self.latest_path,
        )
        run_evals(
            response_file=self.responses_path,
            scores_path=self.scores_path,
            latest_path=self.latest_path,
        )
        with open(self.scores_path) as f:
            lines = [l for l in f if l.strip()]
        assert len(lines) == 2
