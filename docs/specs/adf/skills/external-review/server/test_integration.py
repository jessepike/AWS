"""Integration tests — server startup, tool discovery, end-to-end flow."""

import pytest
import yaml
from pathlib import Path
from unittest.mock import patch, AsyncMock

from providers.base import ReviewResponse


@pytest.fixture
def integration_env(tmp_path, monkeypatch):
    """Full environment for integration tests."""
    # models.yaml
    models_data = {
        "models": {
            "test-model": {
                "provider": "openai_compat",
                "endpoint": "https://api.test.com/v1",
                "model": "test-v1",
                "api_key": "sk-test",
            },
        },
        "settings": {},
    }
    models_path = tmp_path / "models.yaml"
    models_path.write_text(yaml.dump(models_data))

    # skill config
    skill_dir = tmp_path / "skill"
    skill_dir.mkdir()
    config_data = {
        "version": "1.0.0",
        "execution": {"timeout_seconds": 60, "retry_attempts": 1, "parallel": True},
    }
    (skill_dir / "config.yaml").write_text(yaml.dump(config_data))

    # project with artifact
    project_dir = tmp_path / "project"
    project_dir.mkdir()
    artifact = project_dir / "docs" / "brief.md"
    artifact.parent.mkdir(parents=True)
    artifact.write_text("# Brief\nTest content for review.")

    monkeypatch.chdir(project_dir)
    return {
        "models_path": models_path,
        "skill_config_path": skill_dir / "config.yaml",
        "artifact_path": str(artifact),
    }


class TestServerIntegration:
    def test_list_models(self, integration_env):
        """list_models returns configured models."""
        with patch("external_review_server.MODELS_YAML", integration_env["models_path"]):
            from config import load_models_config
            import external_review_server as srv
            srv._models_config = load_models_config(integration_env["models_path"])

            result = srv.list_models()
            assert len(result["models"]) == 1
            assert result["models"][0]["id"] == "test-model"
            assert result["models"][0]["available"] is True

    @pytest.mark.asyncio
    async def test_full_review_flow(self, integration_env):
        """End-to-end: review call → provider → aggregated response."""
        with patch("external_review_server.MODELS_YAML", integration_env["models_path"]), \
             patch("external_review_server.SKILL_CONFIG_YAML", integration_env["skill_config_path"]):
            from config import load_models_config
            import external_review_server as srv
            srv._models_config = load_models_config(integration_env["models_path"])

            mock_review = AsyncMock(return_value=ReviewResponse(
                status="success",
                response="## Feedback\nNo issues found.",
                tokens_used={"input": 50, "output": 30},
                latency_ms=500,
            ))

            with patch("providers.openai_compat.OpenAICompatProvider.review", mock_review):
                result = await srv.review(
                    models=["test-model"],
                    artifact_path=integration_env["artifact_path"],
                    prompt="Review this artifact.",
                )

            assert len(result["reviews"]) == 1
            assert result["reviews"][0]["status"] == "success"
            assert "Feedback" in result["reviews"][0]["response"]
            assert result["models_called"] == ["test-model"]
            assert result["total_latency_ms"] >= 0

    def test_mcp_server_importable(self):
        """Server module imports without error."""
        import external_review_server
        assert hasattr(external_review_server, "mcp")
        assert hasattr(external_review_server, "list_models")
        assert hasattr(external_review_server, "review")
