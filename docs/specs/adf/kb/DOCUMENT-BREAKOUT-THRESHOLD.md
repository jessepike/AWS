---
type: "knowledge-base"
description: "Research findings on optimal document length for LLM processing and human readability"
version: "1.0.0"
created: "2026-01-27"
updated: "2026-01-27"
scope: "adf"
lifecycle: "reference"
tags: ["context-management", "document-structure", "llm-optimization"]
---

# Document Breakout Threshold

## Summary

**Recommended threshold: 500 lines of Markdown**

When a document exceeds 500 lines, split it into a parent overview (~100-200 lines) plus child documents (each under 500 lines).

---

## The Number

| Metric | Value |
|--------|-------|
| Lines | 500 |
| Words | ~2,000-2,500 |
| Tokens | ~3,000-3,500 |
| Pages | ~5-6 printed |

---

## Why 500 Lines

### LLM Context Efficiency

Research shows LLM performance degrades well before hitting advertised context limits:

- **Context rot**: Claude models begin "fading beyond 8,000 words" (~10,000-12,000 tokens), with accuracy dropping ~30% when adding full conversation history versus focused context
- **Lost in the middle**: Information in the middle of long contexts is retrieved less reliably than information at the beginning or end
- **RAG chunking**: Optimal retrieval chunks are 512-1024 tokens for technical documentation

500 lines at ~3,500 tokens sits in the **reliable zone** where:
- Document can be processed as single context without retrieval
- Avoids "lost in the middle" degradation
- Multiple related documents can be loaded together without hitting effective limits

### Human Cognitive Load

- Working memory handles 4-5 items simultaneously
- Major sections should contain 500-2,000 words for comprehension
- 500 lines maps to ~4-6 major sections of 80-125 lines — matches cognitive chunking

### Industry Standards

| Standard | Typical Length | Equivalent Lines |
|----------|---------------|------------------|
| ADRs | 1-3 pages | ~150-450 |
| Google Design Docs | 10-20 pages | ~300-600 |
| General Tech Specs | Under 5 pages | ~150-300 |
| Complex System Specs | Varies | ~300-600 |

500 lines sits at upper boundary of simple specs, comfortable middle of complex ones.

### Why Lines (Not Words or Tokens)

| Metric | Pros | Cons |
|--------|------|------|
| Words | Human-intuitive | Ignores code blocks, tables, structure |
| Tokens | LLM-accurate | Varies by tokenizer, not human-readable |
| **Lines** | Visible in editors, git-trackable, includes structure | Depends on line wrapping |

Lines win because:
- Immediate visibility in any editor
- Git diffs are line-based — 500 lines is reviewable in one PR
- Captures structural elements (headings, code, whitespace)
- Consistent regardless of prose density

---

## Application

### Under 500 Lines

Keep everything in a single document with clear sections.

### Over 500 Lines

Create hierarchical structure:

```
design.md (100-200 lines)
├── Overview and purpose
├── Links to sub-documents
├── Decision log summary
│
├── design-architecture.md (<500 lines)
├── design-interface.md (<500 lines)
├── design-data-model.md (<500 lines)
└── design-capabilities.md (<500 lines)
```

### Why Not 300 Lines (Too Conservative)

- Forces premature fragmentation
- Increases navigation overhead
- ADRs naturally hit 200-400 lines
- Breaking out documents that don't need it

### Why Not 1000 Lines (Too Permissive)

- Exceeds ~8,000 word threshold where LLM performance degrades
- Makes PR reviews unwieldy
- Approaches cognitive overload for single-sitting comprehension
- No headroom for loading related context

---

## Sources

- Chroma — Context Rot Research (2025)
- Liu et al. — Lost in the Middle (arXiv)
- NVIDIA — Chunking Strategy Benchmark (2024)
- Firecrawl — Best Chunking Strategies for RAG (2025)
- Microsoft — ADR Best Practices
- Google — Design Docs at Google
- Stack Overflow — Writing Technical Specs
- Cognitive Load Theory in Technical Writing

---

## ADF Usage

This threshold applies to:
- `design.md` and child specs
- `brief.md` (rarely exceeds, but applies)
- Any specification or documentation artifact

When approaching 500 lines, consider:
1. Can sections be split into referenced child documents?
2. Is there redundant content that can be removed?
3. Should this be multiple focused documents instead of one broad one?
