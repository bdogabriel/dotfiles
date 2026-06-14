---
name: snyk
description: Use when scanning for security vulnerabilities, testing dependencies for known issues, monitoring projects with Snyk, scanning container images or Infrastructure as Code, running SAST code analysis, generating SBOMs, or when the user mentions snyk CLI, vulnerability scanning, security testing of dependencies, Snyk monitoring, or CI/CD security gates.
---

# Snyk CLI

Scan and monitor projects for security vulnerabilities using the Snyk CLI.

For automated resolution of vulnerabilities reported as SEC Jira tickets (with MR creation), use the `the-silence` skill.

## Preconditions

- `snyk` CLI installed (`brew install snyk` or `npm install -g snyk`)
- Authenticated: `snyk auth` (browser OAuth) or `SNYK_TOKEN` env var (CI/CD)
- Internet connection (Snyk CLI queries the Snyk API for vulnerability data)

Verify setup:
```bash
snyk version
snyk config get api     # confirms authentication
```

## Command pattern

```
snyk <command> [--json] [--severity-threshold=<LEVEL>] [--all-projects] [<PATH>]
```

Most commands auto-detect the ecosystem by scanning for manifest files (package.json, pom.xml, build.gradle, go.mod, requirements.txt, etc.). No explicit ecosystem flag is needed.

## Exit codes

| Code | Meaning |
|------|---------|
| 0 | Clean -- no vulnerabilities found |
| 1 | Vulnerabilities found (only `snyk test`) |
| 2 | Failure -- re-run with `-d` for debug |
| 3 | No supported projects detected |

In CI/CD, exit code 1 blocks the pipeline. All other non-zero codes are tool/infrastructure errors.

## Common tasks

### Scan a project for vulnerabilities

```bash
snyk test                          # auto-detect manifest in current dir
snyk test --all-projects           # monorepo: scan all manifests
snyk test --severity-threshold=high # only high/critical
snyk test --json                   # structured output for parsing
```

### Monitor project on snyk.io (continuous)

```bash
snyk monitor                       # upload snapshot for ongoing monitoring
snyk monitor --all-projects        # monorepo
```

### Scan a container image

```bash
snyk container test node:18
snyk container test node:18 --file=Dockerfile  # includes base image recommendations
snyk container monitor node:18                  # continuous monitoring for images
```

### Scan code with SAST

```bash
snyk code test
snyk code test --severity-threshold=high
```

### Scan Infrastructure as Code

```bash
snyk iac test                       # scan Terraform, K8s, CloudFormation, etc.
snyk iac describe --all             # detect unmanaged cloud resources
```

### Generate an SBOM

```bash
snyk sbom --format=cyclonedx1.6+json --json-file-output=sbom.json
```

### CI/CD pattern

```bash
export SNYK_TOKEN=<token>
snyk test --severity-threshold=high --fail-on=upgradable || exit $?
```

Use `--fail-on=upgradable` to only block the pipeline when a fix is available, avoiding noise from vulnerabilities without remediation.

## Reference

- **`references/cli-reference.md`** -- Full command reference with all subcommands, flags, and options for `test`, `monitor`, `container`, `code`, `iac`, `sbom`, `aibom`, `redteam`, `log4shell`, `config`, `policy`, and `ignore`.
