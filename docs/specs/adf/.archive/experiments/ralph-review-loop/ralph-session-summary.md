# Ralph Loop Session Summary

**Purpose:** Share with external agents for comparison and follow-up review.

---

## What Ralph Did

**Input:** Intentionally weak Brief with vague problem, subjective success criteria, no constraints.

**Process:** 2 iterations of self-review using ACM's review criteria.

**Output:** Improved Brief with measurable criteria, explicit constraints, documented assumptions.

---

## Issues Found (Iteration 1)

| # | Issue | Impact | Priority |
|---|-------|--------|----------|
| 1 | Problem statement too vague — "showcase my work" doesn't specify what work or for whom | High | P1 |
| 2 | Desired outcome unverifiable — "nice looking" is subjective | High | P1 |
| 3 | Success criteria not measurable — "looks professional" cannot be objectively assessed | High | P1 |
| 4 | No assumptions section — unstated assumptions create risk | High | P1 |
| 5 | Scope items lack detail — pages listed but behaviors undefined | Med | P2 |
| 6 | Open questions are blockers — tech stack and hosting are prerequisites | Med | P2 |
| 7 | No constraints identified — unrealistic for any project | Med | P2 |

---

## Changes Made (Iteration 1 → 2)

### Problem Statement
**Before:** "I need a website to showcase my work."

**After:** "I am a software developer/designer seeking new opportunities. Potential employers and clients have no central place to evaluate my skills, past projects, or professional background. Without a portfolio, I rely on LinkedIn and resume PDFs, which don't demonstrate my actual work."

### Desired Outcome
**Before:** "A nice looking portfolio site."

**After:**
- Presents my professional identity and background
- Showcases 3-6 completed projects with descriptions and visuals
- Provides a way for visitors to contact me
- Functions as a credibility signal when applying for roles or contracts

### Success Criteria
**Before:**
- Looks professional
- Works on mobile
- Easy to update

**After:**
- Site loads in under 3 seconds on mobile (3G)
- All pages responsive at 320px, 768px, and 1200px breakpoints
- Projects display with title, description, tech stack, and at least one image/screenshot
- Contact form submits successfully and delivers message to owner
- Site passes Lighthouse accessibility score of 90+
- New project can be added by editing a single file (no code changes to templates)

### Added Sections

**Constraints:**
- Budget: $0 for hosting (use free tier services)
- Timeline: MVP within 1 week
- Tech skills: Owner comfortable with HTML/CSS/JS, familiar with React
- Maintenance: Owner will maintain; no handoff to non-technical person

**Assumptions:**
- Owner already has a domain or will acquire one
- Owner has 3-6 projects ready to showcase (content exists)
- Target audience: Tech recruiters, hiring managers, potential clients
- English-language only (no i18n required for MVP)

---

## Issues Left Open (for Design)

| # | Issue | Priority | Note |
|---|-------|----------|------|
| 5 | Scope items lack detail | P2 | Pages listed but behaviors undefined |
| 6 | Open questions are blockers | P2 | Tech stack and hosting still TBD |
| 8 | Constraints vs Open Questions inconsistency | P2 | React mentioned in constraints but listed as open question |

---

## Exit Criteria Check (Iteration 2)

- [x] All required sections populated
- [x] Project classification assigned (App + personal + mvp + standalone)
- [x] Scope boundaries explicit (in/out clear)
- [x] Success criteria verifiable (quantified metrics)
- [x] No P1 issues open
- [x] No internal contradictions (minor inconsistency noted as P2)

---

## For External Reviewers

**Request:** Review the final Brief (test-brief.md) and identify:
1. Issues Claude missed
2. Areas where Claude was too lenient
3. Gaps that would cause problems in Design/Develop
4. Whether P2 deferrals are appropriate or should be P1s

**Comparison focus:** Does single-model self-review produce sufficient quality, or are there blind spots only external perspective catches?
