# Brief: Agentic Work System

## Scope

Govern the integration, health, and evolution of the agentic work system. This project tracks how components connect, identifies gaps, and ensures the architecture stays grounded in reality.

## Success Criteria

1. **Orientation:** Any agent session can understand the system by reading this project's artifacts
2. **Integration:** Component communication protocols are defined and tested
3. **Observability:** System health is assessable from this project without visiting every sub-project
4. **Architecture currency:** `docs/architecture.md` reflects actual state, not aspirational state
5. **Ring formalization:** Each ring's instantiation at each layer is documented with current vs. target state
6. **Governance operational:** Krypton governance health check runs on cadence

## Component Inventory

| Component | MVP Status | Integration Status |
|-----------|-----------|-------------------|
| ADF | Delivered | Well-integrated (MCP, plugins, stage specs) |
| Knowledge Base | Delivered | Well-integrated (MCP, kb-manager plugin) |
| Memory | Delivered | Partially integrated (MCP operational, routing rules defined) |
| Capabilities Registry | Delivered | Partially integrated (INVENTORY.md, gap detection) |
| Krypton | Delivered | Partially integrated (plugin, skills, needs governance layer) |
| Link Triage | Delivered | Partially integrated (KB capture works, broader routing needed) |
| Work Management | Designed | Not integrated (brief exists, implementation pending) |

## Out of Scope

- Building software for any component (each component has its own project)
- Day-to-day task management within components
- Replacing component-level backlogs or status tracking
