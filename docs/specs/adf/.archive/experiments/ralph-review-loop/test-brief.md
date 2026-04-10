---
type: "brief"
project: "Portfolio Website"
version: "0.1"
status: "complete"
created: "2026-01-27"
updated: "2026-01-27"
---

# Brief: Portfolio Website

## Classification

**Type:** App
**Scale:** personal
**Scope:** mvp
**Complexity:** standalone

## Problem Statement

I am a software developer/designer seeking new opportunities. Potential employers and clients have no central place to evaluate my skills, past projects, or professional background. Without a portfolio, I rely on LinkedIn and resume PDFs, which don't demonstrate my actual work.

## Desired Outcome

A personal portfolio website that:
- Presents my professional identity and background
- Showcases 3-6 completed projects with descriptions and visuals
- Provides a way for visitors to contact me
- Functions as a credibility signal when applying for roles or contracts

## Scope

### In Scope

- Homepage
- Projects page
- Contact form

### Out of Scope

- Blog
- E-commerce

## Success Criteria

- [ ] Site loads in under 3 seconds on mobile (3G)
- [ ] All pages responsive at 320px, 768px, and 1200px breakpoints
- [ ] Projects display with title, description, tech stack, and at least one image/screenshot
- [ ] Contact form submits successfully and delivers message to owner
- [ ] Site passes Lighthouse accessibility score of 90+
- [ ] New project can be added by editing a single file (no code changes to templates)

## Constraints

- Budget: $0 for hosting (use free tier services)
- Timeline: MVP within 1 week
- Tech skills: Owner comfortable with HTML/CSS/JS, familiar with React
- Maintenance: Owner will maintain; no handoff to non-technical person

## Assumptions

- Owner already has a domain or will acquire one
- Owner has 3-6 projects ready to showcase (content exists)
- Target audience: Tech recruiters, hiring managers, potential clients
- English-language only (no i18n required for MVP)

## Open Questions

- What technology to use?
- Where to host?

---

## Issue Log

| # | Issue | Source | Impact | Priority | Status | Resolution |
|---|-------|--------|--------|----------|--------|------------|
| 1 | Problem statement too vague — "showcase my work" doesn't specify what work or for whom | Ralph-Review | High | P1 | Resolved | Expanded to specify developer seeking opportunities, target audience |
| 2 | Desired outcome unverifiable — "nice looking" is subjective | Ralph-Review | High | P1 | Resolved | Replaced with specific deliverables and functions |
| 3 | Success criteria not measurable — "looks professional" cannot be objectively assessed | Ralph-Review | High | P1 | Resolved | Replaced with quantifiable criteria (load time, breakpoints, Lighthouse) |
| 4 | No assumptions section — unstated assumptions create risk | Ralph-Review | High | P1 | Resolved | Added Assumptions section with 4 explicit assumptions |
| 5 | Scope items lack detail — pages listed but behaviors undefined | Ralph-Review | Med | P2 | Open | - |
| 6 | Open questions are blockers — tech stack and hosting are prerequisites, not nice-to-haves | Ralph-Review | Med | P2 | Open | - |
| 7 | No constraints identified — unrealistic for any project | Ralph-Review | Med | P2 | Resolved | Added Constraints section with budget, timeline, skills, maintenance |
| 8 | Open Questions vs Constraints inconsistency — tech stack mentioned in constraints but listed as open question | Ralph-Review | Low | P2 | Open | Note for Design: clarify if React is decided or still open |
| 9 | Review loop complete — all exit criteria met | Ralph-Review | - | - | Complete | Brief ready for Design phase |

---

## Session State

**Phase:** Review Loop
**Last Action:** Iteration 2 — all exit criteria verified; Brief marked complete
**Next Steps:** Proceed to Design phase
