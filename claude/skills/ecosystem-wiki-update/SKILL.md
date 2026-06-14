---
name: ecosystem-wiki-update
description: Use when the user asks to update, refresh, or regenerate an ecosystem wiki. Also use when the user mentions the knowledge base is stale, wants to sync it with recent code changes, or needs to recompile the wiki after making changes.
---

# Ecosystem Wiki Update

## Overview

Re-explores repos that changed since the last update and recompiles the wiki. Diff-gated: only re-runs analyses for repos and topics affected by code changes. Reads `ecosystem.yaml` for configuration — does not re-prompt for topology.

## When to Use

Triggered when the user asks to update, refresh, or regenerate architecture knowledge for an ecosystem. Also triggered when the knowledge base is stale, needs syncing with recent code changes, or the wiki needs recompilation after changes.

## Preconditions

- `~/wiki/<ecosystem>/` exists with `ecosystem.yaml` (`.last-update` is normally present; if missing, Step 2 falls back to full re-analysis)
- `llm-wiki-compiler` installed and available on PATH
- `LLMWIKI_PROVIDER` env var and credentials configured

## Core Pattern

### Step 1: Identify the ecosystem

Ask the user for the ecosystem name. Check that `~/wiki/<ecosystem>/ecosystem.yaml` exists. If not, tell the user to run bootstrap first.

Read `ecosystem.yaml` to get repo names, paths, and topology edges.

### Step 2: Detect changes

Read the `.last-update` timestamp from `~/wiki/<ecosystem>/.last-update`.

For each repo in parallel, get changed files since that timestamp (including renames):

```bash
git -C <repo-path> log --since="<.last-update timestamp>" --name-only --diff-filter=ACDMRT --pretty=format:"" && git -C <repo-path> log --since="<.last-update timestamp>" --diff-filter=R --name-status --pretty=format:"" | grep '^R' | cut -f2
```

The first command produces current filenames (one per line, no commit metadata). The second command captures the **old** names of renamed files, ensuring trigger resolution can match paths referenced in stale architecture docs. Deduplicate and filter blank lines. Empty output means no changes in that repo.

If `git log` fails for a repo (no `.git` directory, no commits, path no longer exists), fall back to full re-analysis for that repo and warn the user.

If `.last-update` is missing, fall back to a full re-analysis of all repos (equivalent to re-bootstrap but preserving `ecosystem.yaml`) and warn the user.

### Step 3: Determine which analyses to re-run

Map changed files to analysis types using the trigger table in `## Diff-Gating Triggers` below. Read the architecture source files from `sources/` (not the compiled wiki) to resolve trigger categories to concrete paths.

Rules:
- Each analysis type is triggered independently per repo (Conventions, Gotchas) or per feature area (Architecture)
- Cross-repo analyses are triggered whenever files matching their scope change in **any** repo
- **Safety net:** when Architecture analysis re-runs for a feature area, always re-run the Cross-repo Implementation Guide analysis for edges involving that feature area — an architecture change by definition invalidates cross-repo docs
- If no changes detected in any repo, report that the knowledge base is up to date and exit

### Step 4: Run triggered analyses

When the catchall trigger fires (new directory at the same depth as existing feature areas), run discovery first (same as bootstrap Step 3a) for the affected repo before running Architecture for the new feature area. Update `<repo>-feature-areas.md` with the newly discovered area.

Re-run only the triggered analyses. Same parallelism as the `ecosystem-wiki-bootstrap` skill: per-repo analyses across different repos run in parallel. Each analysis receives the git diff summary as additional context to guide attention, but must produce a **complete** output file conforming to the output contracts from the `ecosystem-wiki-bootstrap` skill. The output replaces the previous source file entirely — partial or delta-only output is not valid. "Focus on the delta" means the agent should pay special attention to changed areas, not that it should omit unchanged sections.

### Step 5: Validate and run cross-repo analyses

Run contract validation on any Architecture docs that were regenerated (see `ecosystem-wiki-bootstrap/references/shared-contracts.md` for the full checklist). If validation fails, retry with format-correction prompt (max 1 retry). Skip cross-repo edges involving failed feature areas.

Run the Cross-repo Implementation Guide analysis only if the cross-repo analysis minimum threshold is met (see `ecosystem-wiki-bootstrap/references/shared-contracts.md`). If not met, skip the cross-repo analysis even when Architecture triggered it. This waits for all per-repo and per-feature-area analyses to complete.

### Step 6: Compile wiki (review mode)

```bash
cd ~/wiki/<ecosystem> && llmwiki compile --review
```

`--review` writes generated pages as candidates under `.llmwiki/candidates/` instead of mutating `wiki/` directly.

After compile, inspect candidates and approve or reject them:

```bash
cd ~/wiki/<ecosystem> && llmwiki review show <id>
cd ~/wiki/<ecosystem> && llmwiki review approve <id>
cd ~/wiki/<ecosystem> && llmwiki review reject <id>
```

Present candidates to the user with a summary of what changed. For large batches (10+ candidates), group by category (per-repo vs cross-repo, by repo name) and offer bulk operations: "approve all for repo X", "approve all", "reject all". Approve candidates the user accepts; reject the rest.

After all candidates are resolved, run lint and eval against the updated wiki:

```bash
cd ~/wiki/<ecosystem> && llmwiki lint; llmwiki eval
```

Lint and eval errors are informational — surface them in the report but don't abort.

### Step 7: Write timestamp and report

Update `.last-update` with the current ISO 8601 UTC timestamp.

Report to the user:
- Repos with changes detected (and which trigger matched)
- Analyses re-run: which types, for which repos
- Compile status (success/failure)
- Lint summary: error count and warning count
- Eval summary: health score, citation coverage, citation precision
- Skipped analyses (if any), with reasons

## Diff-Gating Triggers

Maps git diff changes to analyses that must be re-run. Trigger categories are resolved to concrete file paths by reading source files from `sources/` (not the compiled wiki).

### Trigger table

| Git diff shows changes in | Re-runs |
|---|---|
| Feature area directory, its entry points, client/transport files within that feature area, dependency manifest | Architecture analysis for that feature area |
| Test files, generated code directories, linter config, build config | Conventions analysis for that repo |
| Error handling paths, complex logic, configuration files | Gotchas analysis for that repo |
| Feature area directories (from architecture docs), call path files (client modules, route registrations, entry-point handlers, shared types, auth middleware, error propagation code) | Cross-repo Implementation Guide analysis |

### Resolving trigger categories to file paths

Read source files from `sources/` to identify concrete paths for each category:

**Architecture trigger:**
- The diff touches files under any feature area directory listed in `<repo>-feature-areas.md` — re-run Architecture analysis for that specific feature area only
- Any file matched by `### Outbound hosts` or `### Inbound entry points` in a feature area's Architecture doc — re-run Architecture for that feature area
- The dependency manifest (package.json, go.mod, build.gradle, etc.) — re-run Architecture for all feature areas in that repo
- The top-level entry-point directory or router/framework wiring (main, cmd, app, src, internal/infrastructure/router) — re-run Architecture for all feature areas in that repo
- **Catchall:** if the diff touches a new directory at the same depth as existing feature areas, under the same parent prefix, that is not already listed in `<repo>-feature-areas.md`, trigger discovery + Architecture analysis for the new area. To determine the root: take the common parent directory of all listed feature area paths (e.g., if feature areas are `modules/payments/`, `modules/orders/`, `modules/logistics/`, the root is `modules/`). If feature areas share no common parent (e.g., `src/api/`, `cmd/worker/`), treat each feature area's immediate parent as a separate root (`src/`, `cmd/`). A new directory at the same depth under any root (e.g., `modules/notifications/`) that is not already listed triggers discovery and Architecture analysis

**Conventions trigger:**
- Test directories (`**/test/**`, `**/*_test.go`, `**/*.test.ts`, `**/*Test.java`)
- Linter config (`.golangci.yml`, `.eslintrc`, `.pylintrc`, `checkstyle.xml`)
- Build config (`Makefile`, `package.json`, `build.gradle`, `pom.xml`, `pyproject.toml`)
- Generated code directories (`**/generated/**`, `**/gen/**`)

**Gotchas trigger:**
- Files with error handling paths (identifiable by error type usage, error wrapping)
- Configuration files (`*.yaml`, `*.yml`, `*.toml`, `*.properties`, `*.env`)
- Any file previously referenced in `<repo>-gotchas.md`

**Cross-repo Implementation Guide trigger:**
- Any file in a feature area directory (identified from `<repo>-feature-areas.md` discovery output)
- Any client module (identified from any Architecture doc's `### Outbound hosts` table)
- Any route/entry-point registration file (identified from any Architecture doc's `### Inbound entry points`)
- Shared type packages (from `cross-repo-implementation-guide.md`)
- Auth middleware (from `cross-repo-implementation-guide.md`)
- Error propagation paths (from `cross-repo-implementation-guide.md`)

### Safety net

When Architecture analysis re-runs for any feature area, always re-run the Cross-repo Implementation Guide analysis for edges involving that feature area — an architecture change by definition invalidates cross-repo docs. If the minimum criteria (2+ feature areas, at least one verified topology edge) are not met, skip cross-repo as in Step 5. The trigger table above is the primary mechanism; this is a safety net.

## Quick Reference

| Command | Purpose |
|---------|---------|
| `llmwiki compile --review` | Compile candidate pages without mutating live wiki |
| `llmwiki review show <id>` | Inspect a candidate page diff |
| `llmwiki review approve <id>` | Accept a candidate page |
| `llmwiki review reject <id>` | Reject a candidate page |
| `llmwiki lint` | Check for broken wikilinks, orphan pages, contradictions |
| `llmwiki eval` | Measure wiki quality score, citation coverage, corpus stats |

## Common Mistakes

- **Partial output:** Analyses must produce complete replacement files, not deltas. The agent should focus attention on changed areas but output the full document.
- **Missing bootstrap:** If `ecosystem.yaml` doesn't exist, the update skill can't proceed. Run `ecosystem-wiki-bootstrap` first.
- **Stale `.last-update`:** If the timestamp file is missing, all repos are re-analyzed from scratch -- a full rebuild, not a targeted update.
