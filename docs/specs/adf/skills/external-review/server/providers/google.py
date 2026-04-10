"""Google Generative AI provider (Gemini)."""

import asyncio
import random
import time

import httpx

from .base import BaseProvider, ReviewResponse

RETRYABLE_STATUS_CODES = {429, 500, 502, 503, 504}
MAX_RETRY_TOTAL_SECONDS = 60


class GoogleProvider(BaseProvider):
    """Provider for Google Generative AI (Gemini) API."""

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

        generation_config = {}
        if "temperature" in settings:
            generation_config["temperature"] = settings["temperature"]
        if "max_tokens" in settings:
            generation_config["maxOutputTokens"] = settings["max_tokens"]
        generation_config.update(extra_params)

        body = {
            "system_instruction": {"parts": [{"text": prompt}]},
            "contents": [{"parts": [{"text": artifact_content}]}],
        }
        if generation_config:
            body["generationConfig"] = generation_config

        url = f"{self.endpoint}/models/{model}:generateContent?key={self.api_key}"

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
                        url,
                        headers={"Content-Type": "application/json"},
                        json=body,
                    )

                if resp.status_code == 200:
                    data = resp.json()
                    candidates = data.get("candidates", [])
                    text = ""
                    if candidates:
                        parts = candidates[0].get("content", {}).get("parts", [])
                        text = "".join(p.get("text", "") for p in parts)

                    usage = data.get("usageMetadata", {})
                    tokens = {
                        "input": usage.get("promptTokenCount", 0),
                        "output": usage.get("candidatesTokenCount", 0),
                    }
                    return ReviewResponse(
                        status="success",
                        response=text,
                        tokens_used=tokens,
                        latency_ms=int((time.monotonic() - start) * 1000),
                        retries_attempted=attempt,
                        cost_usd=ReviewResponse.calculate_cost(tokens, pricing),
                    )

                if resp.status_code in RETRYABLE_STATUS_CODES:
                    last_error = f"HTTP {resp.status_code}"
                    continue

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
                    f"{self.endpoint}/models?key={self.api_key}",
                )
                return resp.status_code == 200
        except httpx.HTTPError:
            return False
