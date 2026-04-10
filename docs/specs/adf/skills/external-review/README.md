# External Review MCP Server

MCP server that sends artifacts + review prompts to external LLMs (Gemini, GPT, Kimi) in parallel and returns aggregated responses. Used for Phase 2 external reviews in ADF.

## Setup

### 1. Install dependencies

```bash
cd skills/external-review/server
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### 2. Configure API keys

Add exports to `~/.zshrc` (or equivalent shell profile):

```bash
export GOOGLE_API_KEY="your-key-here"
export OPENAI_API_KEY="your-key-here"
export MOONSHOT_API_KEY="your-key-here"
```

Then reload:

```bash
source ~/.zshrc
```

Keys are resolved from environment variables at runtime — they never touch any git-tracked file.

### 3. Configure models

Create `~/.claude/models.yaml`:

```yaml
models:
  gemini:
    provider: google
    endpoint: https://generativelanguage.googleapis.com/v1beta
    model: gemini-2.0-flash
    api_key_env: GOOGLE_API_KEY
  gpt:
    provider: openai_compat
    endpoint: https://api.openai.com/v1
    model: gpt-4o
    api_key_env: OPENAI_API_KEY
  kimi:
    provider: openai_compat
    endpoint: https://api.moonshot.cn/v1
    model: kimi-k2
    api_key_env: MOONSHOT_API_KEY
```

Each model entry requires: `provider`, `endpoint`, `model`, and one of `api_key` (inline) or `api_key_env` (env var name).

### 4. MCP registration

The server is registered in `.mcp.json` at the project root:

```json
{
  "mcpServers": {
    "external-review": {
      "command": "skills/external-review/server/venv/bin/python",
      "args": ["skills/external-review/server/external_review_server.py"],
      "env": {}
    }
  }
}
```

**Important:** After changing API keys or `models.yaml`, restart Claude Code — MCP servers launch as subprocesses at startup.

## MCP Tools

### `list_models`

Returns available models from `~/.claude/models.yaml` with availability status (whether API key resolves).

### `review`

Sends an artifact + prompt to specified models in parallel.

Parameters:
- `models` — list of model IDs from models.yaml
- `artifact_path` — absolute path to the artifact file
- `prompt` — review prompt text
- `timeout` — optional override (seconds, default from config.yaml)

## Providers

| Provider | Type | Models |
|----------|------|--------|
| `google` | Google Generative AI | Gemini |
| `openai_compat` | OpenAI-compatible | GPT, Kimi, DeepSeek, Together, etc. |

Both providers support retry with exponential backoff, configurable timeout, and `extra_params` pass-through.

## Testing

```bash
cd skills/external-review/server
source venv/bin/activate
pytest -v
```

34 tests covering config loading, path validation, both providers, review tool, and integration.
