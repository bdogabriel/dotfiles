---
name: ecosystem-wiki-bootstrap
description: Use when the user asks to bootstrap, initialize, set up, or create an ecosystem wiki for a multi-repo ecosystem. Also use when the user wants to generate a knowledge base, wiki, or architecture documentation for interconnected repositories.
---

# Ecosystem Wiki Bootstrap

## Overview

Bootstraps compiled architecture knowledge for a multi-repo ecosystem from scratch. Runs parallel read-only analyses on each repo, synthesizes a cross-repo implementation guide, then compiles everything into a queryable wiki via `llm-wiki-compiler`.

## When to Use

Triggered when the user asks to bootstrap, initialize, set up, or create architecture knowledge for a multi-repo ecosystem. Covers knowledge base generation, wiki creation, and architecture documentation for interconnected repositories.

## Preconditions

- `llm-wiki-compiler` installed and available on PATH
- `LLMWIKI_PROVIDER` env var set (`anthropic`, `openai`, `ollama`, or `copilot`) with corresponding credentials. Do not use reasoning models (`deepseek-r1`, `o1`, `o3`) — the compile pipeline requires forced tool calling, which reasoning models reject
- Each repo to be analyzed exists at a known local path
- Knowledge root is `~/wiki/` (fixed path, not configurable)

## Core Pattern

### Step 1: Gather inputs from user

Ask the user interactively, one question at a time:

1. **Ecosystem name** — short identifier (e.g., `payment-pipeline`). Used as directory name under `~/wiki/`
2. **Repo list** — for each repo, collect a short name and a local path. One at a time; empty input ends the list. Validate each path exists before proceeding to the next

### Step 2: Set up ecosystem directory

1. If `~/wiki/<ecosystem>/` does not exist, create it and write `ecosystem.yaml` with repo names and paths only (topology is auto-discovered later, see Step 4)
2. If it already exists with `ecosystem.yaml`, read the existing config. Ask the user for confirmation before overwriting `ecosystem.yaml` and all `sources/*.md` files. Re-bootstrap is idempotent: existing source files are overwritten, `llmwiki compile` regenerates pages from scratch
3. Create `sources/` directory if missing

Initial `ecosystem.yaml` format:

```yaml
version: 1
name: <ecosystem-name>
repos:
  - name: <repo-name>
    path: /absolute/path/to/repo
```

Store absolute paths. The topology section is appended in Step 4 using this format:

```yaml
version: 1
name: <ecosystem-name>
repos:
  - name: <repo-name>
    path: /absolute/path/to/repo
topology:
  - from: <source-repo-name>
    to: <target-repo-name>
```

The `topology` key is a list of directed edges. Each edge has exactly two fields: `from` (the caller repo name) and `to` (the callee repo name). Both values must match a `name` in the `repos` list.

### Step 3a: Discover feature areas

Run one discovery step per repo. Read the repo's directory structure to enumerate feature areas — distinct functional units identified from the module/package layout (e.g., top-level directories under `modules/`, `cmd/`, `app/`, `src/`). Write one `<repo>-feature-areas.md` file to `sources/`.

See `references/discovery-contract.md` for the output format.

This step runs in parallel across all repos (N agents).

### Step 3b: Run per-repo analyses

For each repo, run 2 analyses in parallel (2N agents total):

| Analysis | Scope | Produces |
|----------|-------|----------|
| Conventions | Naming, error handling, testing, code generation, code style, build targets, cross-repo conventions visible from this repo | `<repo>-conventions.md` |
| Gotchas | Non-obvious behaviors, implementation footguns, things that break unexpectedly during development | `<repo>-gotchas.md` |

These wait for Step 3a to complete so feature area names are available for context (the Conventions and Gotchas analyses receive the list of feature areas to inform their scope). Steps 3b and 3c both depend on 3a completion and run concurrently.

### Step 3c: Run per-feature-area Architecture analyses

For each feature area discovered in Step 3a, run one Architecture analysis. All run in parallel (sum of feature areas across all repos agents).

| Analysis | Scope | Produces |
|----------|-------|----------|
| Architecture | Responsibility boundaries, implementation patterns, module structure, key interfaces, framework wiring, outbound hosts with route verification — scoped to ONE feature area | `<repo>-<feature-area>-architecture.md` |

**Critical rules:**

1. **Scope is one feature area, not the whole repo.** Analyze only the code under that feature area's directory. Outbound calls are the HTTP calls made FROM this feature area's code. Inbound entry points are the routes registered by this feature area.

2. **Derive outbound hosts from HTTP client configuration, not from variable names or route paths.** Grep for base URLs in config files, env vars, client constructors. A variable named `serviceClient` calling `api/v1/endpoint/...` does NOT mean the target is `service-api` — check where the client is actually configured to connect.

3. **Verify target repo ownership.** For each outbound host, open the target repo and confirm it registers routes matching the outbound call paths. The `### Outbound hosts` table requires a `Verified` column proving this check was done.

4. **Focus on responsibility boundaries.** Answer: "when I add feature X to this feature area, does the logic go here or somewhere else?" If business logic for deployments lives in an external service, say so — the agent needs to know where to put things.

Each Architecture analysis receives: the list of ecosystem repo names and paths (for callee route verification), the feature area directory path, and the repo's feature area list.

See `references/analysis-contracts.md` for the exact output structure.

All source files must include YAML frontmatter:

```yaml
---
title: <repo-name>/<feature-area> Architecture
source: file://<absolute-path-to-repo>/<feature-area-path>
ingestedAt: <ISO 8601 timestamp>
---
```

For per-repo analyses, `source` is `file://<absolute-path-to-repo>`. For per-feature-area analyses, `source` is `file://<absolute-path-to-repo>/<feature-area-path>`. For cross-repo analyses, `source` is `ecosystem://repo-a,repo-b,repo-c`.

### Step 4: Discover and verify topology

After all per-feature-area Architecture analyses complete, discover the call topology and cross-validate:

**Phase A — Extract from Architecture docs:**

Parse the `### Outbound hosts` table from each `<repo>-<feature-area>-architecture.md`. For every row where the `Ecosystem repo` column names a repo in `ecosystem.yaml` (case-insensitive, after normalizing `_` to `-`), add a topology edge (`from`: `<repo>/<feature-area>`, `to`: the named repo).

Topology edges now carry feature area granularity. The `ecosystem.yaml` topology format:

```yaml
topology:
  - from: <repo-name>/<feature-area>
    to: <target-repo-name>/<feature-area>
```

The `to` field includes the target feature area when the Architecture doc's `Verified` column resolves to a specific feature area in the target repo. When the target feature area cannot be determined from route verification, the `to` field uses just the repo name.

**Phase B — Cross-validate:**

For each proposed edge A -> B:
1. Re-read A's Architecture doc `### Outbound hosts` table to get the host URL and the `Verified` column value
2. If the `Verified` column says "Confirmed: route ... registered in ...", the Architecture analysis already did the verification. Trust it — mark the edge as verified
3. If the `Verified` column says "Unverified" or is missing: open B's repo directly and grep its route registration files (e.g., `router.go`, `routes.py`) for path patterns matching the outbound calls A claims to make. If at least one route matches, determine which feature area in B owns that route (using the `<repo>-feature-areas.md` discovery output), and mark the edge as verified with the specific target feature area
4. If no routes match: the edge is unverified. Emit a warning listing the edge, the mismatched host, and suggest manually checking the topology
5. If B has no Architecture doc (analysis failed or was skipped): the `Verified` column won't exist or will say "Unverified" — fall back to direct grep (step 3), or mark as unverified if B's repo is inaccessible

**Phase C — Resolve:**

- Verified edges: write to `ecosystem.yaml` topology with full `from: <repo>/<feature-area>, to: <repo>/<feature-area>`
- Unverified edges: write to topology at repo granularity (`from: <repo>/<feature-area>, to: <repo>`), flag in Step 8 report as "unverified" with reason
- Feature areas with no outbound hosts (leaf areas, internal-only): no edges from them

For near-misses (Levenshtein distance <= 2 from a known repo name in the `Ecosystem repo` column), emit a warning and treat as unverified. Write the complete topology to `ecosystem.yaml` using the schema defined in Step 2.

### Step 5: Validate and retry

1. Detect failures: an analysis failed if it produced no file, an empty file (< 200 chars), or a file missing required YAML frontmatter (`title`, `source`, `ingestedAt`)
2. Retry failed analyses once (max 1 retry)
3. Run **contract validation** on each Architecture doc (see `references/shared-contracts.md` for the full checklist). If validation fails, retry Architecture analysis with an explicit format-correction prompt (max 1 retry). If the Architecture doc is regenerated, re-run Step 4 to re-discover topology for the affected feature area before proceeding. If validation still fails, skip cross-repo edges involving that feature area and warn the user

### Step 6: Run cross-repo analysis

If the cross-repo analysis minimum threshold is met (see `references/shared-contracts.md`), run the Cross-repo Implementation Guide analysis. Otherwise skip and warn.

| Analysis | Scope | Reads | Produces |
|----------|-------|-------|----------|
| Implementation Guide | Synthesizes per-feature-area knowledge into actionable implementation rules: topology, responsibility map, implementation order, parameter/type propagation, integration patterns, common workflows, cross-repo conventions and gotchas | All per-feature-area architecture docs, per-repo conventions, gotchas, and the verified topology from Step 4 | `cross-repo-implementation-guide.md` |

This is the primary cross-repo artifact — the document an agent queries before implementing any feature. It does NOT produce per-endpoint tables. It synthesizes patterns: "deployment flows through all 3 repos; the BFF enriches get/promote/abort but blind-proxies everything else; the developer-api delegates business logic to deploy-service."

The analysis should trace a few representative call chains internally to understand how features flow, but the output is a synthesis of patterns, not a trace of every endpoint. Use the approach from `references/call-chain-algorithm.md` to understand call flow, but produce synthesized patterns, not per-endpoint hop tables.

See `references/analysis-contracts.md` for the Cross-repo Implementation Guide output structure.

Cross-repo source files use `ecosystem://` prefix for the `source` field:

```yaml
source: ecosystem://repo-a,repo-b,repo-c
```

### Step 7: Compile wiki and evaluate quality

```bash
cd ~/wiki/<ecosystem> && llmwiki compile && { llmwiki lint; llmwiki eval; }
```

- `llmwiki compile`: Phase A extracts concepts from all `sources/*.md` files (hash-gated). Phase B generates wiki pages that synthesize all source references, merging concepts shared across sources into single pages. Contradictions are surfaced, not resolved
- `llmwiki lint`: checks for broken wikilinks, orphan pages, empty pages, low-confidence pages, contradictions, broken citations
- `llmwiki eval`: fast suite — measures health score (0–100), citation coverage and precision, corpus stats. No API key needed
- Exit 0 for all three means success. Exit 1 on compile aborts. Lint and eval errors are informational (surfaced in report, don't abort)

### Step 8: Write timestamp and report

Write `.last-update` file (single line, ISO 8601 UTC, no trailing newline):

```bash
echo -n "2026-06-07T14:30:00.000Z" > ~/wiki/<ecosystem>/.last-update
```

Report to the user:

- Analyses run: list each analysis type with repo and feature area (where applicable)
- Files produced vs expected: `N/M source files written` (M = 2N + sum of feature areas when cross-repo was skipped, M = 2N + sum of feature areas + 1 when cross-repo analysis ran)
- Lint summary: error count and warning count from `llmwiki lint`
- Eval summary: health score, citation coverage, citation precision from `llmwiki eval`
- Skipped analyses: which failed and why
- Topology coverage: which edges are verified, unverified, or skipped (with reasons)

### Partial bootstrap

If analyses fail after retry, the wiki compiles with available sources. Report coverage level:

| State | Meaning |
|-------|---------|
| Full coverage | All analyses succeeded, all topology edges verified |
| Partial — feature area | One or more per-feature-area Architecture analyses failed |
| Partial — cross-repo | Cross-repo analyses skipped or failed |
| Minimal | Fewer than 2 Architecture analyses succeeded, no cross-repo tracing |

## Quick Reference

| Command | Purpose |
|---------|---------|
| `llmwiki compile` | Compile source files into wiki pages |
| `llmwiki lint` | Check for broken wikilinks, orphan pages, contradictions |
| `llmwiki eval` | Measure wiki quality score, citation coverage, corpus stats |
| `~/wiki/<ecosystem>/` | Knowledge root (fixed path) |

## Common Mistakes

- **Using reasoning models:** `deepseek-r1`, `o1`, and `o3` reject forced tool calling required by the compile pipeline. Use `anthropic`, `openai`, `ollama`, or `copilot`.
- **Skipping contract validation:** Architecture docs missing `## Responsibility boundaries`, `## Implementation patterns`, or `### Outbound hosts` with a `Verified` column cause downstream cross-repo analyses to fail silently.
- **Missing LLMWIKI_PROVIDER:** The env var must be set with corresponding credentials before running `llmwiki compile`.
