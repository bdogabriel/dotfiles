# Snyk CLI Reference

## Global flags

| Flag | Purpose |
|------|---------|
| `-d`, `--debug` | Output debug logs |
| `--json` | Output results as JSON (supported by `test`, `monitor`, `container`, `iac`, `code`) |
| `--json-file-output=<PATH>` | Write JSON output to a file |
| `--severity-threshold=<low\|medium\|high\|critical>` | Only report vulnerabilities at or above this level |
| `--fail-on=<all\|upgradable\|patchable>` | Fail only when there are fixable issues (used with `test`) |
| `--org=<ORG_ID>` | Run command for a specific Snyk Organization |
| `--all-projects` | Auto-detect all projects in working directory (monorepo support) |
| `--detection-depth=<DEPTH>` | Limit subdirectory search depth with `--all-projects` |
| `--exclude=<NAME>[,<NAME>]...` | Exclude directories/files with `--all-projects` |

## Exit codes

| Code | Meaning |
|------|---------|
| 0 | Success, no vulnerabilities found |
| 1 | `action_needed` -- scan completed, vulnerabilities found (`test` only) |
| 2 | Failure -- re-run with `-d` for debug logs |
| 3 | Failure -- no supported projects detected |

In CI/CD, exit code 1 is the signal to block the pipeline. All other non-zero codes indicate a tool/infrastructure failure.

## Authentication

```bash
snyk auth                                    # OAuth browser flow (default since v1.1293)
snyk auth --auth-type=token <API_TOKEN>      # Legacy token-based auth
SNYK_TOKEN=<token> snyk test                 # CI/CD: pass token via env var
```

Use `SNYK_TOKEN` in CI/CD environments. For service accounts, use `snyk auth --client-id=<ID> --client-secret=<SECRET>`.

Verify auth with `snyk config get api` or by running `snyk test --help` (no auth error = authenticated).

## Config management

```bash
snyk config get <KEY>         # Read a config value
snyk config set <KEY>=<VALUE> # Set a config value
snyk config unset <KEY>       # Remove a config value
snyk config clear             # Remove all config values
```

Common keys: `api`, `endpoint`, `org`, `disable-analytics`, `oci-registry-url`.

## snyk test -- Open-source vulnerabilities

```bash
snyk test [--json] [--all-projects] [--severity-threshold=<LEVEL>] [--fail-on=<MODE>] [<PATH>]
```

Auto-detects manifest files (package.json, pom.xml, build.gradle, go.mod, requirements.txt, etc.) and tests dependencies for known vulnerabilities.

Key options:
- `--json` -- Structured output for parsing
- `--json-file-output=<PATH>` -- Write JSON to file
- `--all-projects` -- Scan all manifests in monorepos/Yarn workspaces
- `--fail-fast` -- Stop on first error with `--all-projects`
- `--severity-threshold=high` -- Only show high/critical issues
- `--fail-on=upgradable` -- Only fail pipeline for fixable issues
- `--prune-repeated-subdependencies` -- De-duplicate transitive deps in output
- `--dev` -- Include dev dependencies
- `--unmanaged` -- Scan all files for known deps (C/C++ only)
- `--print-deps` -- Print dependency tree before scan results

Exit codes: 0 (clean), 1 (vulns found), 2 (error), 3 (no supported projects).

## snyk monitor -- Continuous monitoring

```bash
snyk monitor [--json] [--all-projects] [--org=<ORG_ID>] [<PATH>]
```

Takes a snapshot of dependencies and uploads to snyk.io for ongoing monitoring. Snyk alerts you when new vulnerabilities are disclosed against your snapshot.

Not supported for `snyk code`.

Exit codes: 0 (snapshot created), 2 (error), 3 (no supported projects).

## snyk container -- Container images

```bash
snyk container test <IMAGE> [--json] [--severity-threshold=<LEVEL>] [--file=<DOCKERFILE>]
snyk container monitor <IMAGE> [--json] [--org=<ORG_ID>]
snyk container sbom <IMAGE> [--format=<FORMAT>] [--json-file-output=<PATH>]
```

`test` scans a container image for known vulnerabilities in OS packages and application dependencies. `monitor` uploads the image snapshot for continuous monitoring. `sbom` generates a Software Bill of Materials.

Image can be a tag (`node:18`), digest (`node@sha256:...`), or archive (`docker save` output). For Dockerfile-based scanning, use `--file=<PATH>` to include base image recommendations.

## snyk code -- Static code analysis (SAST)

```bash
snyk code test [--json] [--severity-threshold=<LEVEL>] [<PATH>]
```

Finds security vulnerabilities in your source code using static analysis. Supports JavaScript, TypeScript, Python, Java, Go, C#, Ruby, PHP, Scala, Swift, and more.

Not supported: `monitor` (Code results are point-in-time only).

## snyk iac -- Infrastructure as Code

```bash
snyk iac test [--json] [--severity-threshold=<LEVEL>] [<PATH>]        # Scan IaC files
snyk iac describe [--json] [--all] [--only-managed\|--only-unmanaged] # Detect unmanaged cloud resources
snyk iac update-exclude-policy [--exclude-missing]                     # Auto-generate .snyk exclusions
```

`test` scans Terraform, CloudFormation, Kubernetes, ARM, and Helm files for misconfigurations. `describe` detects unmanaged (drifted) cloud resources in AWS, Azure, or GCP. `update-exclude-policy` creates a `.snyk` policy to exclude approved unmanaged resources from future scans.

## snyk sbom -- Software Bill of Materials

```bash
snyk sbom --format=<FORMAT> [--org=<ORG_ID>] [--all-projects] [--exclude=<NAME>] [<PATH>]
```

Generates an SBOM for a project. Requires Snyk Enterprise plan.

Supported formats: `cyclonedx1.4+json`, `cyclonedx1.4+xml`, `cyclonedx1.5+json`, `cyclonedx1.5+xml`, `cyclonedx1.6+json`, `cyclonedx1.6+xml`, `spdx2.3+json`.

Use `--json-file-output=<FILE>` to write to disk.

## snyk aibom -- AI Bill of Materials

```bash
snyk aibom [--json] [--json-file-output=<PATH>] [<PATH>]            # Generate AIBOM for Python projects
snyk aibom test [--json] [--severity-threshold=<LEVEL>] [<PATH>]    # Test AIBOM against tenant policies
```

Detects AI models, datasets, tools, and libraries used in a Python project. `aibom test` validates the generated AIBOM against your Snyk tenant's AI policies.

## snyk redteam -- AI red teaming

```bash
snyk redteam [--json] [<TARGET>]
```

Runs red teaming scans against AI targets to find vulnerabilities in AI/ML systems.

## snyk log4shell -- Log4Shell scanner

```bash
snyk log4shell [--json] [<PATH>]
```

Scans files for the Log4Shell vulnerability (CVE-2021-44228) in Log4j libraries.

## snyk policy -- View .snyk policy

```bash
snyk policy [<PATH>]
```

Displays the `.snyk` policy file for a package, including ignored vulnerabilities and path exclusions.

## snyk ignore -- Ignore vulnerabilities

```bash
snyk ignore --id=<ISSUE_ID> [--reason=<REASON>] [--expiry=<DATE>] [--policy-path=<PATH>]
```

Adds a vulnerability to the `.snyk` ignore policy. Requires `--reason` and an expiry date. Used to suppress known false positives or accepted risks with documented justification.
