"""Tests for OpenAI-compatible provider — mocked HTTP."""

import json
import pytest
import httpx

from providers.openai_compat import OpenAICompatProvider


@pytest.fixture
def provider():
    return OpenAICompatProvider(endpoint="https://api.example.com/v1", api_key="sk-test")


def mock_success_response():
    return httpx.Response(
        200,
        json={
            "choices": [{"message": {"content": "## Review Feedback\nLooks good."}}],
            "usage": {"prompt_tokens": 100, "completion_tokens": 50},
        },
    )


def mock_rate_limit_response():
    return httpx.Response(429, text="Rate limited")


def mock_auth_error_response():
    return httpx.Response(401, text="Unauthorized")


class TestOpenAICompatProvider:
    @pytest.mark.asyncio
    async def test_success(self, provider):
        transport = httpx.MockTransport(lambda req: mock_success_response())
        provider.endpoint = "https://api.example.com/v1"

        # Monkey-patch httpx.AsyncClient
        original_init = httpx.AsyncClient.__init__

        def patched_init(self_client, **kwargs):
            kwargs["transport"] = transport
            original_init(self_client, **kwargs)

        httpx.AsyncClient.__init__ = patched_init
        try:
            result = await provider.review("content", "prompt", "test-model")
            assert result.status == "success"
            assert "Review Feedback" in result.response
            assert result.tokens_used["input"] == 100
            assert result.tokens_used["output"] == 50
            assert result.latency_ms >= 0
        finally:
            httpx.AsyncClient.__init__ = original_init

    @pytest.mark.asyncio
    async def test_auth_error_no_retry(self, provider):
        call_count = 0

        def handler(req):
            nonlocal call_count
            call_count += 1
            return mock_auth_error_response()

        transport = httpx.MockTransport(handler)
        original_init = httpx.AsyncClient.__init__

        def patched_init(self_client, **kwargs):
            kwargs["transport"] = transport
            original_init(self_client, **kwargs)

        httpx.AsyncClient.__init__ = patched_init
        try:
            result = await provider.review(
                "content", "prompt", "test-model",
                settings={"_retry_attempts": 2}
            )
            assert result.status == "error"
            assert "401" in result.error
            assert call_count == 1  # No retries for auth errors
        finally:
            httpx.AsyncClient.__init__ = original_init

    @pytest.mark.asyncio
    async def test_rate_limit_retries(self, provider):
        call_count = 0

        def handler(req):
            nonlocal call_count
            call_count += 1
            if call_count < 3:
                return mock_rate_limit_response()
            return mock_success_response()

        transport = httpx.MockTransport(handler)
        original_init = httpx.AsyncClient.__init__

        def patched_init(self_client, **kwargs):
            kwargs["transport"] = transport
            original_init(self_client, **kwargs)

        httpx.AsyncClient.__init__ = patched_init
        try:
            result = await provider.review(
                "content", "prompt", "test-model",
                settings={"_retry_attempts": 3}
            )
            assert result.status == "success"
            assert call_count == 3
        finally:
            httpx.AsyncClient.__init__ = original_init

    @pytest.mark.asyncio
    async def test_extra_params_passed(self, provider):
        captured_body = {}

        def handler(req):
            captured_body.update(json.loads(req.content))
            return mock_success_response()

        transport = httpx.MockTransport(handler)
        original_init = httpx.AsyncClient.__init__

        def patched_init(self_client, **kwargs):
            kwargs["transport"] = transport
            original_init(self_client, **kwargs)

        httpx.AsyncClient.__init__ = patched_init
        try:
            await provider.review(
                "content", "prompt", "test-model",
                extra_params={"min_p": 0.01, "top_k": 50}
            )
            assert captured_body.get("min_p") == 0.01
            assert captured_body.get("top_k") == 50
        finally:
            httpx.AsyncClient.__init__ = original_init

    @pytest.mark.asyncio
    async def test_timeout(self, provider):
        def handler(req):
            raise httpx.ReadTimeout("timeout")

        transport = httpx.MockTransport(handler)
        original_init = httpx.AsyncClient.__init__

        def patched_init(self_client, **kwargs):
            kwargs["transport"] = transport
            original_init(self_client, **kwargs)

        httpx.AsyncClient.__init__ = patched_init
        try:
            result = await provider.review(
                "content", "prompt", "test-model",
                settings={"_retry_attempts": 0}
            )
            assert result.status == "error"
            assert "timed out" in result.error.lower()
        finally:
            httpx.AsyncClient.__init__ = original_init
