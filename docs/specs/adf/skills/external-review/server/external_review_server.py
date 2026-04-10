"""External Review MCP Server — calls external LLMs for Phase 2 reviews."""

import asyncio
import os
import time
from datetime import datetime, timezone
from pathlib import Path

from mcp.server.fastmcp import FastMCP

from config import load_models_config, load_skill_config, resolve_api_key
from path_validation import validate_artifact_path
from providers.openai_compat import OpenAICompatProvider
from providers.google import GoogleProvider

# Resolve config paths
SKILL_DIR = Path(__file__).parent.parent
SERVER_DIR = Path(__file__).parent
MODELS_YAML = Path.home() / ".claude" / "models.yaml"
SKILL_CONFIG_YAML = SKILL_DIR / "config.yaml"

# Load configs at startup
_models_config = load_models_config(MODELS_YAML)

PROVIDER_MAP = {
    "openai_compat": OpenAICompatProvider,
    "google": GoogleProvider,
}

mcp = FastMCP("external-review")


def _get_provider(model_id: str):
    """Instantiate provider for a model ID."""
    model_cfg = _models_config["models"].get(model_id)
    if not model_cfg:
        return None, f"Unknown model: {model_id}"

    api_key = resolve_api_key(model_cfg)
    if not api_key:
        return None, f"No API key for model: {model_id}"

    provider_type = model_cfg["provider"]
    provider_cls = PROVIDER_MAP.get(provider_type)
    if not provider_cls:
        return None, f"Unknown provider type: {provider_type}"

    return provider_cls(endpoint=model_cfg["endpoint"], api_key=api_key), None


@mcp.tool()
def list_models() -> dict:
    """List available external review models from ~/.claude/models.yaml."""
    models = []
    for model_id, model_cfg in _models_config["models"].items():
        api_key = resolve_api_key(model_cfg)
        models.append({
            "id": model_id,
            "provider": model_cfg["provider"],
            "model": model_cfg["model"],
            "available": api_key is not None,
        })
    return {"models": models}


@mcp.tool()
async def review(
    models: list[str],
    artifact_path: str,
    prompt: str,
    timeout: int | None = None,
) -> dict:
    """Send artifact + prompt to specified models in parallel, return aggregated responses.

    Args:
        models: Model IDs from models.yaml
        artifact_path: Absolute path to artifact file
        prompt: Review prompt with instructions
        timeout: Override default timeout (seconds)
    """
    # Detect project root (cwd of the server process)
    project_root = os.getcwd()

    # Validate and read artifact
    try:
        validated_path = validate_artifact_path(artifact_path, project_root=project_root)
        artifact_content = Path(validated_path).read_text()
    except (ValueError, FileNotFoundError) as e:
        return {"error": str(e), "reviews": [], "models_called": models}

    # Load skill config for defaults
    try:
        skill_config = load_skill_config(SKILL_CONFIG_YAML)
        default_timeout = skill_config.get("execution", {}).get("timeout_seconds", 120)
        retry_attempts = skill_config.get("execution", {}).get("retry_attempts", 2)
    except FileNotFoundError:
        default_timeout = 120
        retry_attempts = 2

    effective_timeout = timeout or default_timeout

    # Build tasks for parallel execution
    start = time.monotonic()

    async def call_model(model_id: str) -> dict:
        provider, error = _get_provider(model_id)
        if error:
            return {
                "model": model_id,
                "status": "error",
                "error": error,
                "retries_attempted": 0,
            }

        model_cfg = _models_config["models"][model_id]
        settings = dict(_models_config.get("settings", {}).get(model_id, {}))
        settings["_retry_attempts"] = retry_attempts
        settings["_timeout_seconds"] = effective_timeout

        pricing = model_cfg.get("pricing")

        result = await provider.review(
            artifact_content=artifact_content,
            prompt=prompt,
            model=model_cfg["model"],
            settings=settings,
            pricing=pricing,
        )

        entry = {
            "model": model_id,
            "status": result.status,
            "timestamp": datetime.now(timezone.utc).isoformat(),
        }
        if result.status == "success":
            entry["response"] = result.response
            entry["tokens_used"] = result.tokens_used
            entry["cost_usd"] = result.cost_usd
            entry["latency_ms"] = result.latency_ms
            entry["cycle"] = 1
        else:
            entry["error"] = result.error
            entry["retries_attempted"] = result.retries_attempted

        return entry

    reviews = await asyncio.gather(
        *(call_model(m) for m in models),
        return_exceptions=True,
    )

    # Handle any unexpected exceptions
    processed = []
    for i, r in enumerate(reviews):
        if isinstance(r, Exception):
            processed.append({
                "model": models[i],
                "status": "error",
                "error": str(r),
                "retries_attempted": 0,
            })
        else:
            processed.append(r)

    total_latency = int((time.monotonic() - start) * 1000)

    # Aggregate tokens and cost
    total_input = sum(r.get("tokens_used", {}).get("input", 0) for r in processed if r.get("tokens_used"))
    total_output = sum(r.get("tokens_used", {}).get("output", 0) for r in processed if r.get("tokens_used"))
    costs = [r["cost_usd"] for r in processed if r.get("cost_usd") is not None]
    total_cost = round(sum(costs), 6) if costs else None

    return {
        "reviews": processed,
        "models_called": models,
        "parallel": True,
        "total_latency_ms": total_latency,
        "total_tokens": {"input": total_input, "output": total_output},
        "total_cost_usd": total_cost,
    }


def main():
    mcp.run(transport="stdio")


if __name__ == "__main__":
    main()
