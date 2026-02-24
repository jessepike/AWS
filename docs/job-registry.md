# Automation Job Registry

**Total jobs:** 35 (17 launchd + 18 NC Railway)
**Last full audit:** 2026-02-24

This is the canonical source of truth for all automation jobs in the Agentic Work System. Update here when jobs are added, changed, or removed.

---

## LaunchD Jobs (macOS, laptop-local)

Scripts at `~/.claude/scripts/`. Logs at `~/.claude/logs/`. All jobs fire `job-fail-notify.sh` on non-zero exit (→ Slack alert).

| # | Label | Script | Schedule | Model | Type | Purpose | Last Verified |
|---|-------|--------|----------|-------|------|---------|--------------|
| 1 | `com.claude.krypton.daily` | `krypton-daily.sh` | Daily 5am | Sonnet 4.5 | Claude -p | Daily morning Slack report — git activity across projects | 2026-02-24 |
| 2 | `com.claude.krypton.gm` | `krypton-gm.sh` | Daily 5am | Sonnet 4.6 | Claude -p | Morning orientation briefing — bridges from EOD | 2026-02-24 |
| 3 | `com.claude.krypton.eod` | `krypton-eod.sh` | Daily 8pm | Sonnet 4.6 | Claude -p | End-of-day briefing — accomplishments, coaching, learnings | 2026-02-24 |
| 4 | `com.claude.insights.nightly` | `insights-nightly.sh` | Daily 8pm | Default (Max) | Claude -p | Nightly friction analysis — Memory + KB pattern detection | 2026-02-24 |
| 5 | `com.claude.krypton.memory-audit` | `memory-capture-audit.sh` | Daily 3pm | Haiku 4.5 | Claude -p | Daily memory capture gap detection — observational | 2026-02-24 |
| 6 | `com.claude.krypton.mcp-health` | `mcp-health-check.sh` | 8am + 2pm daily | — | Script | MCP server health — HTTP/stdio connectivity + KB/Memory functional | 2026-02-24 |
| 7 | `com.claude.wm.triage-light` | `wm-triage-light.sh` | Daily 12:30pm | Haiku 4.5 | Claude -p | WM light triage — incremental triage since last scan | 2026-02-24 |
| 8 | `com.claude.wm.triage-deep` | `wm-triage-deep.sh` | Daily 5pm | Sonnet 4.5 | Claude -p | WM deep triage — full sweep of all untriaged items | 2026-02-24 |
| 9 | `com.claude.krypton.weekly` | `krypton-weekly.sh` | Mon 4am | Sonnet 4.5 | Claude -p | Weekly digest report — 7-day activity summary | 2026-02-24 |
| 10 | `com.claude.wm.briefing` | `wm-briefing.sh` | Mon 8am | Sonnet 4.5 | Claude -p | Weekly WM Manager briefing — backlog health digest | 2026-02-24 |
| 11 | `com.claude.krypton.backlog-aging` | `backlog-aging.sh` | Fri 4pm | Haiku 4.5 | Claude -p | Weekly backlog aging — WM staleness + priority drift | 2026-02-24 |
| 12 | `com.claude.krypton.kb-curation` | `kb-curation.sh` | Sat 8pm | Haiku 4.5 | Claude -p | Weekly KB health audit — staleness, duplicates, orphans | 2026-02-24 |
| 13 | `com.claude.krypton.git-hygiene` | `git-hygiene.sh` | Sun 10am | — | Script | Weekly git scan — gone branches, uncommitted changes | 2026-02-24 |
| 14 | `com.claude.krypton.diagram-forge-health` | `diagram-forge-health.sh` | Sun 9am | — | Script | API key validation — Gemini, OpenAI, Replicate probes | 2026-02-24 |
| 15 | `com.claude.krypton.memory-maintenance` | `memory-maintenance.sh` | Sun 9pm | Haiku 4.5 | Claude -p | Weekly memory maintenance — archive stale entries | 2026-02-24 |
| 16 | `com.claude.wm.adf-sync` | `adf-sync.sh` | Every 15min + login | — | Script | ADF project sync — local markdown → WM database | 2026-02-24 |
| 17 | `com.claude.wm.triage-login` | `wm-triage-light.sh --gated` | On login (gated 4h) | Haiku 4.5 | Claude -p | Login catchup triage — skips if <4h since last run | 2026-02-24 |

**Failure alerting:** All 17 jobs have `job-fail-notify.sh` EXIT trap. On non-zero exit: last 6 log lines posted to Slack with job name and exit code. Added 2026-02-23.

---

## NC Railway Jobs

Defined in `~/code/_shared/nerve-center/config/jobs.yaml`. Run on Railway. Monitored by NC health infrastructure.

| # | Job | Schedule | Model | Purpose | Last Verified |
|---|-----|----------|-------|---------|--------------|
| 1 | `health-prober` | Every 30min | Haiku | Project health check | 2026-02-24 |
| 2 | `mcp-availability` | Every 15min | Haiku | MCP server availability probe | 2026-02-24 |
| 3 | `session-discipline` | Every 15min | Haiku | Session start/end discipline probe | 2026-02-24 |
| 4 | `infra-monitor` | Every 10min | Haiku | Infrastructure monitoring | 2026-02-24 |
| 5 | `notification-delivery-health` | Every 15min | Haiku | Notification delivery health | 2026-02-24 |
| 6 | `ws-feed-health` | Every 15min | Haiku | WebSocket feed health | 2026-02-24 |
| 7 | `backlog-health` | Every 3h | Haiku | Backlog health probe | 2026-02-24 |
| 8 | `drift-detector` | Every 4h | Haiku | Status + backlog + git drift detection | 2026-02-24 |
| 9 | `cross-project-consistency` | Every 6h | Haiku | Cross-project consistency check | 2026-02-24 |
| 10 | `coverage-matrix` | Every 2h | Haiku | Coverage matrix probe | 2026-02-24 |
| 11 | `backup-restore-health` | Every 2h | Haiku | Backup/restore health | 2026-02-24 |
| 12 | `auth-session-regression` | Every 30min | Haiku | Auth session regression | 2026-02-24 |
| 13 | `priority-alignment` | Daily 8am | Sonnet | Backlog vs git activity alignment | 2026-02-24 |
| 14 | `quality-tracker` | Daily 9am | Sonnet | Code quality tracking | 2026-02-24 |
| 15 | `dependency-health` | Daily 7:30am | Haiku | Dependency health probe | 2026-02-24 |
| 16 | `governance-sentinel` | Hourly | Sonnet | CLAUDE.md + recent commits governance check | 2026-02-24 |
| 17 | `knowledge-auditor` | Mon 8am | Sonnet | Knowledge base doc audit | 2026-02-24 |
| 18 | `autonomy-assessor` | Mon 8am | Sonnet | Weekly autonomy level assessment | 2026-02-24 |

---

## Summary

| Category | Count | Failure Alerting |
|----------|-------|-----------------|
| LaunchD jobs | 17 | Yes — EXIT trap → job-fail-notify.sh → Slack |
| NC Railway jobs | 18 | NC health infrastructure |
| **Total** | **35** | **All covered** |

### Model Distribution (launchd)

| Model | Jobs |
|-------|------|
| Sonnet 4.6 | 2 (krypton-gm, krypton-eod) |
| Sonnet 4.5 | 4 (krypton-daily, krypton-weekly, wm-triage-deep, wm-briefing) |
| Haiku 4.5 | 6 (wm-triage-light, wm-triage-login, backlog-aging, kb-curation, memory-audit, memory-maintenance) |
| Default Max | 1 (insights-nightly) |
| Script (no LLM) | 4 (mcp-health-check, git-hygiene, diagram-forge-health, adf-sync) |

### Refresh Cadence

Update this registry when:
- A new plist is loaded (`launchctl load`)
- A job is removed or disabled
- A job's schedule or model changes
- `config/jobs.yaml` (NC) is modified
