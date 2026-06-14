# Call Flow Tracing (internal method)

Deterministic, grep-driven. Used internally by the Cross-repo Implementation Guide analysis to understand how features flow across repos. Nothing is hardcoded per language or framework.

**Input:** `ecosystem.yaml` (verified topology + repo paths), per-repo architecture docs.

**Output:** Internal understanding of call flow patterns. The Implementation Guide analysis uses this to produce synthesized patterns, not per-endpoint hop tables. Do NOT write `cross-repo-call-chains.md` as a standalone source file.

The goal is to answer: "how does feature X flow through the system?" so the Implementation Guide can extract the pattern and explain it as a rule ("deployment flows through all 3 repos; the BFF enriches get/promote/abort but blind-proxies everything else").

## Phase 1: Extract patterns from architecture docs and code

For each repo, extract three facts:

| Fact | Source | Examples |
|------|--------|----------|
| Feature area roots | `<repo>-feature-areas.md` from the discovery step (Step 3a) — lists all feature area directory paths | `modules/<name>/`, `app/<name>/` |
| Outbound host URLs | `### Outbound hosts` table under `## Topology verification` | `https://bff.internal`, `https://api.internal` |
| Outbound call patterns | Grep the repo's code for HTTP client calls to the outbound host URLs. Identify the pattern used (e.g., `client.DoGet(path)`, `httpClient.Get(url)`) | `client.DoRequest()`, `requests.post(` |
| Inbound entry patterns | Grep the repo's route registration files (e.g., `router.go`, `routes.py`) for path registration patterns | `mux.HandleFunc(`, `@app.route(` |

Feature area roots are discovered from the `## Implementation patterns` prose and by reading the directory structure. Outbound call patterns are discovered by grepping for the host URLs found in `### Outbound hosts`. Inbound entry patterns are discovered by grepping route registration files directly.

## Phase 2: Build feature area index per repo

For each repo, list feature areas from `<repo>-feature-areas.md` (the discovery step output). This file already enumerates all feature areas — no directory scan needed.

Normalize names across repos: lowercase, replace `_` and `-` with `-` (hyphen as canonical separator), strip trailing plural suffixes from the last path segment only when the result is at least 3 characters. Strip `es` when the preceding characters form a consonant that takes `es` plurals (`z`, `x`, `ch`, `sh` — check up to two characters before `es`). Otherwise strip `s`. `s` alone before `es` is excluded because `ses` endings are ambiguous: the base word may end in `se` (where the plural adds only `s`, e.g., `house` -> `houses`) or in `s`/`ss` (where the plural adds `es`, e.g., `class` -> `classes`). Stripping `s` favors the more common case and leaves close matches (Levenshtein <= 1) for the `ss` case. Examples: `boxes` -> strip `es` -> `box`, `services` -> strip `s` -> `service` (not `es`, because `c` is not `z`/`x`/`ch`/`sh`), `houses` -> strip `s` -> `house` (not `es`, because `s` alone before `es` is ambiguous). In ambiguous cases, prefer the longer result. This handles trivial variations (`resource_catalog` vs `resource-catalog`) but won't match semantic equivalents (`deployment` vs `deploy`). Primary resolution is via import/package grep (Phase 5, step 2) and route path match (Phase 5, step 3).

## Phase 3: Trace each topology edge

For each edge `A -> B` in the topology:

1. For each feature area in A, read its entry-point files
2. From A's architecture doc, filter the `### Outbound hosts` table to rows where `Ecosystem repo` = B. Grep A's code for HTTP client calls to those host URLs to find call sites
3. Identify the specific callee: import paths, client types, route path literals
4. Map the call to B's entry point by grepping B for the inbound entry patterns (from B's architecture doc) that match the route/client/endpoint name
5. Record the trace: `<repo-A>/<path>:<line> -> <repo-B>/<path>:<line>`

Fallback: if grep finds no match, the feature area in A does not call B. Skip that edge for that feature area.

## Phase 4: Assemble full chains

Join individual edge traces into complete paths across the topology graph. To join traces across hops, reverse-map each intermediate entry point file path to its owning feature area using the Phase 2 index (check which feature area root the entry point path falls under).

**Linear topology** A -> B -> C:
- Start from each feature area in A
- Follow edge A->B to find B's entry point
- Reverse-map B's entry point path to B's feature area (via Phase 2 index)
- From that B feature area, follow edge B->C to find C's entry point

**Fan-out** A -> B, A -> C:
- Each feature area in A may trace to B, to C, or to both
- Produce separate entries for each resolved path

**Fan-in** A -> C, B -> C:
- A feature area in A traces to C; a feature area in B traces to the same C endpoint
- Note the shared entry point in C

## Phase 5: Resolve feature area identity across repos

Match feature areas across repos using this priority:

1. **Exact name match** — after normalization, feature area names are identical
2. **Import/package grep** — grep A's code for import paths or package references that identify which feature area in B is being called. The referenced package is the authoritative callee feature area name
3. **Route path match** — if the caller contains route path string literals, match them against the callee's inbound entry pattern registrations
4. **Unresolved** — if no match after all three strategies, emit a warning and list the feature area as "unresolved" for that edge. Do not fabricate a connection

## Phase 6: Extract patterns

The Implementation Guide analysis runs this algorithm internally for 2-3 representative feature areas (not all of them). After tracing individual paths, extract the patterns:

1. **Group by pattern, not by endpoint.** Feature areas that follow the same flow are combined. E.g., "deployment, platform, resilience, and selfapproval all follow the same pattern: CLI calls BFF, BFF blind-proxies to developer-api, developer-api calls external service."

2. **Identify the exceptions.** If most feature areas follow one pattern but a few don't, highlight the exceptions. E.g., "deployment get/promote/abort are enriched by the BFF; all other deployment sub-commands are blind-proxied."

3. **Note responsibility handoffs.** At each hop, note who owns the business logic. E.g., "the developer-api is a thin orchestration layer — business logic for deployments lives in deploy-service (external), not in developer-api."

4. **Feed patterns into the Implementation Guide.** The patterns discovered here become the `### <from> -> <to>` subsections in the Implementation Guide's `## Integration patterns` section, and inform the `## Common implementation workflows` section.

## Edge cases

| Case | Handling |
|------|----------|
| One feature area calls multiple callee endpoints | List all calls as sub-branches under the same feature area |
| Multiple feature areas share one callee endpoint | Cross-reference: note "also called by `<other-feature-area>`" |
| A hop aggregates multiple downstream calls | List all downstream calls in that hop's row |
| A hop has no downstream call (leaf node) | Mark next hop as "none — terminal" |
| No match found after all resolution strategies | Warn that the feature area is unresolved for that edge; skip it when extracting patterns |
| Feature area calls a service outside the ecosystem | Document the external dependency, mark the edge as "external" |
