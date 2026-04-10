"""OpenAI-compatible provider (Kimi K2, DeepSeek, Together, etc.)."""

import asyncio
import random
import time

import httpx

from .base import BaseProvider, ReviewResponse

RETRYABLE_STATUS_CODES = {429, 500, 502, 503, 504}
MAX_RETRY_TOTAL_SECONDS = 60


class OpenAICompatProvider(BaseProvider):
    """Provider for OpenAI-compatible chat completion APIs."""

    async def review(
        self,
        artifact_content: str,
        prompt: str,
        model: str,
        settings: dict | None = None,
        extra_params: dict | None = None,
        pricing: dict | None = None,
    ) -> ReviewResponse:
        settings = settings or {}
        extra_params = extra_params or {}
        retry_attempts = settings.pop("_retry_attempts", 2)
        timeout_seconds = settings.pop("_timeout_seconds", 120)

        body = {
            "model": model,
            "messages": [
                {"role": "system", "content": prompt},
                {"role": "user", "content": artifact_content},
            ],
            **{k: v for k, v in settings.items() if k in ("temperature", "max_tokens", "top_p")},
            **extra_params,
        }

        start = time.monotonic()
        last_error = None
        retry_start = time.monotonic()

        for attempt in range(retry_attempts + 1):
            if attempt > 0:
                if time.monotonic() - retry_start > MAX_RETRY_TOTAL_SECONDS:
                    break
                delay = min(2 ** attempt + random.uniform(0, 1), 30)
                await asyncio.sleep(delay)

            try:
                async with httpx.AsyncClient(timeout=timeout_seconds) as client:
                    resp = await client.post(
                        f"{self.endpoint}/chat/completions",
                        headers={
                            "Authorization": f"Bearer {self.api_key}",
                            "Content-Type": "application/json",
                        },
                        json=body,
                    )

                if resp.status_code == 200:
                    data = resp.json()
                    usage = data.get("usage", {})
                    tokens = {
                        "input": usage.get("prompt_tokens", 0),
                        "output": usage.get("completion_tokens", 0),
                    }
                    return ReviewResponse(
                        status="success",
                        response=data["choices"][0]["message"]["content"],
                        tokens_used=tokens,
                        latency_ms=int((time.monotonic() - start) * 1000),
                        retries_attempted=attempt,
                        cost_usd=ReviewResponse.calculate_cost(tokens, pricing),
                    )

                if resp.status_code in RETRYABLE_STATUS_CODES:
                    last_error = f"HTTP {resp.status_code}"
                    continue

                # Non-retryable error
                return ReviewResponse(
                    status="error",
                    error=f"HTTP {resp.status_code}: {resp.text[:200]}",
                    latency_ms=int((time.monotonic() - start) * 1000),
                    retries_attempted=attempt,
                )

            except httpx.TimeoutException:
                last_error = "Request timed out"
                continue
            except httpx.HTTPError as e:
                last_error = str(e)
                continue

        return ReviewResponse(
            status="error",
            error=last_error or "Unknown error",
            latency_ms=int((time.monotonic() - start) * 1000),
            retries_attempted=retry_attempts,
        )

    async def health_check(self) -> bool:
        try:
            async with httpx.AsyncClient(timeout=10) as client:
                resp = await client.get(
                    f"{self.endpoint}/models",
                    headers={"Authorization": f"Bearer {self.api_key}"},
                )
                return resp.status_code == 200
        except httpx.HTTPError:
            return False
