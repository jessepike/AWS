---
updated: 2026-05-24
owner: krypton
status: awaiting-jesse-confirm
purpose: Low-effort way for Jesse to brief Krypton on the REAL live workstreams, so portfolio-map Part B reflects truth, not filesystem inference. React to each line — confirm / kill / correct. Add any I missed. Fill it here OR just tell me and I'll fill it.
---

# Workstream Brief — confirm/correct

For each: is it **real & active**? who **owns** it? is it **in-flight right now** (open session)? what's the **real next move**? My guesses are inferred from git — correct them.

## A. Workstreams I'm BLIND to (you flagged these — I have no visibility)

| # | Workstream | My guess | Real? | Owner | In-flight now? | Real next move |
|---|---|---|---|---|---|---|
| 0 | **WM / task-management revision** | You + Forge revising work-management + wm-agent (both were abandoned). I have zero visibility. | ☐ | Forge+you? | ☐ | ? | yes this is active an a priority project. CTO, Forge, and Krypton have pieces. each project needs a lead that can direct wprk...think a Project Manager...that single point of contact for that project.

## B. Candidates inferred from the portfolio map (Part B)

| # | Workstream | My guess | Real? | Owner | In-flight? | Real next move |
|---|---|---|---|---|---|---|
| 1 | AWS governance refresh | Reconcile stale status/backlog with North Star + map | ☐ | Forge | ☐ | ? | -- this is Krypton and Forge. 
| 2 | Symlink cleanup | Remove the 2 slated symlinks after ref-check | ☐ | Forge | ☐ | (already in Forge P0 note) | -- ok, make sure forge is away and get's this done, but wait until after 11pm Sunday (today 5/24/26) when weekly token allotment resets.
| 3 | Context substrate reconciliation | Merge `personal-context` + `context` into one component | ☐ | ? | ☐ | ? | -- this is a recent project that needs a bit more focus. need to ensure there are intent, architecture, etc. for this so we can merge cleanly. who should own this? Maybe we have an artifact--mayhe it's claude.md that sits at repo root that also assigns the PM for the project so if a new agent is going to work it's clear which agent to check with, check state with, etc. thinking through each repo having a core set of artifacts, resolver, project map, project owner, etc. so when an agent needs to acclimate/orient to a project they have a clear defined set of artifacts to ingest to get up to speed so minimizing assumptions and stale info.
| 4 | Personal-context Phase 1 | Core files / frontmatter / portability / eval suite | ☐ | ? | ☐ | ? | this project has a few threads that need to be pulled together. See our archtecture for personal context. this is new and not yet implemented
| 5 | CLS router dogfood | v1.2.0 router shipped; 1-week dogfood underway | ☐ | ? | ☐ | ? | this is new and not yet implemented
| 6 | Diagram Forge OSS launch | Key rotation + plugin-path fixes blocking launch | ☐ | Forge+CTO? | ☐ | ? | -- we can P1 this. it's not a core need right now.
| 7 | Agent-org cleanup | Trim agent-exec / merge into pike-agents | ☐ | Forge | ☐ | ? | -- this is active open session. it's new project work. needs to be aligned with our work in AWS. this is where I'm building the agent teams and defining their harnesses
| 8 | Knowledge/wiki operationalization | KB + capture + wiki sync status unclear | ☐ | ? | ☐ | ? | - wiki is not operational...maybe live, but not actively being used. This should fall under the kb project and owner. Can be punted to p1/p2

## C. Anything I missed
Work-Management/wm-agent: this is the project where we are defining the spine. this intersects with some of what we've been discussing. essentially this is how work/tasks to be done get capture, routed, etc. this is core to AWS and what we are building. this work mgmt piece will also capture those automated jobs...the goal is to have a runtime were all work flows through, is visibile, auditable, traceable, observable, etc. A dashboard will capture current state across active work streams, provide configuration options, be a single POV interface into what's happening, where, etc. this needs to be aligned with our discussions 

i think we need to do some overall dir maintenance. wonder if we need a skill for this and a schedule to fire it off weekly. let's add this to scratch pad. we've built some tools around this already in ADF audit, etc. we just need to assign an owner, schedule, and wire it up to ensure it's happening. Another example of where we need to focus our effort on closing gaps--not as much design, but execution and durability.

pike-agents: this is recent and defining the agents, the roles, heiarchy and the model to operate, invoke, etc.

Agent canvas app and get agents to use...agents will write html that will be used to interact with.

my priorities:
1. build out our foundation for AWS, personal operating infrastructure, and set the ground work for how you and i work and how to prioritize and execute and track all the pieces.
2. clean up stale/bad jobs. token conservation and optimization
3. focus on CLS, personal context, etc. 
4. build out work/task mgmt capability
5. start changing workflow to adjust/adapt to new processes and ways to work
6. build out Marcus coach...exploring new approach for interaction use
7. build out krypton personal agent capabilities
8. get core substrate componments healthy, updated, current state, future state, gaps, etc. kb, memory, etc.


honestly there's probably more...but let's start here. I need you to help me stay focused on these, drive actions, and overall support me.

---
Once confirmed, I update portfolio-map Part B to real state and we move to Design.
