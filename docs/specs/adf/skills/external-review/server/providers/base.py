"""Abstract base class for LLM providers."""

from abc import ABC, abstractmethod
from dataclasses import dataclass, field


@dataclass
class ReviewResponse:
    status: str  # "success" | "error"
    response: str | None = None
    error: str | None = None
    tokens_used: dict | None = None
    latency_ms: int = 0
    retries_attempted: int = 0
    cost_usd: float | None = None

    @staticmethod
    def calculate_cost(tokens_used: dict, pricing: dict) -> float | None:
        """Calculate cost from token counts and pricing rates.

        Args:
            tokens_used: {"input": int, "output": int}
            pricing: {"input_per_1m": float, "output_per_1m": float}

        Returns:
            Cost in USD, or None if pricing data is incomplete.
        """
        if not tokens_used or not pricing:
            return None
        input_rate = pricing.get("input_per_1m")
        output_rate = pricing.get("output_per_1m")
        if input_rate is None or output_rate is None:
            return None
        input_cost = tokens_used.get("input", 0) / 1_000_000 * input_rate
        output_cost = tokens_used.get("output", 0) / 1_000_000 * output_rate
        return round(input_cost + output_cost, 6)


class BaseProvider(ABC):
    """Abstract base class for LLM providers."""

    def __init__(self, endpoint: str, api_key: str, **kwargs):
        self.endpoint = endpoint.rstrip("/")
        self.api_key = api_key

    @abstractmethod
    async def review(
        self,
        artifact_content: str,
        prompt: str,
        model: str,
        settings: dict | None = None,
        extra_params: dict | None = None,
        pricing: dict | None = None,
    ) -> ReviewResponse:
        """Send review request to provider."""
        ...

    @abstractmethod
    async def health_check(self) -> bool:
        """Verify API connectivity."""
        ...
