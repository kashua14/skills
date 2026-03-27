---
name: daily-work-orchestrator
description: Orchestrates a multi-workspace developer day by resuming from prior handoffs, generating an approval-first daily plan, routing likely Codex skills, and capturing end-of-day handoffs. Use when the user wants start-of-day or end-of-day workflow across multiple repos/workspaces, workspace handoffs, daily planning, skill routing, or a persistent developer planner.
---

# Daily Work Orchestrator

Use this skill to run a repeatable daily loop across many repos and non-git workspaces without losing context between days.

## Quick start

- Keep the central planner repo as the control plane for the workflow.
- Keep each tracked workspace's local handoff in `.codex/session-handoff.md`.
- Use `codex-daily start-day` to analyze all tracked workspaces and propose focus areas.
- Use `codex-daily end-day` to update handoffs only for active workspaces.

## Start-day workflow

1. Load the tracked workspace registry from the planner repo.
2. Gather deterministic evidence for every workspace.
   - For git workspaces: branch, git status, changed files, recent commits, previous handoff.
   - For non-git workspaces: existence, previous handoff, planner metadata, and lightweight filesystem signals if configured.
3. Apply explicit routing rules first to recommend candidate skills.
4. If a model backend is configured, let it refine summaries, next actions, and skill ranking.
5. Show a compact summary for every workspace.
6. Propose a focus shortlist, then let the user approve or edit it interactively.
7. For workspaces with no existing handoff, switch into the fixed bootstrap pipeline instead of pretending there is prior context.
8. Automatically start the bootstrap kickoff for one selected no-handoff workspace at a time:
   - ask for the user's top priority
   - if needed, suggest up to 3 strong candidates
   - write a planner-side bootstrap brief
   - generate the launch prompt for the interactive Codex session
   - launch Codex directly when the environment is interactive and bootstrap auto-launch is enabled
   - instruct the launched Codex session to begin step 1 immediately and continue step-by-step, only pausing for the user when a step needs input or approval
9. Write the central daily dashboard and refresh the recommended start prompt inside each selected workspace handoff. Do not create a fake local handoff for a no-handoff workspace before the issue set is confirmed.

## No-handoff bootstrap workflow

Use this default pipeline one workspace at a time:

1. Do a lightweight scan.
2. Ask for the user's top priority in the workspace.
3. If the user has no clear priority, suggest up to 3 strong candidates from:
   - open issues and PRs first
   - lightweight repo inspection second
4. Use `grill-me` to sharpen the chosen problem.
5. Do deeper targeted inspection.
6. Use `write-a-prd` when the problem is a larger feature, ambiguous initiative, or needs clearer product/UX scope before issue slicing.
7. Use `triage-issue` if the problem is one safe vertical slice.
8. Use `prd-to-issues` if it must split into parent/child issues. If a PRD was needed, derive the issue set from that PRD.
9. Draft issue(s) with repo templates if present.
10. Only create GitHub issue(s) after explicit confirmation.
11. Write the first bootstrap handoff immediately after issue confirmation.
12. Ask whether to implement now, but do not implement without explicit approval.
13. Ask separately whether to create a draft PR after implementation.

Execution rule:
- Once the bootstrap Codex session starts, it should execute the pipeline immediately instead of merely restating it. It should ask one question at a time during `grill-me`, keep moving between user gates, and stop only for the approvals that the workflow explicitly requires.

## End-day workflow

1. Read today's dashboard to recover the morning selection.
2. Detect active workspaces from planner signals plus filesystem signals.
3. Review only active workspaces by default, with an optional quick pass over the rest.
4. Draft the handoff from evidence, then ask the user for a very short confirmation or edit:
   - where they stopped
   - next action
   - blockers
   - short session notes
5. Write `.codex/session-handoff.md` for each reviewed workspace.
6. Update planner issues and skill-gap backlog files.

## Routing rules

- Prefer explicit routing rules over pure model judgment.
- Recommend only the skills that match the workspace evidence.
- Surface `skill_gap` explicitly when no current skill fits well.
- Persist candidate new skills and routing improvements in the planner repo backlog.

Typical mappings:
- failing CI or PR checks -> `gh-fix-ci`
- review feedback or requested changes -> `gh-address-comments`
- clear implementation slice -> `tdd`
- architecture uncertainty or shallow modules -> `improve-codebase-architecture`
- notes or research workspace -> `obsidian-vault`
- recurring new workflow need -> `write-a-skill`

## Files

- Planner repo:
  - `workspaces.yaml`
  - `config.yaml`
  - `skill-routing.yaml`
  - `days/YYYY-MM-DD.md`
  - `planner-issues.md`
  - `skill-backlog.md`
- Per workspace:
  - `.codex/session-handoff.md`

`workspaces.yaml` may also include:
- `group` for related repos such as `ucu`
- `depends_on` for ordered cross-repo flows such as `ucu-ui` depending on `ucu-api`

## Guardrails

- The workflow is approval-first.
- `start-day` recommends focus workspaces but does not launch deeper work automatically in v1.
- `end-day` updates files only; it does not stage, commit, or push git changes.
- Missing or inaccessible workspaces are planner errors, not silent skips.
