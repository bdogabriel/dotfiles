---
name: ecosystem-dev
description: Use when the user asks to implement something that spans multiple repos in an ecosystem -- features, bug fixes, refactors, migrations. Also use when the user wants to implement changes guided by the ecosystem wiki.
---

# Ecosystem Dev

## Overview

Assembles a cross-repo implementation brief from the ecosystem wiki and user-supplied context, then dispatches staged tamandua runs to implement changes across repos.

## When to Use

Triggered when the user asks to implement something that spans multiple repos in an ecosystem -- features, bug fixes, refactors, migrations, endpoint additions. Also when the user wants to implement something guided by the ecosystem wiki.

## Preconditions

- The ecosystem must be bootstrapped and the wiki compiled. `ecosystem-wiki-query` must return usable results.
- `tamandua` CLI installed and available on PATH
- `ecosystem-dev` workflow installed in tamandua
- `ecosystem-wiki-query` and `tamandua-agents` skills discoverable by the harness and by tamandua agents

## Core Pattern

### Phase 1 -- Assemble implementation brief

1. **Identify ecosystem.** Ask for the ecosystem name. Validate `~/wiki/<ecosystem>/ecosystem.yaml` exists. If not, tell the user to bootstrap first.

2. **Feature description.** Ask for a natural language description of the feature.

3. **Context files.** Ask for optional context files (PRD, Swagger/OpenAPI specs, sequence diagrams). Accept file paths. No limit on file count.

4. **Query the wiki.** Invoke the `ecosystem-wiki-query` skill to pull:
   - Cross-repo implementation guide (topology, responsibility map, implementation order, integration patterns)
   - Architecture docs for relevant feature areas
   - Per-repo conventions and gotchas

   Do not attempt to exhaustively extract all wiki knowledge into the brief. The wiki remains available to tamandua agents at implementation time via `ecosystem-wiki-query` — agents are instructed to query it first for architecture and cross-repo questions. The brief provides the structural skeleton (scope, contracts, dependency order); the wiki provides the living architecture reference that agents query on demand.

5. **Synthesize the implementation brief.** Use the wiki's topology to determine which repos depend on which others. Group repos into execution stages. Read any user-supplied context files and extract contracts, acceptance criteria, and constraints. Produce a structured brief with these sections:

   ```
   CURRENT_REPO: <repo-name>

   ## Feature: <summary>

   ### Scope
   - Ecosystem: <name>
   - Repos affected: <repo-a>, <repo-b>
   - Feature areas: <repo-a>/<area-1>, <repo-b>/<area-2>

   ### Dependency Order
   Stage 1 (no internal dependencies):
     - repo-a: <what it provides>
   Stage 2 (depends on Stage 1):
     - repo-b: <what it consumes from repo-a>

   ### Contracts
   - <endpoint or interface> (from <source>)
       <request/response or input/output shapes>

   ### Per-Repo Scope
   #### repo-a
   - <specific changes>
   - Convention: <relevant conventions from wiki>
   ...

   ### Architectural Constraints
   - <constraint from wiki or context files>
   ...

   ### Wiki Guidance
   The ecosystem wiki is available to all agents via `ecosystem-wiki-query`.
   For architecture and cross-repo questions (call chains, responsibility maps,
   integration patterns, per-repo conventions, gotchas), query the wiki first
   before reaching for grep or local codebase exploration. The wiki answers in
   one call what would require digging through multiple repos.

   ### Upstream Branches (stage 2+ only)
   - repo-a: feature/payment-flow (worktree: /abs/path/to/worktree)

   ### Acceptance Criteria
   1. <criterion>
   ...
   ```

   For the per-repo briefs sent to tamandua, prepend `CURRENT_REPO: <repo-name>` so the planner knows which repo it owns. Each repo receives the full brief (all repos) for cross-repo context.

   The `### Upstream Branches` section is absent for stage 1 runs. For stage 2+ runs, it is populated automatically by the orchestrator after extracting branch names from completed upstream runs (see step 8). This section is informational context -- the workflow planner tells agents to assume upstream changes are in place and code against the contracts defined in the brief.

6. **Present for approval.** Show the brief to the user. The user can refine, add hints, override repo assignments, skip repos, or add additional repos. Loop until the user approves. After approval, Phase 2 runs without further approval. If a run fails, the orchestrator reports the failure and stops.

### Phase 2 -- Execute via tamandua

7. **Execute stages in order.** The `Dependency Order` section defines the stages. For each stage, launch one tamandua run per repo in parallel. Use a heredoc to avoid shell quoting issues with the multi-line brief:

   ```bash
   tamandua workflow run ecosystem-dev "$(cat <<'BRIEF'
   <per-repo-brief content>
   BRIEF
   )" --worktree-origin-repository <repo-path>
   ```

   If `tamandua workflow run` exits non-zero, report the error to the user and stop the pipeline.

8. **Wait for stage completion and extract branches.** Poll `tamandua workflow status <run-id>` for each run in the current stage. Check the status field:
   - `done`: extract the branch name (see below)
   - `failed` or `paused`: stop the pipeline, report the run ID and status to the user
   - `canceled`: stop the pipeline, report to the user

   Extract branch names from completed runs:

   ```bash
   tamandua worktree status <run-id>   # get worktree path
   git -C <worktree-path> branch --show-current   # get branch name
   ```

9. **Inject upstream refs into next stage briefs.** For each repo in the next stage, add the `### Upstream Branches` section listing the completed upstream repos with their branch names and worktree paths.

10. **Repeat** steps 7-9 for each stage.

11. **Report results.** Show all run IDs grouped by stage, with status and branch name for each.

### Edge Cases

- **Ecosystem doesn't exist**: tell user to bootstrap first
- **Brief has gaps**: user refines in the approval step before launching tamandua
- **Tamandua run fails**: planner/developer errors escalate to human via tamandua's `on_fail`. Stop the pipeline, report the run ID so the user can run `tamandua logs <run-id>` or `tamandua workflow resume <run-id>`
- **Partial stage failure**: if some repos in a stage fail while others succeed, halt the pipeline. Do not launch dependent stages with missing upstream refs
- **Single repo ecosystem**: no dependency stages needed -- single run, no upstream refs
- **Tamandua not installed or workflow not found**: report preconditions clearly, stop
- **Launch failure**: if `tamandua workflow run` exits non-zero (bad repo path, missing workflow), report the error and stop

## Quick Reference

| Phase | Action |
|-------|--------|
| Assemble | Identify ecosystem, collect inputs, query wiki, synthesize brief, get approval |
| Execute | Launch staged tamandua runs, extract branches, inject upstream refs, report |

## Common Mistakes

- **Launching dependent repos too early**: dependent repos need upstream branch refs. Wait for the stage to complete and extract branches before launching the next
- **Not passing the full brief**: each repo run needs the full cross-repo brief plus `CURRENT_REPO`. Without full context, the planner can't understand how its work relates to other repos
- **Missing upstream worktree paths**: the `### Upstream Branches` section must include the worktree path, not just the branch name -- the developer can fetch from the worktree if it needs actual source code beyond what the contracts describe
- **Shell quoting the brief**: the brief contains markdown with backticks, dollar signs, and special characters. Always use a heredoc with single-quoted delimiter (`<<'BRIEF'`) to prevent shell expansion
- **Proceeding after partial failure**: if any run in a stage fails, the entire pipeline must stop. Launching downstream stages with incomplete upstream refs produces broken integrations
