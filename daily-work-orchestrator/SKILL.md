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
   - store the full chosen problem in that brief so long problem statements are not passed inline to the launch command
   - generate the launch prompt for the interactive Codex session
   - instruct the launched Codex session to read the bootstrap brief first and treat it as the source of truth
   - launch Codex directly when the environment is interactive and bootstrap auto-launch is enabled
   - instruct the launched Codex session to begin step 1 immediately and continue step-by-step, only pausing for the user when a step needs input or approval
9. Write the central daily dashboard and refresh the recommended start prompt inside each selected workspace handoff. Do not create a fake local handoff for a no-handoff workspace before the issue set is confirmed.

## Canonical workflow

Apply the same workflow to both handoff and no-handoff repos, but with different entrypoints.

- With handoff:
  - start from the recorded issue queue, current issue, branch, PR, and next action
  - inspect existing open issues and PRs first
  - if the user states a new problem, compare it against the current queue and recommend whether to override
- Without handoff:
  - bootstrap from zero using the no-handoff path below

Default execution model:

1. Start from the user-stated problem if they give one. If they do not, inspect the repo and use judgment.
2. Use `grill-me` to sharpen the problem one question at a time until the problem and intended outcome are clear.
3. Inspect the repo and existing open work.
   - prioritize unfinished existing issues and PRs first
   - reuse and update existing relevant issues before creating new ones
4. If the work is a larger feature, ambiguous initiative, or needs clearer scope, use `write-a-prd`.
5. If the work is one safe vertical slice, use `triage-issue`.
6. If the work is larger than one safe vertical slice, use `prd-to-issues`. If a PRD was needed, derive the issue set from that PRD.
7. Draft the issue set first using repo templates if present.
   - use strict lookup order: repo-local templates, repo conventions, planner fallback, then structured custom draft
   - update existing issue bodies in place as the canonical plan; add a short change-note comment only when context changed materially
8. Apply priorities using `P0` to `P3`.
   - `P0`: urgent blocker
   - `P1`: top issue for today
   - `P2`: important but not first today
   - `P3`: backlog/later
9. Present the issue set and priority updates for confirmation before creating or updating GitHub issues.
10. Create or update issues only after approval.
11. Maintain a planner-side today queue as a derived view, not a separate source of truth.
12. Rank across repos with this ordered rule set:
   - `P0` beats everything
   - unblocks other work beats isolated work
   - existing branch or PR continuation beats brand-new work
   - user-stated problem can override with explicit confirmation
   - otherwise use workspace priority
13. Present the highest-priority unblocked issue for today and ask for confirmation before implementation.
14. Implement only one issue at a time by default.
15. Continue an existing branch or PR when it clearly maps to the same issue. Otherwise create a fresh branch from the default branch using `codex/<issue-number>-<slug>`.
16. If GitHub is unavailable, degrade cleanly to planner-side local drafts for issues and PRs without blocking understanding or planning.
17. Before commit/push/PR creation, stop and ask one final `ship this issue now?` approval.
18. If approved, create a draft PR using repo templates where present.
   - link the issue so it closes on merge, but do not close it immediately
   - assign to the currently authenticated GitHub user by default, with optional override to `kashua14`
   - apply repo-native labels and projects when they clearly exist; otherwise use only the safe minimum metadata
19. Update the handoff immediately with the current issue, branch, PR, priority, suggested next action, and derived today queue, then stop.

Execution rule:
- Once the launched Codex session starts, it should execute this workflow immediately instead of restating it. It should ask one question at a time during `grill-me`, keep moving between user gates, and stop only for the approvals that the workflow explicitly requires.

## No-handoff bootstrap workflow

Use this bootstrap entrypoint one workspace at a time:

1. Do a lightweight scan.
2. Ask for the user's top priority in the workspace.
3. If the user has no clear priority, suggest up to 3 very strong candidates from:
   - open issues and PRs first
   - lightweight repo inspection second
4. Then continue into the canonical workflow above.

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
- `start-day` may launch a Codex bootstrap session automatically when configured to do so.
- `end-day` updates files only; it does not stage, commit, or push git changes.
- Missing or inaccessible workspaces are planner errors, not silent skips.
- Keep `workspaces.yaml` manual. Only derived planner artifacts should update automatically.
