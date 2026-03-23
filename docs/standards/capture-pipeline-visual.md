# Capture Pipeline Visual

```mermaid
flowchart TD
  A["Capture Input\n(human/agent/automation)"] --> B["Parse\ntext + #topics + intent"]
  B --> C["Build Envelope\naws.capture-envelope.v1"]
  C --> D{"Project topic matches\nactive project slug?"}

  D -->|Yes| E["Route: project backlog"]
  D -->|No| F["Route: inbox backlog"]

  E --> G["Persist backlog_item\ntriage_metadata.capture_envelope"]
  F --> G

  G --> H["Triage/Promotion"]
  H --> I{"Secondary route?"}

  I -->|Learning/Reference| J["Promote to KB"]
  I -->|Explicit only| K["Write to Memory (global default)"]
  I -->|Task/Execution| L["Stay in backlog/task pipeline"]

  B --> M["Capability topics\n(mcp, skills, context, memory, plugins, agents)"]
  M --> C
```

## Notes

- `mcp` is treated as a topic/category label, not dependency relation.
- Primary target remains backlog-first for low-friction capture.
- Memory stays explicit/manual until memory workflow is stable.
