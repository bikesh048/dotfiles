"""Tests for the response generator."""
import json
import os
import tempfile
from unittest.mock import patch, MagicMock
import pytest
from generate import generate_responses, MAX_RETRIES


class TestGenerateResponses:
    def setup_method(self):
        self.tmpdir = tempfile.mkdtemp()
        self.test_cases_path = os.path.join(self.tmpdir, "test_cases.jsonl")
        self.output_path = os.path.join(self.tmpdir, "responses.jsonl")

        with open(self.test_cases_path, "w") as f:
            f.write(json.dumps({
                "id": "test_001",
                "input": "Deploy to all servers",
                "category": "workflow",
                "expect_behavior": "must ask for --limit",
            }) + "\n")

    @patch("generate.subprocess.run")
    def test_generates_responses(self, mock_run):
        mock_proc = MagicMock()
        mock_proc.returncode = 0
        mock_proc.stdout = "Which environment? Use --limit dev"
        mock_proc.stderr = ""
        mock_run.return_value = mock_proc

        generate_responses(
            test_cases_path=self.test_cases_path,
            output_path=self.output_path,
        )

        assert os.path.exists(self.output_path)
        with open(self.output_path) as f:
            results = [json.loads(line) for line in f if line.strip()]
        assert len(results) == 1
        assert results[0]["id"] == "test_001"
        assert results[0]["response"] == "Which environment? Use --limit dev"

        # Verify claude CLI was called with correct args
        mock_run.assert_called_once()
        call_args = mock_run.call_args[0][0]
        assert "claude" in call_args
        assert "--print" in call_args
        assert "Deploy to all servers" in call_args

    @patch("generate.subprocess.run")
    def test_exits_on_persistent_failure(self, mock_run):
        mock_proc = MagicMock()
        mock_proc.returncode = 1
        mock_proc.stdout = ""
        mock_proc.stderr = "Error"
        mock_run.return_value = mock_proc

        with pytest.raises(SystemExit):
            generate_responses(
                test_cases_path=self.test_cases_path,
                output_path=self.output_path,
            )

        assert mock_run.call_count == MAX_RETRIES

    @patch("generate.subprocess.run")
    def test_retries_on_failure_then_succeeds(self, mock_run):
        fail_proc = MagicMock()
        fail_proc.returncode = 1
        fail_proc.stdout = ""
        fail_proc.stderr = "Error"

        success_proc = MagicMock()
        success_proc.returncode = 0
        success_proc.stdout = "Use --limit dev"
        success_proc.stderr = ""

        mock_run.side_effect = [fail_proc, success_proc]

        generate_responses(
            test_cases_path=self.test_cases_path,
            output_path=self.output_path,
        )

        assert mock_run.call_count == 2
        with open(self.output_path) as f:
            results = [json.loads(line) for line in f if line.strip()]
        assert len(results) == 1
