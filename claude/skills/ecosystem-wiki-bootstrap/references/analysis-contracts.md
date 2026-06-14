# Analysis Output Contracts

Exact output structures for each analysis type. All files go into `sources/` with YAML frontmatter.

## Source file size limit

Max 100,000 characters per source file. If an analysis produces output exceeding this limit, truncate and add `truncated: true` + `originalChars: <N>` to the YAML frontmatter.

When truncating, prioritize keeping:
1. `## Responsibility boundaries` — the most critical section for implementation decisions
2. `## Implementation patterns` — how features are added, parameter flow rules
3. `## Topology verification` — outbound hosts table for cross-validation
4. Freeform prose about module boundaries, key interfaces, and framework setup
5. `## Dependencies` and `## Overview` — summarize most aggressively

## Architecture (`<repo>-<feature-area>-architecture.md`)

### Frontmatter

```markdown
---
title: <repo-name>/<feature-area> Architecture
source: file://<absolute-path-to-repo>/<feature-area-path>
ingestedAt: <ISO 8601>
---
```

### Overview

<1-2 paragraphs: what this feature area does within the repo, its role in the ecosystem, what other feature areas or repos call it>

### Responsibility boundaries

**Owns:** <what this repo is authoritative for — business logic, data, decisions>

**Delegates to external services:** <what this repo does NOT own — list each external service and what it handles>

**Delegates to other ecosystem repos:** <what this repo delegates to repos in the ecosystem — be specific about which repo handles what>

This section is the single most important output. An agent implementing a feature needs to know where to put things. For this specific feature area: does business logic live here, in another feature area, in an external service, or in another ecosystem repo? Answer: "when I add feature X to this feature area, does the logic go here or somewhere else?"

### Implementation patterns

How features are added to this feature area. Answer: "I need to add a new command/endpoint/feature to this feature area — what files do I touch and what patterns do I follow?"

Include:
- The chain of files touched when adding a feature (e.g., "handler parameter struct → service → client → route registration")
- How parameters flow: CLI flags derive from struct tags, route params map to handler fields, etc.
- How the module/package structure maps to features (e.g., "each feature area is a top-level module under `modules/` with `mod.go` as entry point")
- Code generation steps and their triggers (e.g., "run `make generate-mocks` after changing any interface")
- Common boilerplate or wiring patterns with a concrete example from the codebase

### Topology verification

A short section that answers: "what network hosts does this feature area actually connect to?"

Include at minimum:
- The base URL(s) the HTTP client(s) are configured to point at
- Which ecosystem repo serves at each URL (verified by checking that repo's route registrations)
- External service hostnames this repo calls

This is a machine-parseable section consumed by Step 4 (topology discovery) to cross-validate. Format:

```
### Outbound hosts

| Host URL | Ecosystem repo | Verified |
|----------|---------------|----------|
| https://api.example.com/v1 | example-service | Confirmed: route `/api/v1/items` registered in `internal/infrastructure/router/router.go` |
| https://auth.example.com | auth-service | Confirmed: route `/api/v1/tokens` registered in `internal/infrastructure/router/router.go` |

### External hosts

| Host URL | Service name | Purpose |
|----------|-------------|---------|
| https://llm.example.com | llm-gateway | LLM inference for AI agents |

### Inbound entry points

Structured list of route registration files with their patterns, scoped to this feature area. Each entry is a file path and the route registration pattern used.

```
- internal/infrastructure/router/router.go: HandleFunc("/api/v1/deployments/:serviceName")
```

The `Verified` column proves the analysis checked the host against the target repo, not just inferred from variable names.

The Architecture analysis must derive outbound host URLs from HTTP client configuration — not from variable names, route path prefixes, or semantic similarity to ecosystem repo names. Grep for base URL configuration (YAML config files, env vars, client constructors). Read each host's repo to confirm route registrations match. Scope is ONE feature area — only analyze outbound calls and inbound routes from code under that feature area's directory.

## Conventions (`<repo>-conventions.md`)

Freeform markdown. No mandatory sections beyond frontmatter. Recommended structure:

```markdown
---
title: <repo-name> Conventions
source: file://<absolute-path-to-repo>
ingestedAt: <ISO 8601>
---

## Naming
## Error handling
## Testing
## Code generation
## Build and CI
```

## Gotchas (`<repo>-gotchas.md`)

Freeform markdown. Each gotcha is a self-contained section:

```markdown
---
title: <repo-name> Gotchas
source: file://<absolute-path-to-repo>
ingestedAt: <ISO 8601>
---

## <Gotcha title>

**What:** <what happens>
**Why:** <root cause or historical reason>
**Workaround:** <how to avoid or handle it>
```

Discover from: existing project instructions, comments referencing past issues, test setup quirks, complex error handling paths.

## Cross-repo Implementation Guide (`cross-repo-implementation-guide.md`)

This is the primary cross-repo artifact. It synthesizes per-repo architecture docs, conventions, and gotchas into actionable implementation rules. An agent queries this before implementing any cross-repo feature.

The analysis reads all per-repo architecture docs and the ecosystem topology, then produces a single synthesized document.

### Frontmatter

```markdown
---
title: Cross-repo Implementation Guide
source: ecosystem://repo-a,repo-b,repo-c
ingestedAt: <ISO 8601>
---
```

### Topology and responsibility map

A concise summary of who calls who and who owns what. Answer: "when I need to add a feature, which repos do I touch?"

```markdown
## Topology

<diagram or list showing the call graph with verified edges>

## Responsibility boundaries

| Repo | Role | Owns | Does NOT own |
|------|------|------|--------------|
| <repo-a> | <role description> | <what it owns> | <what it delegates> |
| <repo-b> | <role description> | <what it owns> | <what it delegates> |
```

### Implementation order

The sequence for implementing a cross-repo feature. Answer: "I have a PRD. What do I implement first?"

```markdown
## Implementation order

1. **<repo-name>** — <what to implement here first and why>. This repo defines the contract (types, endpoints) that upstream repos depend on.
2. **<repo-name>** — <what to implement next>. This repo re-exports or wraps the contract for downstream consumers.
3. **<repo-name>** — <what to implement last>. This repo wires the contract into user-facing interfaces.
```

Include the bump chain: when you change X in repo A, you must bump dependency Y in repo B because of Z (e.g., "changing the developer-api's deployment types requires bumping the BFF's go.mod dependency, which then requires bumping the CLI's go.mod — both depend on the type aliases in `pkg/bff`").

### Parameter and type propagation

How parameters, types, and data flow across repos. Answer: "I added a field to the API contract. Where does it show up?"

```markdown
## Parameter and type propagation

### Type flow
<repo-A>/<path-to-types> --(imported by)--> <repo-B>/<path-to-type-aliases> --(imported by)--> <repo-C>/<path-to-consumer>

### Parameter flow
CLI flag (`--<flag-name>`) --(struct tag `option:"<flag-name>"`)--> CLI request struct --(HTTP body/query)--> BFF handler binding --(proxied)--> developer-api handler binding --(mapped to)--> external service client request

### Flag-to-parameter mapping rules
- Struct field names in the CLI options struct map to `--kebab-case` flags via `option:"<name>"` tags
- The same struct fields serialize to JSON camelCase for HTTP requests
- The developer-api handler parameter struct uses `json:"<camelCase>"` tags that must match
- Adding a field to the developer-api contract propagates automatically through type aliases in the BFF
```

### Integration patterns

How repos interact. Answer: "what's the pattern for calls between these repos?"

```markdown
## Integration patterns

### <from-repo> -> <to-repo>

**Pattern:** <proxy | enrichment | direct | two-step resolution>

**Description:** <1-2 sentences about how calls flow>

**Enriched endpoints** (if pattern is mixed):
- `<METHOD /path>` — <how it's enriched, what additional calls are made>
- All other endpoints are blind-proxied

**Auth flow:** <how auth propagates — token chain, header forwarding, middleware points>

**Error propagation:** <how errors cascade — which types, which layers transform them>

**Shared types:** <where types live, how they flow — type aliases, imports, re-exports>

**Canary/feature headers:** <how routing headers propagate, which middleware handles them at each hop>
```

Each topology edge gets one `### <from> -> <to>` subsection. External service calls are documented in a separate `## External service dependencies` section.

### Common implementation workflows

Concrete step-by-step guides for the most common implementation scenarios, derived from the patterns above.

```markdown
## Common implementation workflows

### Adding a new command/module to <repo-a>

1. Define the contract in <repo-c>: add handler parameter struct with `json` tags, register route
2. Bump <repo-b>: type aliases are automatic via `type X = api.X`, but bump the go.mod dependency
3. Wire in <repo-a>: create options struct with `option` tags matching the parameter names, create the command, wire into the module tree
4. Run code generation: <specific commands>
5. Test across all repos: <what to verify>

### Adding a new endpoint to an existing module

<same structure, scoped to the module>
```

### Cross-repo conventions

Patterns that span repos — an agent working in one repo needs to know these.

```markdown
## Cross-repo conventions

- <convention>: <description>. <concrete example from the codebase>.
```

Examples: "test files require `//go:build unit` tag in all three repos", "all three repos use mockery with testify template for mocking", "commit messages follow conventional commits enforced by commitizen in all repos".

### Cross-repo gotchas

Implementation surprises that span repos.

```markdown
## Cross-repo gotchas

### <gotcha title>

**What:** <what happens>
**Why:** <root cause>
**Which repos affected:** <list>
**Workaround:** <how to handle it>
```
