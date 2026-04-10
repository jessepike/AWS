"""Tests for review tool — mocked providers, TDD."""

import os
import pytest
import yaml
from pathlib import Path
from unittest.mock import AsyncMock, patch

from providers.base import ReviewResponse


@pytest.fixture
def setup_env(tmp_path, monkeypatch):
    """Set up models.yaml, config.yaml, and artifact for review tool tests."""
    # Create models.yaml
    models_data = {
        "models": {
            "model-a": {
                "provider": "openai_compat",
                "endpoint": "https://api.a.com/v1",
                "model": "a-v1",
                "api_key": "sk-a",
            },
            "model-b": {
                "provider": "google",
                "endpoint": "https://api.b.com/v1beta",
                "model": "b-v1",
                "api_key": "sk-b",
            },
        },
        "settings": {},
    }
    models_path = tmp_path / "models.yaml"
    models_path.write_text(yaml.dump(models_data))

    # Create skill config.yaml
    skill_dir = tmp_path / "skill"
    skill_dir.mkdir()
    config_data = {
        "version": "1.0.0",
        "execution": {"timeout_seconds": 60, "retry_attempts": 1, "parallel": True},
    }
    (skill_dir / "config.yaml").write_text(yaml.dump(config_data))

    # Create artifact
    project_dir = tmp_path / "project"
    project_dir.mkdir()
    artifact = project_dir / "docs" / "brief.md"
    artifact.parent.mkdir(parents=True)
    artifact.write_text("# Test Artifact\nThis is test content.")

    monkeypatch.chdir(project_dir)

    return {
        "models_path": models_path,
        "skill_config_path": skill_dir / "config.yaml",
        "artifact_path": str(artifact),
        "project_dir": project_dir,
    }


def _make_success_response(model_name: str) -> ReviewResponse:
    return ReviewResponse(
        status="success",
        response=f"## Review from {model_name}\nLooks good.",
        tokens_used={"input": 100, "output": 50},
        latency_ms=1000,
    )


def _make_error_response() -> ReviewResponse:
    return ReviewResponse(
        status="error",
        error="API rate limit exceeded",
        latency_ms=500,
        retries_attempted=2,
    )


class TestReviewTool:
    @pytest.mark.asyncio
    async def test_all_succeed(self, setup_env):
        with patch("external_review_server.MODELS_YAML", setup_env["models_path"]), \
             patch("external_review_server.SKILL_CONFIG_YAML", setup_env["skill_config_path"]):
            # Reload config
            from config import load_models_config
            import external_review_server as srv
            srv._models_config = load_models_config(setup_env["models_path"])

            # Mock providers
            mock_openai = AsyncMock(return_value=_make_success_response("model-a"))
            mock_google = AsyncMock(return_value=_make_success_response("model-b"))

            with patch("providers.openai_compat.OpenAICompatProvider.review", mock_openai), \
                 patch("providers.google.GoogleProvider.review", mock_google):
                result = await srv.review(
                    models=["model-a", "model-b"],
                    artifact_path=setup_env["artifact_path"],
                    prompt="Review this.",
                )

            assert len(result["reviews"]) == 2
            assert all(r["status"] == "success" for r in result["reviews"])
            assert result["parallel"] is True
            assert set(result["models_called"]) == {"model-a", "model-b"}

    @pytest.mark.asyncio
    async def test_one_fails_partial_results(self, setup_env):
        with patch("external_review_server.MODELS_YAML", setup_env["models_path"]), \
             patch("external_review_server.SKILL_CONFIG_YAML", setup_env["skill_config_path"]):
            from config import load_models_config
            import external_review_server as srv
            srv._models_config = load_models_config(setup_env["models_path"])

            mock_openai = AsyncMock(return_value=_make_success_response("model-a"))
            mock_google = AsyncMock(return_value=_make_error_response())

            with patch("providers.openai_compat.OpenAICompatProvider.review", mock_openai), \
                 patch("providers.google.GoogleProvider.review", mock_google):
                result = await srv.review(
                    models=["model-a", "model-b"],
                    artifact_path=setup_env["artifact_path"],
                    prompt="Review this.",
                )

            assert len(result["reviews"]) == 2
            statuses = {r["model"]: r["status"] for r in result["reviews"]}
            assert statuses["model-a"] == "success"
            assert statuses["model-b"] == "error"

    @pytest.mark.asyncio
    async def test_all_fail(self, setup_env):
        with patch("external_review_server.MODELS_YAML", setup_env["models_path"]), \
             patch("external_review_server.SKILL_CONFIG_YAML", setup_env["skill_config_path"]):
            from config import load_models_config
            import external_review_server as srv
            srv._models_config = load_models_config(setup_env["models_path"])

            mock_fail = AsyncMock(return_value=_make_error_response())

            with patch("providers.openai_compat.OpenAICompatProvider.review", mock_fail), \
                 patch("providers.google.GoogleProvider.review", mock_fail):
                result = await srv.review(
                    models=["model-a", "model-b"],
                    artifact_path=setup_env["artifact_path"],
                    prompt="Review this.",
                )

            assert len(result["reviews"]) == 2
            assert all(r["status"] == "error" for r in result["reviews"])

    @pytest.mark.asyncio
    async def test_artifact_not_found(self, setup_env):
        with patch("external_review_server.MODELS_YAML", setup_env["models_path"]), \
             patch("external_review_server.SKILL_CONFIG_YAML", setup_env["skill_config_path"]):
            from config import load_models_config
            import external_review_server as srv
            srv._models_config = load_models_config(setup_env["models_path"])

            result = await srv.review(
                models=["model-a"],
                artifact_path=str(setup_env["project_dir"] / "nonexistent.md"),
                prompt="Review this.",
            )

            assert "error" in result
            assert result["reviews"] == []

    @pytest.mark.asyncio
    async def test_unknown_model(self, setup_env):
        with patch("external_review_server.MODELS_YAML", setup_env["models_path"]), \
             patch("external_review_server.SKILL_CONFIG_YAML", setup_env["skill_config_path"]):
            from config import load_models_config
            import external_review_server as srv
            srv._models_config = load_models_config(setup_env["models_path"])

            result = await srv.review(
                models=["nonexistent-model"],
                artifact_path=setup_env["artifact_path"],
                prompt="Review this.",
            )

            assert len(result["reviews"]) == 1
            assert result["reviews"][0]["status"] == "error"
            assert "Unknown model" in result["reviews"][0]["error"]
