---
name: ecosystem-wiki-query
description: Use when the user asks to query, search, or ask about an ecosystem wiki, codebase structure, call chains, or cross-repo patterns in a multi-repo ecosystem. Also use when the user wants to look up how a feature flows through the system or how repos are connected.
---

# Ecosystem Wiki Query

## Overview

Queries the compiled knowledge wiki for a multi-repo ecosystem. Thin wrapper around `llmwiki query` and `llmwiki context` with ecosystem validation.

## When to Use

Triggered when the user asks to query, search, or ask about architecture knowledge, codebase structure, call chains, or cross-repo patterns in a multi-repo ecosystem. Covers feature flow lookups, repo connectivity questions, and architecture exploration.

## Preconditions

- `~/wiki/<ecosystem>/` exists with `ecosystem.yaml` and a compiled `wiki/`
- Node >= 24 with `llm-wiki-compiler` installed globally
- `LLMWIKI_PROVIDER` env var and credentials configured (required for `llmwiki query` and `llmwiki context`)

## Core Pattern

### Query (generated answer)

1. Ask the user for the ecosystem name and the question
2. Validate `~/wiki/<ecosystem>/` exists and contains `ecosystem.yaml`
3. Validate `wiki/` exists and contains at least one `.md` file
4. Check staleness: read `~/wiki/<ecosystem>/.last-update` (single line, ISO 8601 UTC, no trailing newline). If the timestamp is older than 7 days, warn the user (e.g., "Wiki was last updated 12 days ago -- consider running ecosystem-wiki-update for current information"). If `.last-update` is missing, warn that the wiki may be stale. This is a warning only -- proceed with the query regardless
5. Run:

```bash
cd ~/wiki/<ecosystem> && llmwiki query "<question>"
```

6. Print the stdout output directly to the user

**Error handling:**
- Ecosystem directory missing: tell user to run bootstrap
- `wiki/` empty: tell user to run compile
- `llmwiki query` exits non-zero: report the error and suggest checking LLM credentials
- "Wiki index not found. Run `llmwiki compile` first.": tell user to compile
- "No matching pages found. Try refining your question.": relay to user (not an error, exit 0)

### Save query result

Add `--save` to persist the answer as a wiki page (only write path to `wiki/` that persists through recompiles):

```bash
cd ~/wiki/<ecosystem> && llmwiki query "<question>" --save
```

### Context retrieval (structured evidence pack)

When the agent needs raw page content rather than a generated answer:

```bash
cd ~/wiki/<ecosystem> && llmwiki context "<prompt>" --json
```

Returns an evidence pack with primary pages, semantic chunks, graph neighbors, citations, and suggested actions. Suitable for feeding directly into an implementation plan.

### Direct file access

Wiki pages are plain markdown files. For known targets, read directly rather than querying:

```
wiki/concepts/<slug>.md    # concept pages
wiki/queries/<slug>.md     # saved query answers
wiki/index.md              # auto-generated table of contents
```

Use `llmwiki query` or `llmwiki context` for discovery; use direct file reads for known targets.

## Quick Reference

| Command | Purpose |
|---------|---------|
| `llmwiki query "<q>"` | Generate an answer from the compiled wiki |
| `llmwiki query "<q>" --save` | Query and persist the answer as a wiki page |
| `llmwiki context "<q>" --json` | Retrieve structured evidence pack (pages, chunks, citations) |
| `wiki/concepts/<slug>.md` | Direct path to concept pages |
| `wiki/index.md` | Auto-generated table of contents |

## Common Mistakes

- **Querying for known targets:** When the target page path is already known, read the file directly instead of running `llmwiki query`. Queries are for discovery, not direct access.
- **Ignoring staleness warnings:** The wiki may be outdated. If `.last-update` is older than 7 days, consider running `ecosystem-wiki-update` before relying on results.
- **Missing compile step:** `llmwiki query` requires a compiled `wiki/` directory. If the index is missing, run `llmwiki compile` first.
