# Stage-Specific Review Focus Areas

Each ADF stage has unique review dimensions based on its artifacts and goals.

## Discover Stage

**Primary Artifacts:** intent.md, brief.md

**Review Focus:**
- Problem statement clarity
- Success criteria are measurable and specific
- Scope is well-defined
- Stakeholders identified
- No assumptions about solutions (problem-focused)

**Common Issues:**
- Vague problem statements ("make things better")
- Unmeasurable success criteria ("improve performance")
- Solution details creeping into problem definition
- Missing context about current state

## Design Stage

**Primary Artifacts:** design.md

**Review Focus:**
- Architectural soundness
- All components specified
- Data model completeness
- Integration points defined
- Technology choices justified
- Decision log captures trade-offs
- Non-functional requirements addressed

**Common Issues:**
- Missing data model or schema
- Undefined integration protocols
- Unjustified technology selections
- Missing error handling strategy
- Scalability not considered

## Develop Stage

**Primary Artifacts:** plan.md, tasks.md, manifest.md, capabilities.md

**Review Focus:**
- Plan covers all design requirements
- Tasks are atomic and executable
- Dependencies correctly sequenced
- Testing strategy adequate
- All capabilities identified
- No implementation blockers
- Verification strategy defined

**Common Issues:**
- Missing tasks.md artifact
- Tasks too large or vague
- Circular dependencies
- Insufficient test coverage
- Missing critical capabilities
- No build-to-design verification

## Deliver Stage

**Primary Artifacts:** deployment docs, handoff materials

**Review Focus:**
- Deployment process documented
- Configuration management clear
- Monitoring and observability
- Rollback procedures defined
- Handoff materials complete
- Production readiness verified

**Common Issues:**
- Missing deployment documentation
- Unclear configuration requirements
- No rollback strategy
- Incomplete handoff materials
- Production environment not validated

## Cross-Stage Considerations

**All Stages:**
- Artifacts follow ADF specifications
- YAML frontmatter valid
- Required sections present
- Clear and actionable language
- No internal contradictions

**Stage Transitions:**
- Exit criteria met for current stage
- Prerequisites met for next stage
- Handoff documentation updated
- Status.md reflects transition
