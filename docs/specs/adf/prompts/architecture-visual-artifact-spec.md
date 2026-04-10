---
type: "prompt"
description: "Prompt for generating architecture diagrams from individual ADF artifact specs"
version: "1.0.0"
updated: "2026-01-25"
lifecycle: "reference"
location: "prompts/architecture-visual-artifact-spec.md"
---

# Prompt: Artifact Specification Architecture Diagram

Use this prompt with an image generation tool to create an architectural visualization from any ADF artifact specification.

---

## Prompt Template

Create a clean, modern architecture diagram depicting the high-level structure of the attached specification.

**Style Requirements:**
- Layered, hierarchical visualization
- Business and contextual focus (not technical implementation)
- Show relationships between components
- Show lifecycle/evolution where applicable
- Use clear visual hierarchy — most important elements prominent

**Visual Elements to Include:**

1. **Parent/Dependency Relationships**
   - If the artifact references or depends on other artifacts, show them
   - Use arrows to indicate relationship direction (parent → child, input → output)
   - Position parent artifacts to the left or above

2. **Core Structure**
   - Show the main sections/components of the artifact
   - Use boxes or containers to group related elements
   - Include brief labels describing purpose of each section

3. **Metadata Layer**
   - Show frontmatter/metadata if relevant (versioning, type, lifecycle)
   - Position at top of the artifact container

4. **Evolution/Lifecycle** (if applicable)
   - Show how the artifact changes through stages or over time
   - Use horizontal flow: Stage 1 → Stage 2 → Stage 3
   - Label what happens at each stage (Created, Refined, Stable, etc.)

5. **Governance & Validation** (if applicable)
   - Who can modify
   - Version tracking rules
   - Validation criteria

**Visual Style:**
- Clean, minimal, professional
- Muted color palette:
  - Blue for primary artifact
  - Purple/violet for artifact internals
  - Light blue for supporting elements (governance, lifecycle)
  - Gray for metadata
- Use simple icons to distinguish section types
- White or light background
- Clear typography, readable labels

**Do NOT:**
- Include security-specific frameworks or terminology (unless the spec is security-focused)
- Reference specific architecture framework names or acronyms
- Add implementation details not in the spec
- Over-complicate with too many visual elements

**Title:** Use the artifact name (e.g., "ADF Brief Specification for brief.md")

**Subtitle:** Brief description of artifact purpose

---

## Usage

1. Attach or paste the artifact specification
2. Use this prompt
3. Optionally add: "Focus on [specific aspect]" if you want to emphasize a particular area

**Example:**
```
[Paste ADF-BRIEF-SPEC.md content]

Create a clean, modern architecture diagram depicting the high-level structure of the attached specification.

[Include full prompt above]
```
