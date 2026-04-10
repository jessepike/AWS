"""Config loading for external-review MCP server."""

import os
from pathlib import Path

import yaml
from dotenv import load_dotenv

# Load .env from ADF project root (two levels up from server/)
_env_path = Path(__file__).resolve().parent.parent.parent.parent / ".env"
load_dotenv(_env_path, override=True)

REQUIRED_MODEL_FIELDS = {"provider", "endpoint", "model"}


def load_models_config(path: Path) -> dict:
    """Load models.yaml. Returns empty models dict if file missing or invalid."""
    result = {"models": {}, "settings": {}}
    if not path.exists():
        return result

    try:
        raw = yaml.safe_load(path.read_text()) or {}
    except yaml.YAMLError:
        return result

    raw_models = raw.get("models", {})
    if not isinstance(raw_models, dict):
        return result

    for model_id, model_cfg in raw_models.items():
        if not isinstance(model_cfg, dict):
            continue
        if not REQUIRED_MODEL_FIELDS.issubset(model_cfg.keys()):
            continue
        result["models"][model_id] = model_cfg

    result["settings"] = raw.get("settings", {}) or {}
    return result


def load_skill_config(path: Path) -> dict:
    """Load skill config.yaml. Raises FileNotFoundError if missing."""
    if not path.exists():
        raise FileNotFoundError(f"Skill config not found: {path}")

    with open(path) as f:
        return yaml.safe_load(f)


def resolve_api_key(model_config: dict) -> str | None:
    """Resolve API key from inline value or environment variable."""
    if "api_key" in model_config:
        return model_config["api_key"]
    if "api_key_env" in model_config:
        return os.environ.get(model_config["api_key_env"])
    return None
