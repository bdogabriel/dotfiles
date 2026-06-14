# Feature Area Discovery Contract

Output format for the discovery step (Step 3a). One file per repo in `sources/`.

## Feature Area Discovery (`<repo>-feature-areas.md`)

```markdown
---
title: <repo-name> Feature Areas
source: file://<absolute-path-to-repo>
ingestedAt: <ISO 8601>
---

## Feature areas

Structured list of feature area directory paths. Derived from the module/package structure — how the repo organizes its code into distinct functional areas.

Each entry is a directory path relative to the repo root with a brief description.

```
- modules/deployments/    # deployment lifecycle commands
- modules/platform/       # platform resource management
- modules/resilience/     # resilience and failover operations
```

## Inbound entry points

Structured list of route registration files with their patterns, scoped to the entire repo. Each entry is a file path and the route registration pattern used.

```
- internal/infrastructure/router/router.go: HandleFunc("/api/v1/deployments/:serviceName")
- internal/infrastructure/router/router.go: HandleFunc("/api/v1/deployments/{serviceName}")
```
```
