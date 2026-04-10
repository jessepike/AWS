# External Review Comparison

**Date:** 2026-01-27
**Reviewers:** Gemini Pro, GPT 5.2
**Subject:** Portfolio Website Brief (post-Ralph)

---

## Key Finding

**Ralph addressed structural completeness. External reviewers found strategic coherence issues.**

Ralph caught missing sections and vague language. Gemini and GPT caught misalignments between Intent and Brief, unstated assumptions about content readiness, and conflicts between stated goals.

---

## Issues by Category

### 1. Intent/Brief Misalignment (Ralph missed, externals caught)

| Issue | Source | Impact |
|-------|--------|--------|
| Conversion path misalignment — Intent mentions "inbound inquiries" but Contact form is out of scope | Gemini | High |
| Brief/Intent mismatch on "downloadable resources" — Intent says platform provides them, Brief puts them out of scope | GPT | High |
| Audience definition in Intent not carried into Brief's success criteria | GPT | Medium |

**Why Ralph missed this:** Ralph reviewed the Brief in isolation. It didn't cross-reference Intent. The prompt didn't instruct it to check artifact alignment.

### 2. Subjective Success Criteria (Ralph partially caught, externals reinforced)

| Issue | Source | Impact |
|-------|--------|--------|
| "Shareable with confidence (professional appearance)" is subjective | Both | Low-Med |

**Note:** Ralph caught the original "looks professional" and replaced it with metrics. But the replacement still included one subjective criterion that both external reviewers flagged.

### 3. Technical Decision Conflicts (Ralph missed, externals caught)

| Issue | Source | Impact |
|-------|--------|--------|
| Plausible Analytics cost conflicts with "free tier preferred" constraint | Both | Low-Med |
| Hosting decision ambiguous (Vercel vs Railway split) for "standalone" MVP | GPT | Medium |

**Why Ralph missed this:** Ralph wasn't instructed to validate technical decisions against constraints. It focused on structural completeness, not internal consistency of specifics.

### 4. Underspecified Concepts (Ralph missed, externals caught)

| Issue | Source | Impact |
|-------|--------|--------|
| "Agent-first architecture" is a goal but operationally undefined | GPT | Medium |
| "Writing/Blog" scope boundary is broad, could expand silently | GPT | Low |
| "Projects" outcomes lack definition of evidence level | GPT | Low |

**Why Ralph missed this:** These require domain knowledge and forward-thinking about implementation. Ralph checked if sections existed, not if they were sufficient for downstream use.

### 5. Audience/Design Tension (Ralph missed, externals caught)

| Issue | Source | Impact |
|-------|--------|--------|
| "Zed IDE-inspired" aesthetic may conflict with executive target audience | Gemini | Medium |

**Why Ralph missed this:** This requires understanding audience psychology and design implications — not a structural issue.

---

## What Ralph Did Well

1. **Structural completeness** — Added missing Constraints, Assumptions sections
2. **Vague → Measurable** — Converted "nice looking" to specific metrics
3. **Issue logging discipline** — Clean audit trail of changes
4. **Appropriate P2 deferrals** — Didn't over-fix; left Design-appropriate items open

---

## What Ralph Missed (Pattern Analysis)

| Gap Type | Examples | Root Cause |
|----------|----------|------------|
| Cross-artifact alignment | Intent/Brief mismatch | Prompt didn't include Intent; single-document focus |
| Constraint/decision consistency | Analytics cost vs free tier | Prompt didn't instruct technical validation |
| Downstream usability | "Agent-first" undefined | Structural check ≠ semantic sufficiency |
| Audience-aware critique | Design vs executive tension | Requires domain reasoning beyond checklist |

---

## Recommendations for ACM Review Loop

### 1. Two-Phase Review

**Phase 1: Ralph (structural)**
- Completeness, measurability, section population
- Fast, automated, handles the grind

**Phase 2: External (strategic)**
- Cross-artifact alignment
- Constraint consistency
- Downstream usability
- Audience/market fit

### 2. Update Ralph Prompt

Add to review criteria:
- "Cross-reference Intent — do Brief outcomes align with Intent's stated goals?"
- "Validate technical decisions against Constraints — any conflicts?"
- "For each underspecified term, ask: would Design/Develop know what to do with this?"

### 3. External Review Focus Areas

When sending to GPT/Gemini, explicitly request:
- Intent/Brief alignment check
- Constraint/decision consistency
- Downstream usability assessment
- Blind spots a single model might miss

---

## Verdict

**Ralph is necessary but not sufficient.**

Use Ralph for structural iteration (fast, cheap, handles repetitive improvement). Use external models for strategic review (catches coherence issues, cross-artifact alignment, domain-specific blind spots).

**Proposed flow:**
```
Draft Brief
    ↓
Ralph Loop (2-5 iterations)
    ↓
P1s resolved, structure solid
    ↓
External Review (GPT + Gemini)
    ↓
Integrate feedback
    ↓
Final human sign-off
    ↓
Exit Discover
```

---

## Action Items

- [ ] Update Ralph prompt with cross-artifact and constraint validation
- [ ] Create external review prompt template (focused on strategic issues)
- [ ] Update ACM-DISCOVER-SPEC with two-phase review guidance
- [ ] Resolve issues flagged by external reviewers on this Brief
