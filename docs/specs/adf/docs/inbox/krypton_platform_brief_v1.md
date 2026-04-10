# Krypton Platform — Product Brief v1
updated: 2026-02-05
owner: Jess
status: draft

---

## 1) What this document is

Krypton is a **personal AI chief of staff** — an always-on, autonomous agent platform that manages, organizes, and surfaces information about Jess's work and life across all domains.

Krypton is not a single tool. It is a **platform** composed of a gateway, channel adapters, skills, memory, a tool registry, and an intelligence engine. It is LLM-agnostic, channel-agnostic, and designed for increasing autonomy as trust is established.

**This brief covers:**
- System identity, vision, and role specification
- Architecture (gateway-centric, inspired by OpenClaw patterns)
- Channel strategy (multi-platform communication)
- Skills and tool registry
- Memory and knowledge systems
- Autonomy model (configurable trust levels)
- Intelligence capabilities
- Capture patterns
- Agent-to-agent protocol
- MVP scope and sequencing

**Related document:** Work OS Brief v5 (the operational data layer Krypton operates on)

---

## 2) North Star vision (12–24 months)

### What fully-realized Krypton does

**You wake up.** Krypton has already prepared your daily focus — not just a list, but an intelligent assessment. It knows you've been heads-down on Krypton dev for 3 days and Papa Dogs inventory ordering is overdue. It knows Fletcher hasn't updated his TCDC deliverable in a week. It knows your AI Risk Tools demo is in 10 days and the auth module is blocked. It tells you what matters, in priority order, with recommended actions.

**During the day.** You're on a call and someone mentions "we should look into X." You tell Krypton via iMessage. It captures X to the right project's backlog, triages it against existing priorities, and you never think about it again until Krypton surfaces it at the right time.

**You ask "where are we?"** At any scope — portfolio, project, category — and get an accurate, intelligent answer in seconds. Not just data. Insight. "Krypton dev is on track but Phase 3 has two blocked tasks that depend on the MCP auth work. If you unblock that today, everything downstream stays on schedule."

**Agents finish work.** Krypton notices via connectors to Work OS. It updates its mental model, adjusts priorities, and tells you in your next interaction without you asking.

**You get a disorganized status update from Brennan via Slack.** Krypton reads it, extracts actionable items, updates the relevant project tasks in Work OS, and gives you a clean summary: "Brennan completed the site survey and flagged 2 issues. I've updated TCDC tasks and added the issues to backlog as P2."

**End of week.** Krypton delivers a chief-of-staff briefing via your preferred channel. Wins, risks, recommendations. You share a scoped snippet with collaborators.

**Always running.** Krypton isn't waiting for you to type. It's monitoring, organizing, triaging, analyzing — acting within its autonomy boundaries — and surfacing what matters when you're ready to engage.

### What makes this different

Traditional AI assistants are **stateless, passive, and single-channel.** They answer when asked, forget between sessions, and live in one interface.

Krypton is **persistent, proactive, and omni-channel.** It maintains continuous context, acts autonomously within defined boundaries, and meets you wherever you are — Claude Desktop, Slack, Discord, Telegram, iMessage, mobile.

The intelligence layer is what separates Krypton from a chatbot with tools. Krypton doesn't just retrieve and display. It **reasons across your entire work context** — detecting patterns, identifying friction, anticipating needs, and making recommendations informed by history.

---

## 3) Role specification

### Identity
Krypton is an AI chief of staff responsible for operational oversight across all of Jess's work and personal domains.

### Core responsibilities

| Area | What Krypton does |
|---|---|
| **Awareness** | Maintains comprehensive, current understanding of all projects, tasks, deadlines, owners, blockers, and priorities via Work OS and other data sources |
| **Intelligence** | Detects patterns, identifies risks, spots friction, analyzes velocity, recognizes bottlenecks before they become critical |
| **Organization** | Triages incoming work, maintains priority accuracy, suggests sequencing, keeps Work OS data clean and current |
| **Communication** | Delivers digests, answers questions, provides recommendations, generates shareable reports — all in clear, concise, actionable language |
| **Capture** | Ingests work items from any input channel with minimal friction and routes them to Work OS |
| **Facilitation** | Helps make better decisions by presenting options, tradeoffs, and recommendations with supporting evidence |
| **Coordination** | Communicates with other agents (ADF orchestrator, future domain agents) to gather status, delegate work, and monitor completion |

---

## 4) Architecture

### Design principles (OpenClaw-inspired, custom-built)

| Principle | Source | Krypton adaptation |
|---|---|---|
| Gateway-centric | OpenClaw | Single long-running service as control plane. All channels and tools connect through it. |
| Channel adapters | OpenClaw | Unified message format internally. Platform-specific adapters handle translation. |
| Skills as modular capabilities | OpenClaw (AgentSkills standard) | Each tool/integration is a skill. Work OS, KB, browser, calendar — all pluggable. |
| Heartbeat / cron | OpenClaw | Proactive scheduled tasks: digest generation, health monitoring, backlog triage, follow-up checks. |
| LLM-agnostic | OpenClaw Model Resolver | Model selection per-task or per-session. Claude, GPT, Gemini, local models. Failover and key rotation. |
| Persistent memory | OpenClaw workspace | Daily memory logs, long-term curated memory, session context. |
| Serial-by-default execution | OpenClaw Lane Queue | Prevents race conditions. Explicit parallelism only for safe operations. |
| Security-first | Krypton-specific (diverges from OpenClaw) | Sandboxing, allowlisting, configurable autonomy, credential management, audit trail. |

### Component overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                       INPUT CHANNELS                                │
│  Claude Desktop │ ChatGPT │ Gemini │ Slack │ Discord │ Telegram    │
│  iMessage │ Mobile (future) │ Voice (future) │ Email (future)      │
└─────────────────────────────┬───────────────────────────────────────┘
                              │ (unified message format)
                              ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      KRYPTON GATEWAY                                │
│                   (long-running service)                             │
│                                                                     │
│  ┌───────────┐ ┌───────────┐ ┌───────────┐ ┌────────────────────┐ │
│  │ Channel   │ │ Message   │ │ Session   │ │ Heartbeat /        │ │
│  │ Router    │ │ Queue     │ │ Manager   │ │ Cron Scheduler     │ │
│  └───────────┘ └───────────┘ └───────────┘ └────────────────────┘ │
│                                                                     │
│  ┌───────────┐ ┌───────────┐ ┌───────────┐ ┌────────────────────┐ │
│  │ Model     │ │ Skill     │ │ Memory    │ │ Autonomy           │ │
│  │ Resolver  │ │ Router    │ │ Manager   │ │ Governor           │ │
│  └───────────┘ └───────────┘ └───────────┘ └────────────────────┘ │
└─────────────────────────────┬───────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────┐
│                         SKILLS LAYER                                │
│                                                                     │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐             │
│  │ Work OS  │ │ Knowledge│ │ Browser  │ │ Calendar │             │
│  │ (MCP)    │ │ Base     │ │ (Chrome) │ │          │             │
│  │          │ │ (MCP)    │ │          │ │          │             │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘             │
│                                                                     │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐             │
│  │ Email    │ │ Agent    │ │ File     │ │ Custom   │             │
│  │          │ │ Comms    │ │ System   │ │ Skills   │             │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘             │
└─────────────────────────────────────────────────────────────────────┘
```

### Gateway components

| Component | Purpose |
|---|---|
| **Channel Router** | Routes inbound messages from any platform to the processing pipeline. Maps channels to sessions. |
| **Message Queue** | Serial-by-default execution. Prevents race conditions. Explicit parallel lanes for safe operations. |
| **Session Manager** | Maintains conversation state per channel/user. Handles context windowing and history. |
| **Heartbeat / Cron** | Scheduled proactive tasks: digest generation, health monitoring, follow-up checks, backlog triage. |
| **Model Resolver** | Selects LLM per-task. Handles failover, key rotation, rate limiting. Provider-agnostic. |
| **Skill Router** | Matches intent to available skills. Routes tool calls to the correct skill. |
| **Memory Manager** | Loads/saves session memory, daily logs, long-term curated memory. |
| **Autonomy Governor** | Enforces trust levels. Checks every action against configurable autonomy rules before execution. |

---

## 5) Channel strategy

### Principle
Krypton meets you where you are. Every channel uses the same unified message format internally. Channel-specific adapters handle platform translation (formatting, media, rate limits, etc.).

### Channel roadmap

| Channel | Type | MVP | Post-MVP | Notes |
|---|---|---|---|---|
| **Claude Desktop (MCP)** | LLM client | ✅ | ✅ | Primary dev/power-user interface |
| **Slack** | Messaging | ❌ | ✅ | Key for work communication |
| **Discord** | Messaging | ❌ | ✅ | Existing Krypton channel |
| **Telegram** | Messaging | ❌ | ✅ | Existing Krypton channel |
| **ChatGPT (MCP)** | LLM client | ❌ | ✅ | When MCP support available |
| **Gemini (MCP)** | LLM client | ❌ | ✅ | When MCP support available |
| **iMessage** | Messaging | ❌ | ✅ | Via BlueBubbles or native |
| **Mobile app** | Native | ❌ | ✅ | Push capture + notifications |
| **Voice** | Speech | ❌ | ✅ | Via Claude Desktop or mobile |
| **Email** | Async | ❌ | ✅ | Ingest forwarded emails as captures |
| **Apple Notifications** | Push | ❌ | ✅ | iPhone push notifications |
| **Web Dashboard** | Visual | ✅* | ✅ | *Dashboard is Work OS; Krypton's command bar connects through it |

### Channel adapter contract

Each adapter must:
1. Receive platform-native messages
2. Normalize to unified message format (text, attachments, metadata, sender, channel_id)
3. Forward to Gateway message queue
4. Receive response from Gateway
5. Translate back to platform-native format
6. Deliver to user

---

## 6) Skills and tool registry

### Design
Skills are modular capability packages. Each skill gives Krypton access to a specific tool or system. Skills follow the AgentSkills standard format (SKILL.md config + implementation).

### Skill registry

The tool registry is a configuration layer that defines which skills are available, active, and what permissions they have. It is stored as structured config (JSON/YAML) and is editable by the human.

| Field | Purpose |
|---|---|
| skill_id | Unique identifier |
| name | Display name |
| description | What this skill does |
| enabled | On/off toggle |
| requires_approval | Whether actions need human approval |
| config | Skill-specific settings (API endpoints, credentials ref, etc.) |
| permissions | What the skill can read/write/execute |

### Core skills (planned)

| Skill | What it does | MVP | Connects to |
|---|---|---|---|
| **Work OS** | Read/write projects, tasks, backlog, queries, digests | ✅ | Work OS REST API (via MCP) |
| **Knowledge Base** | Read/write to personal KB | ✅ | KB MCP server (existing) |
| **Browser** | Web browsing, form filling, data extraction | ❌ | Chrome CDP (Claude/Chrome browser tool) |
| **Calendar** | Read/create/modify events, check availability | ❌ | Google Calendar API or Apple Calendar |
| **Email** | Read/send/search email, extract action items | ❌ | Gmail API or IMAP |
| **File System** | Read/write local files in sandbox | ❌ | Local filesystem (sandboxed) |
| **Agent Communication** | Talk to other agents (ADF orchestrator, etc.) | ❌ | Agent protocol (see §10) |
| **Notifications** | Send push notifications | ❌ | Apple Push / platform-specific |

### Credentials management

Skills that require API keys or OAuth tokens reference credentials stored in a secure `.env` or secret manager — never inline in skill config. Krypton can read credentials at runtime but cannot display or transmit them.

---

## 7) Memory architecture

### Design
Krypton maintains persistent, structured memory across sessions. Memory is what makes Krypton *yours* — it accumulates context that makes every interaction more informed.

### Memory layers

| Layer | Scope | Persistence | Purpose |
|---|---|---|---|
| **Session memory** | Current conversation | Until session ends | Immediate conversational context |
| **Daily log** | One file per day | Permanent, prunable | Record of what happened each day |
| **Long-term memory** | Curated facts and preferences | Permanent | "Jess prefers concise updates." "Brennan handles TCDC site surveys." |
| **Work OS state** | Queried on demand | Lives in Work OS | Current project/task state (not duplicated in Krypton memory) |
| **Knowledge Base** | Queried on demand | Lives in KB | Reference material, research, saved content |

### Memory principles
- Krypton does NOT duplicate Work OS data in its own memory. It queries Work OS when it needs operational data.
- Long-term memory stores *patterns, preferences, and relationships* — not task lists.
- Daily logs auto-prune after configurable retention (e.g., 90 days).
- Memory is local-first. Stored on Krypton's host machine or in Supabase (configurable).

---

## 8) Autonomy model

### Design principle
Krypton's autonomy is **configurable via settings** — not hardcoded. Trust levels can be adjusted as performance is proven. The Autonomy Governor checks every action against the current rule set before execution.

### Trust levels

| Level | Name | Description |
|---|---|---|
| 1 | **Observer** | Read-only. Can query, analyze, report. Cannot modify anything. |
| 2 | **Advisor** | Can query, analyze, report, and recommend. All modifications require approval. |
| 3 | **Operator** | Can execute pre-approved action categories autonomously. Significant changes need approval. |
| 4 | **Autonomous** | Full autonomy within defined boundaries. Only explicitly restricted actions need approval. |

**MVP default: Level 2 (Advisor)** — escalating to Level 3 as trust is established.

### Action categories and default trust assignments

| Action category | Level 1 | Level 2 | Level 3 | Level 4 |
|---|---|---|---|---|
| Query Work OS / KB | ✅ | ✅ | ✅ | ✅ |
| Generate digests and summaries | ✅ | ✅ | ✅ | ✅ |
| Suggest priorities and next actions | ❌ | ✅ | ✅ | ✅ |
| Auto-reprioritize tasks (deadlines/blockers) | ❌ | ❌ | ✅ | ✅ |
| Flag at-risk projects | ❌ | ✅ | ✅ | ✅ |
| Create tasks / backlog items | ❌ | 🔒 | ✅ | ✅ |
| Update task status | ❌ | 🔒 | ✅ | ✅ |
| Promote backlog to task | ❌ | 🔒 | 🔒 | ✅ |
| Delegate to agents | ❌ | 🔒 | 🔒 | ✅ |
| Modify human-set deadlines | ❌ | 🔒 | 🔒 | 🔒 |
| Close / archive projects | ❌ | 🔒 | 🔒 | 🔒 |
| Send messages on behalf of Jess | ❌ | 🔒 | 🔒 | 🔒 |
| Share data with external parties | ❌ | 🔒 | 🔒 | 🔒 |
| Browse web / execute browser actions | ❌ | 🔒 | ✅ | ✅ |
| Read/send email | ❌ | 🔒 | 🔒 | ✅ |

✅ = Autonomous &nbsp;&nbsp; 🔒 = Requires approval &nbsp;&nbsp; ❌ = Not available

### Hard constraints (never autonomous, any level)

- Commit to external deliverables on behalf of Jess
- Delete data (archive only)
- Override an explicit human decision
- Transmit credentials or sensitive data
- Access systems not in the tool registry

### Settings storage

Autonomy settings stored as structured config (JSON), editable by Jess via:
- Config file on host
- Future: settings UI in dashboard
- Future: conversational adjustment ("Krypton, you can now auto-create tasks without asking")

---

## 9) Intelligence engine

### Purpose
The intelligence layer is what separates Krypton from a tool with an LLM wrapper. It reasons across the full portfolio context to detect patterns, predict risks, and generate actionable recommendations.

### Capabilities (progressive build)

| Capability | Description | MVP | Post-MVP |
|---|---|---|---|
| **Cross-project analysis** | Identify patterns across all projects (common blockers, velocity trends, resource conflicts) | ❌ | ✅ |
| **Friction detection** | Spot where work is stalling, recurring blockers, slow-moving phases | ❌ | ✅ |
| **Workload analysis** | Are you overloaded? Is work balanced across domains? What's been neglected? | ❌ | ✅ |
| **Priority intelligence** | Smart prioritization beyond simple P1/P2/P3 — considers deadlines, dependencies, project health, momentum | ✅ (basic) | ✅ (advanced) |
| **Temporal patterns** | "You do quarterly board prep — it's coming up." "You always slip deadlines in Phase 3." | ❌ | ✅ |
| **Estimation intelligence** | Compare estimated vs. actual completion times. Improve forecasting over time. | ❌ | ✅ |
| **Digest commentary** | Add Krypton observations to digests beyond raw data: "Auth module has been blocked for 5 days — consider a focused session." | ✅ (basic) | ✅ (rich) |
| **Recommendation engine** | Suggest reprioritization, sequencing changes, backlog promotions with reasoning | ❌ | ✅ |

### Implementation approach
- Intelligence is powered by LLM calls (Claude API or equivalent) against structured Work OS data
- Krypton queries Work OS, loads relevant context into prompt, asks LLM for analysis
- Results can be cached (e.g., daily analysis run) or generated on-demand
- The LLM does not have direct database access — it receives structured summaries from the API

---

## 10) Capture patterns

### Design principle
The cost of capturing a work item must approach zero. If it takes more than 10 seconds, the system will be bypassed. **Mobile is the primary on-the-fly capture method.**

### Capture channels

| Channel | How it works | MVP | Post-MVP |
|---|---|---|---|
| **MCP (Claude Desktop)** | "Add X to Project Y backlog" | ✅ | ✅ |
| **Dashboard quick-add** | Inline input, title + Enter | ✅* | ✅ |
| **Conversational aside** | "Oh, remind me to check the lease" → captured | ✅ (via MCP) | ✅ |
| **Slack** | Message Krypton in Slack | ❌ | ✅ |
| **Discord** | Message Krypton in Discord | ❌ | ✅ |
| **Telegram** | Message Krypton in Telegram | ❌ | ✅ |
| **iMessage** | Text Krypton from iPhone | ❌ | ✅ |
| **Voice** | Voice note → transcription → capture | ❌ | ✅ |
| **Email forward** | Forward email → Krypton extracts action items | ❌ | ✅ |

*Dashboard quick-add is a Work OS feature; Krypton provides the intelligent routing when connected.

### Capture processing flow

```
Raw input (any channel)
    │
    ▼
Krypton Capture Engine
    ├── Parse intent (new task? backlog item? status update? question?)
    ├── Extract: title, project, priority, deadline, owner (if present)
    ├── Infer: project (from context), priority (from urgency cues), category
    ├── Route: backlog (default) or active task (if explicitly requested)
    ├── Write to Work OS via API
    └── Confirm: brief acknowledgment with what was captured and where
```

### Default behavior
- **Unscoped items:** routed to Work OS "Inbox" project for triage
- **Default destination:** backlog (not active tasks). Promotion is deliberate.
- **Krypton confirms:** "Got it — added 'review lease terms' to Papa Dogs backlog as P2."
- **Ambiguous items:** Krypton asks one clarifying question rather than guessing wrong

### Intelligent ingestion
When Krypton receives unstructured input (e.g., a rambling status update from a collaborator), it:
1. Extracts actionable items
2. Maps them to correct projects/tasks in Work OS
3. Updates status as appropriate (within autonomy level)
4. Summarizes what it did for Jess

---

## 11) Agent-to-agent protocol (future)

### Vision
Krypton can communicate with other specialized agents to gather status, delegate work, and coordinate across systems.

### Example interactions

| Krypton → Agent | Purpose |
|---|---|
| Krypton → ADF Orchestrator | "What's the current status of the Krypton dev project? Any blockers?" |
| Krypton → Build Agent | "Deploy the latest staging build for AI Risk Tools" |
| Krypton → Research Agent | "Find the latest NIST AI RMF updates and add to KB" |

### Protocol considerations (to be designed)
- **Communication channel:** Could be MCP tool calls, Telegram messages, API calls, or a dedicated agent messaging protocol
- **Identity and auth:** Agents need to authenticate to each other
- **Intent format:** Structured requests with expected response format
- **Status tracking:** Krypton needs to track delegated work and follow up
- **Timeout and fallback:** What happens when an agent doesn't respond?

### Near-term implementation
- Start with MCP-based agent communication (Krypton calls another agent's MCP server)
- Add messaging-based communication (via Telegram/Slack) for agents that use those channels
- Eventually: standardized agent communication protocol

---

## 12) Security architecture

### Principles
Given Jess's cybersecurity background, security is a first-class concern — not an afterthought. Krypton diverges significantly from OpenClaw's security posture.

| Layer | Approach |
|---|---|
| **Sandboxing** | Krypton runs in Docker with limited host access. Skills execute in isolated environments. |
| **Credential management** | All secrets in encrypted store or .env. Never inline. Never transmittable. |
| **Skill vetting** | No auto-install of community skills. All skills manually approved. |
| **Allowlisting** | Commands, domains, APIs — all allowlisted. Default deny. |
| **Audit trail** | Every action logged. Every tool call recorded. Full traceability. |
| **Autonomy governance** | Action-level permission checks before execution (see §8). |
| **Input sanitization** | All inbound messages sanitized. Prompt injection mitigations. |
| **Network isolation** | Krypton's outbound network access is controlled and logged. |

---

## 13) Implementation sequencing

> Sequencing guidance. Work OS is built first (see Work OS Brief v5). Krypton builds on top.

### Phase 1: Gateway skeleton
- Long-running Node.js/Python service
- Session management
- Message queue (serial-by-default)
- Config loading (identity, autonomy settings, skill registry)

### Phase 2: First channel + first skill
- Claude Desktop MCP adapter (primary channel)
- Work OS skill (connects to Work OS MCP/REST API)
- Basic query + capture flow working end-to-end

### Phase 3: Memory + heartbeat
- Session memory persistence
- Daily memory log
- Long-term memory (manual curation initially)
- Heartbeat/cron: scheduled digest triggers, health checks

### Phase 4: Knowledge Base skill
- Connect to existing KB MCP server
- Read + write capabilities
- Krypton can query KB for context and add items

### Phase 5: Intelligence (basic)
- Priority intelligence in digest commentary
- Basic cross-project observations
- "What should I focus on?" powered by LLM reasoning over Work OS data

### Phase 6: Additional channels
- Slack adapter
- Discord adapter
- Telegram adapter

### Phase 7: Autonomy escalation
- Move from Level 2 (Advisor) to Level 3 (Operator) for proven action categories
- Settings UI for adjusting trust levels
- Audit review of autonomous actions

### Phase 8: Advanced capabilities
- Browser skill (Chrome CDP)
- Calendar skill
- Email skill
- Agent-to-agent communication
- Advanced intelligence (friction detection, temporal patterns, workload analysis)
- iMessage / mobile
- Voice
- Apple notifications

---

## 14) Open decisions

| # | Decision | Context | Leaning |
|---|---|---|---|
| 1 | Gateway language | Node.js (TypeScript) vs. Python | Node.js (aligns with OpenClaw patterns, real-time strengths) |
| 2 | Skill format | AgentSkills standard or custom? | AgentSkills (Anthropic standard — widely adopted) |
| 3 | Memory storage | Local files vs. Supabase vs. hybrid | Local files for MVP (simple), Supabase for persistence later |
| 4 | LLM provider for intelligence | Claude API vs. multi-provider | Claude primary, model resolver for fallback |
| 5 | Heartbeat frequency | Every 15 min? Hourly? Configurable? | Configurable. Default: hourly for checks, daily for digests. |
| 6 | Agent-to-agent protocol | MCP calls vs. messaging vs. custom API | MCP for structured agents, messaging for conversational agents |
| 7 | Gateway hosting | Mac Mini (local) vs. cloud (DigitalOcean/Fly.io) vs. hybrid | Local Mac for MVP (privacy, control). Cloud for always-on later. |
| 8 | Krypton identity files | Adopt OpenClaw format (SOUL.md, IDENTITY.md, etc.) or custom? | Adopt pattern, customize content |
| 9 | Dashboard integration | Krypton command bar in Work OS dashboard or separate? | Embedded in Work OS dashboard |
| 10 | Notification strategy | Which events trigger push? How to avoid noise? | TBD — needs design |
| 11 | Multi-LLM routing | Per-skill model selection or global? | Per-skill (use cheaper models for simple tasks) |
| 12 | Browser credential access | How does Krypton access .env for browser automation? | Secure env injection at runtime |

---

## 15) What's NOT in this brief

- Work OS data model, API, dashboard (see Work OS Brief v5)
- Detailed skill implementation specs (build phase)
- Gateway protocol specification (build phase)
- Security threat model (separate security doc)
- Agent-to-agent protocol specification (future design phase)
- Deployment architecture (deliver phase)
- Cost modeling (post hosting/LLM decisions)
