# Shared Contracts

Shared validation rules and thresholds referenced by both `ecosystem-wiki-bootstrap` and `ecosystem-wiki-update`.

## Architecture doc contract validation

Each Architecture doc must pass these checks:

1. `## Responsibility boundaries` is present with `**Owns:**` and `**Delegates:**` subsections
2. `## Implementation patterns` is present (at least 200 chars of content)
3. `### Outbound hosts` table is present under `## Topology verification` with at least `Host URL` and `Ecosystem repo` columns (table may be empty for leaf/internal-only feature areas)

If validation fails, retry with format-correction prompt (max 1 retry). If still failing, skip cross-repo edges involving that feature area and warn the user.

## Cross-repo analysis minimum threshold

The Cross-repo Implementation Guide analysis runs only when both conditions are met:

1. 2+ feature areas passed Architecture doc contract validation
2. At least one verified topology edge exists

If this threshold is not met, skip the cross-repo analysis and warn the user.

## ecosystem.yaml schema

```yaml
version: 1
name: <ecosystem-name>
repos:
  - name: <repo-name>
    path: /absolute/path/to/repo
topology:
  - from: <repo-name>/<feature-area>
    to: <target-repo-name>/<feature-area>
```

The `topology` key is a list of directed edges. `from` carries feature area granularity. `to` includes the target feature area when route verification resolves it; otherwise just the repo name.

## .last-update file format

Single line, ISO 8601 UTC, no trailing newline. Example: `2026-06-07T14:30:00.000Z`
