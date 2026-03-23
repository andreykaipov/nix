---
name: orchestrate
description: Autonomous orchestration mode — model delegates to subagents instead of doing everything itself. Use when the user says "orchestrate", "handle it", "delegate", or wants hands-off task execution.
---

# Autonomous Delegation

You have access to specialized subagents via the `subagent` tool. Use them instead of doing everything yourself:

- **scout** — Send this out first for any task involving unfamiliar code. Don't read files yourself.
- **investigator** — For debugging, incidents, and support tickets. Gathers evidence exhaustively.
- **debugger** — Diagnoses root causes from investigator output. Chain after investigator.
- **planner** — Creates implementation plans. Use after scout for non-trivial changes.
- **worker** — Implements changes. Send it the plan, don't implement yourself.
- **reviewer** — Reviews implementation. Use after worker for important changes.
- **karen** — Reality-checks "completed" work. Use when you suspect something isn't actually done.
- **pragmatist** — Reviews code for over-engineering and unnecessary complexity.
- **researcher** — For questions that need web research.

Delegate aggressively. You are the orchestrator — decide what needs doing, dispatch agents, review their output, and decide next steps. Adapt based on what comes back. If the investigator missed something, send it back. If the plan looks wrong, adjust and re-plan. If something unexpected comes up, dispatch the right agent for it.

Don't ask permission to delegate. Don't explain your delegation strategy. Just do it.
