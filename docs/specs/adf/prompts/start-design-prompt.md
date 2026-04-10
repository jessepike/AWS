---
type: "prompt"
description: "Stage transition prompt — validates Discover completion and initiates Design stage"
version: "1.0.0"
updated: "2026-01-28"
scope: "design"
usage: "Run at start of Design stage to transition from Discover"
---

# Start Design Stage

## Purpose

Transition from Discover to Design. Validates prerequisites, updates state, loads context, and begins intake clarification.

---

## Prompt

```
You are transitioning this project from Discover to Design stage.

## Step 1: Validate Prerequisites

Read and verify:
- `status.md` — Confirm stage is Discover and phase is complete
- `discover-brief.md` — Confirm status is `complete` and no open P1 issues in Issue Log

If prerequisites are NOT met:
- STOP
- Report what's missing or incomplete
- Do not proceed until Discover exit criteria are satisfied

If prerequisites ARE met, continue to Step 2.

## Step 2: Update State

Update `status.md`:
- stage: design
- phase: intake
- last_action: "Transitioned from Discover"
- next_steps: "Begin intake clarification"

## Step 3: Load Context

Read and internalize:
- `discover-brief.md` — Your primary input (the "what")
- `~/code/_shared/adf/ADF-DESIGN-SPEC.md` — Stage workflow and requirements
- Note the project classification (type + modifiers) from Brief

Based on project type, identify required Design outputs:
- **All types:** Summary, Capabilities, Interface & Format, Decision Log, Backlog
- **App:** + Architecture, Tech Stack, Data Model, Security
- **Workflow:** + Orchestration, Integration Points, Data Flow, Error Handling, Triggers
- **Artifact:** + Format Specification, Content Outline, Source Materials

## Step 4: Begin Intake

You are now in the Intake & Clarification phase.

Your goal: Resolve all ambiguities and gather decisions needed to draft design.md.

Follow the intake questioning approach:
- Ask batched questions (2-4 at a time)
- Cover: Brief interpretation, ambiguity resolution, technical preferences, constraint clarification, proactive recommendations, risk surfacing, prioritization, capabilities
- Do NOT ask about timeline/effort estimation
- Continue until you have enough clarity to draft

Start by:
1. Summarizing your understanding of the Brief (2-3 sentences)
2. Stating what Design outputs will be required based on project type
3. Asking your first batch of clarifying questions

When you have enough to proceed, confirm: "I have what I need to draft the design specification."
```

---

## Notes

- Intent.md is already loaded via Context File (CLAUDE.md/AGENTS.md) — no need to explicitly read it
- This prompt replaces the need for a shell script — validation is semantic (agent work)
- After intake is complete, agent moves to Technical Design phase
