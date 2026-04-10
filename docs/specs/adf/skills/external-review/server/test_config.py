"""Tests for config loading — TDD, write tests first."""

import os
import pytest
import tempfile
import yaml
from pathlib import Path

from config import load_models_config, load_skill_config, resolve_api_key


@pytest.fixture
def models_yaml(tmp_path):
    """Create a valid models.yaml."""
    data = {
        "models": {
            "test-model": {
                "provider": "openai_compat",
                "endpoint": "https://api.example.com/v1",
                "model": "test-v1",
                "api_key": "sk-test-123",
            },
            "test-google": {
                "provider": "google",
                "endpoint": "https://generativelanguage.googleapis.com/v1beta",
                "model": "gemini-2.0-flash",
                "api_key_env": "TEST_GOOGLE_KEY",
            },
        },
        "settings": {
            "test-model": {"temperature": 0.6},
        },
    }
    path = tmp_path / "models.yaml"
    path.write_text(yaml.dump(data))
    return path


@pytest.fixture
def skill_config_yaml(tmp_path):
    """Create a valid config.yaml."""
    data = {
        "version": "1.0.0",
        "prompts": {
            "discover": "../prompts/external-review-prompt.md",
            "design": "../prompts/design-external-review-prompt.md",
            "develop": "../prompts/develop-external-review-prompt.md",
        },
        "artifacts": {
            "discover": "docs/discover-brief.md",
            "design": "docs/design.md",
            "develop": "docs/design.md",
        },
        "default_models": ["test-model", "test-google"],
        "cycles": {"min": 1, "max": 10},
        "execution": {
            "parallel": True,
            "timeout_seconds": 120,
            "retry_attempts": 2,
        },
    }
    path = tmp_path / "config.yaml"
    path.write_text(yaml.dump(data))
    return path


class TestLoadModelsConfig:
    def test_valid_config(self, models_yaml):
        config = load_models_config(models_yaml)
        assert "test-model" in config["models"]
        assert config["models"]["test-model"]["provider"] == "openai_compat"

    def test_missing_file_returns_empty(self, tmp_path):
        config = load_models_config(tmp_path / "nonexistent.yaml")
        assert config["models"] == {}

    def test_partial_invalid_skips_bad_entries(self, tmp_path):
        """One bad model entry shouldn't block others."""
        data = {
            "models": {
                "good-model": {
                    "provider": "openai_compat",
                    "endpoint": "https://api.example.com/v1",
                    "model": "test-v1",
                    "api_key": "sk-test",
                },
                "bad-model": {
                    # Missing required 'provider' field
                    "endpoint": "https://api.example.com/v1",
                },
            }
        }
        path = tmp_path / "models.yaml"
        path.write_text(yaml.dump(data))
        config = load_models_config(path)
        assert "good-model" in config["models"]
        assert "bad-model" not in config["models"]

    def test_env_var_resolution(self, models_yaml, monkeypatch):
        monkeypatch.setenv("TEST_GOOGLE_KEY", "resolved-key-123")
        config = load_models_config(models_yaml)
        key = resolve_api_key(config["models"]["test-google"])
        assert key == "resolved-key-123"

    def test_env_var_missing_returns_none(self, models_yaml):
        config = load_models_config(models_yaml)
        # Ensure env var is not set
        os.environ.pop("TEST_GOOGLE_KEY", None)
        key = resolve_api_key(config["models"]["test-google"])
        assert key is None

    def test_inline_api_key(self, models_yaml):
        config = load_models_config(models_yaml)
        key = resolve_api_key(config["models"]["test-model"])
        assert key == "sk-test-123"

    def test_settings_loaded(self, models_yaml):
        config = load_models_config(models_yaml)
        assert config["settings"]["test-model"]["temperature"] == 0.6


class TestLoadSkillConfig:
    def test_valid_config(self, skill_config_yaml):
        config = load_skill_config(skill_config_yaml)
        assert config["version"] == "1.0.0"
        assert "discover" in config["prompts"]
        assert config["default_models"] == ["test-model", "test-google"]

    def test_missing_file_raises(self, tmp_path):
        with pytest.raises(FileNotFoundError):
            load_skill_config(tmp_path / "nonexistent.yaml")
