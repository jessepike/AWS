---
type: "prompt"
description: "Stage entry prompt — initiates Discover stage for new projects"
version: "1.1.0"
updated: "2026-02-02"
scope: "discover"
usage: "Run at start of new project to begin Discover stage"
---

# Start Discover Stage

## Purpose

Initiate Discover stage for a new project. Validates project setup, updates state, loads context, and begins exploration phase.

---

## Prompt

```
You are starting the Discover stage for a new project.

## Step 1: Validate Project Setup

Verify basic project structure exists:
- Project directory created
- `status.md` exists (may be minimal/stub)
- `CLAUDE.md` OR `AGENTS.md` exists (context file)

If missing:
- STOP
- Report what's missing
- Instruct user to run project initialization first

If present, continue to Step 2.

## Step 2: Update State

Update `status.md`:
- stage: discover
- phase: exploration
- last_action: "Started Discover stage"
- next_steps: "Begin exploration — gathering ideas, context, constraints"

## Step 3: Load Context

Read and internalize:
- `~/code/_shared/adf/ADF-DISCOVER-SPEC.md` — Stage workflow and requirements
- `~/code/_shared/adf/ADF-BRIEF-SPEC.md` — What the Brief will contain
- `~/code/_shared/adf/ADF-INTENT-SPEC.md` — What Intent.md should capture
- Any existing project notes or context the user has shared

## Step 4: Begin Exploration Phase

You are now in the Exploration phase — the divergent brainstorming stage.

**Your goal:** Gather the puzzle pieces. Understand the problem space.

**Activities:**
- Brainstorm with the user (conversational, broad)
- Research prior art, competitors, adjacent solutions if helpful
- Capture rough notes, questions, possibilities
- Identify constraints and dependencies
- Ask clarifying questions to understand:
  - What problem are we solving?
  - Who is this for?
  - What does success look like?
  - What are the constraints? (time, budget, tech, scope)
  - What's in scope vs out of scope?

**Agent role:** Conversational partner. Ask clarifying questions. Surface considerations. Don't structure yet — let ideas flow.

**Human role:** Provide direction, domain knowledge, gut instincts. Follow interesting threads.

**Phase exit signal:** Enough raw material gathered to start structuring. Human says "I think I have enough to crystallize" or agent confirms sufficient clarity to draft Brief and Intent.

Start by:
1. Asking the user to describe the project concept in their own words
2. Probing with follow-up questions to understand the problem space
3. Exploring constraints, success criteria, and scope boundaries
4. Continuing until you have enough context to move to Crystallization

When you have enough raw material, confirm: "I have enough to crystallize this into a structured Brief and Intent. Ready to move to Crystallization phase?"

## Step 5: Crystallization Phase

After exploration, synthesize raw inputs into structured artifacts:

1. **Create `docs/intent.md`**
   - Use ADF MCP tool: `mcp__adf__get_artifact_stub(artifact="intent")`
   - Fill in: Problem/Opportunity, Desired Outcome, Why It Matters
   - Keep it stable — this is your North Star

2. **Create `docs/discover-brief.md`**
   - Use ADF MCP tool: `mcp__adf__get_artifact_stub(artifact="brief")`
   - Populate all required sections per ADF-BRIEF-SPEC.md
   - Include: Classification, Scope, Success Criteria, Constraints
   - Document Open Questions that need Design stage input

3. **Update `status.md`**
   - Set phase: crystallization-complete
   - Set last_action: "Brief and Intent drafted"
   - Set next_steps: "Ready for review loop"

## Step 6: Review Loop

**CRITICAL:** After crystallization, you MUST run the review loop. This is mandatory.

### Phase 1: Internal Review (Required)

Check available skills for the review command:
- If `/adf-review:artifact` is available → Use it for full 2-phase review
- If `/adf-review:artifact-internal` is available → Use it for internal-only review
- Otherwise → Use ADF MCP tool: `mcp__adf__get_review_prompt(stage="discover", phase="internal")`

**Recommended approach:**
```
/adf-review:artifact
```

This command will:
1. Auto-detect stage (Discover) and artifact (docs/discover-brief.md)
2. Run Phase 1 internal review via Ralph Loop
3. Run Phase 2 external review (if user approves)
4. Log observations to KB for continuous improvement

**Manual alternative** (if command unavailable):
- Get prompt: `mcp__adf__get_review_prompt(stage="discover", phase="internal")`
- Run Ralph Loop with the prompt
- Iterate until no Critical/High issues remain

### Phase 2: External Review (User-Driven)

If using `/adf-review:artifact`, Phase 2 happens automatically after Phase 1.

If running manually:
- Get prompt: `mcp__adf__get_review_prompt(stage="discover", phase="external")`
- User submits to external models (GPT, Gemini)
- Integrate feedback and address High-priority issues

## Step 7: Finalization

After review loop completes:

1. **Verify exit criteria**
   - Use ADF MCP tool: `mcp__adf__check_project_health()`
   - All required artifacts exist
   - No Critical/High issues remain
   - Open questions resolved or deferred to Design

2. **Update `status.md`**
   - Set phase: complete
   - Set stage_completion_date
   - Document handoff to Design

3. **Get user sign-off**
   - Confirm Brief is ready for Design stage
   - Obtain explicit approval to proceed

When complete, the user is ready to start Design stage.
```

---

## Notes

- Discover is the entry point — no prior stage to validate
- Project initialization should create minimal status.md + CLAUDE.md stubs
- Exploration phase is conversational and exploratory — no structure yet
- Crystallization creates Intent.md and discover-brief.md
- **Review is mandatory** — always use `/adf-review:artifact` if available
- External review (Phase 2) is user-driven but recommended for quality
- Tools discovery: Check available skills before asking "what do I do?"
