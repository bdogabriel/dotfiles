---
name: k8s-debug
description: |-
  Guides the investigation of Kubernetes issues, such as pods in CrashLoopBackOff, rollouts, replicas, and events, using kubectl commands.
---

# Kubernetes Debug

## Overview

Use this skill to systematically troubleshoot Kubernetes deployments, rollouts, pods, services, replicas, and namespace issues. It guides the assistant through a structured investigation workflow using `kubectl`, covering Argo Rollouts, GitLab/Helm metadata, service-mesh sidecars, and common operational patterns.

The goal is to diagnose what is happening, prove the root cause with commands and observed outputs, and then provide a safe, copy-pasteable fix using real namespace, service, pod, rollout, or deployment names discovered during the investigation.

## When to Use

Use this skill when the user needs help with Kubernetes runtime or deployment issues, including:

- Pods missing, failing, stuck, restarting, or in `CrashLoopBackOff`, `Error`, `ImagePullBackOff`, `Pending`, or `OOMKilled` states.
- Deployments or Argo Rollouts with the wrong replica count, no running pods, or unexpected scaling.
- Services that appear unavailable because pods are not ready or endpoints are missing.
- Namespace-level investigation of recent changes, events, logs, HPA behavior, resource quotas, limits, ConfigMaps, Secrets names, or rollout history.
- Monday-morning or non-production issues that may have been caused by automated cost-saving scale-down jobs.
- Tracing a Kubernetes resource back to GitLab, Helm, CI/CD, or managed-field metadata.

## When Not to Use

Do not use this skill for:

- Debugging non-Kubernetes applications when no cluster, namespace, pod, deployment, rollout, or service is involved.
- Writing application code, unit tests, or business logic unrelated to Kubernetes operations.
- Making cluster-wide administrative changes such as RBAC, node, admission-controller, or control-plane modifications unless the user explicitly has the required permission and asks for guidance.
- Reading or exposing secret values. It is acceptable to list Secret names or describe Secret metadata, but do not print decoded secret contents unless the user explicitly confirms authorization and need.
- Guessing the cause without running or requesting evidence from `kubectl` output.
- Application-level observability (traces, metrics, logs from Datadog APM) — use the `datadog` skill for APM-level investigation.

## Preconditions

Before running commands, confirm that the user has:

- Access to the target Kubernetes cluster and namespace.
- Permission to run read-only `kubectl` commands in the namespace.
- Permission to scale or modify workloads before suggesting mutating commands such as `kubectl scale`.
- A working shell with `kubectl` installed and configured.
- `jq` installed if using commands that pipe JSON annotations into `jq`.

Verify cluster access before investigating:

```bash
kubectl get namespaces
```

If `kubectl get namespaces` fails, stop the Kubernetes investigation and help the user fix authentication or cluster access first.

If `kubectl get namespaces` fails, stop the Kubernetes investigation and help the user fix authentication, VPN, or cluster access first.

## Required Inputs

Collect the minimum context before investigating:

- Namespace name, for example `my-app-namespace`.
- Service, rollout, deployment, or app name, for example `my-service`.
- Observed symptom, for example "pods disappeared", "service is down", "CrashLoopBackOff", or "replicas are 0".
- Approximate start time or recent change window.
- Environment, when relevant, such as sandbox, staging, production, or non-production.

If the user does not know exact names, use namespace-level discovery commands first and infer candidates from labels, rollouts, deployments, pods, services, and recent events.

## Investigation Workflow

Follow this four-phase process. Prefer read-only commands first. Only suggest mutating commands after the root cause is supported by evidence and the user has permission.

### 1. Gather Context

Ask for or derive:

- Namespace.
- Service, app, rollout, or deployment name.
- Symptom.
- When the issue started.
- Whether this is production or non-production.
- Whether any deploy, scaling event, configuration change, or scheduled automation happened recently.

### 2. Check Current State

Start with a broad namespace overview and recent events:

```bash
NAMESPACE="my-app-namespace"
SERVICE_NAME="my-service"

kubectl get all -n $NAMESPACE -o wide
kubectl get pods -n $NAMESPACE -l app.kubernetes.io/name=$SERVICE_NAME
kubectl get events -n $NAMESPACE --sort-by='.lastTimestamp' | tail -20
```

Treat recent events as critical evidence. They often reveal scaling, scheduling failures, image pulls, OOM kills, failed probes, or controller actions.

### 3. Investigate Root Cause

Choose deeper commands based on the symptom.

#### Pod failures

For pods in `CrashLoopBackOff`, `Error`, `OOMKilled`, `Pending`, or repeated restarts:

```bash
kubectl get pods -n $NAMESPACE -o wide
kubectl describe pod POD_NAME -n $NAMESPACE
kubectl logs POD_NAME -n $NAMESPACE --tail=50
kubectl logs POD_NAME -n $NAMESPACE --previous
kubectl get events -n $NAMESPACE --field-selector involvedObject.kind=Pod --sort-by='.lastTimestamp' | tail -10
```

If the pod has multiple containers, list them and inspect the relevant one:

```bash
kubectl get pod POD_NAME -n $NAMESPACE -o jsonpath='{.spec.containers[*].name}'
echo
kubectl logs POD_NAME -n $NAMESPACE -c CONTAINER_NAME --tail=50
```

Common sidecars may include:

- `istio-proxy` for service mesh.
- `datadog-agent` for monitoring/APM.
- `vault-agent` for secrets injection.

A `3/3` readiness count usually means three containers in one pod, not three pods.

#### Replica or scale issues

For missing pods, wrong replica counts, or 0/0 and 0/1 situations:

```bash
kubectl get rollout $SERVICE_NAME -n $NAMESPACE 2>/dev/null || kubectl get deployment $SERVICE_NAME -n $NAMESPACE
kubectl describe hpa $SERVICE_NAME -n $NAMESPACE
kubectl get events -n $NAMESPACE --sort-by='.lastTimestamp' | grep -i scale
```

For Argo Rollouts:

```bash
kubectl get rollout $SERVICE_NAME -n $NAMESPACE
kubectl describe rollout $SERVICE_NAME -n $NAMESPACE
kubectl get rollout $SERVICE_NAME -n $NAMESPACE -o jsonpath='{.spec.replicas}' && echo " <- desired replicas"
kubectl get rollout $SERVICE_NAME -n $NAMESPACE -o jsonpath='{.status.replicas}' && echo " <- actual replicas"
```

For Deployments:

```bash
kubectl get deployment $SERVICE_NAME -n $NAMESPACE
kubectl describe deployment $SERVICE_NAME -n $NAMESPACE
kubectl rollout history deployment/$SERVICE_NAME -n $NAMESPACE
kubectl rollout status deployment/$SERVICE_NAME -n $NAMESPACE
```

#### Services and endpoints

For traffic or availability issues:

```bash
kubectl get svc -n $NAMESPACE
kubectl describe svc $SERVICE_NAME -n $NAMESPACE
kubectl get endpoints $SERVICE_NAME -n $NAMESPACE
kubectl get pods -n $NAMESPACE -l app.kubernetes.io/name=$SERVICE_NAME -o wide
```

If endpoints are empty, focus on pod readiness, labels, selectors, and readiness probe failures.

#### Config, quota, and namespace constraints

Use these when pods are pending, failing to mount config, or blocked by resources:

```bash
kubectl get configmap -n $NAMESPACE
kubectl get secrets -n $NAMESPACE
kubectl get resourcequota -n $NAMESPACE
kubectl get limitrange -n $NAMESPACE
kubectl get events -n $NAMESPACE --field-selector type=Warning --sort-by='.lastTimestamp'
```

Only inspect Secret metadata or names by default. Do not expose secret values.

#### Change history and ownership

Use these commands to identify who or what changed the workload:

```bash
kubectl rollout history rollout/$SERVICE_NAME -n $NAMESPACE
kubectl rollout status rollout/$SERVICE_NAME -n $NAMESPACE
kubectl get rollout $SERVICE_NAME -n $NAMESPACE -o jsonpath='{.metadata.managedFields[*].manager}' | tr ' ' '\n' | sort -u
kubectl get rollout $SERVICE_NAME -n $NAMESPACE -o jsonpath='{range .metadata.managedFields[*]}{.time}{"\t"}{.manager}{"\t"}{.operation}{"\n"}{end}' | sort
```

For GitLab and Helm metadata:

```bash
kubectl get rollout $SERVICE_NAME -n $NAMESPACE -o jsonpath='{.metadata.annotations}'
echo " <- All annotations"

kubectl get rollout $SERVICE_NAME -n $NAMESPACE -o jsonpath='{.metadata.annotations."helm.sh/revision"}'
echo " <- Helm Revision"
```

### 4. Provide the Solution

When presenting the result, include:

- **Evidence:** the command output or observation that supports the conclusion.
- **Explanation:** what happened, such as OOMKilled due to memory limit, no endpoints because pods are not ready, or replicas set to 0 by automation.
- **Fix:** copy-pasteable commands using actual discovered values.
- **Prevention:** follow-up recommendations to prevent recurrence.
- **Escalation:** when the issue requires DevOps/SRE, cluster admin, or audit-log access.

Do not provide commands with unresolved placeholders such as `YOUR_POD_NAME`, `NAMESPACE`, or `SERVICE_NAME` in the final fix. Replace them with actual values from the investigation. If the actual value is not known, ask for it or provide a discovery command first.

## Common Patterns

### Weekend scale-down

Symptom: the service has 0 pods or a rollout shows 0 replicas, often on Monday or after a weekend.

Check:

```bash
kubectl get events -n $NAMESPACE --sort-by='.lastTimestamp' | grep -i "cost-optimizer"
kubectl get events -n $NAMESPACE --sort-by='.lastTimestamp' | grep -i scale
kubectl get cronjobs -A | grep -i scale
```

Possible fix, only after confirming the expected replica count and permission to scale:

```bash
kubectl scale rollout SERVICE_NAME -n NAMESPACE --replicas=1
```

In the final response, replace `SERVICE_NAME`, `NAMESPACE`, and `1` with the actual service, namespace, and intended replica count.

### OOMKilled or memory pressure

Check:

```bash
kubectl describe pod POD_NAME -n $NAMESPACE
kubectl logs POD_NAME -n $NAMESPACE --previous
kubectl get events -n $NAMESPACE --field-selector type=Warning --sort-by='.lastTimestamp'
```

Explain whether the container exceeded its memory limit, whether restarts are increasing, and whether resource limits should be adjusted by the owning team.

### Image or deploy issues

Check:

```bash
kubectl get pods -n $NAMESPACE -o wide
kubectl describe pod POD_NAME -n $NAMESPACE
kubectl rollout history rollout/$SERVICE_NAME -n $NAMESPACE
kubectl get rollout $SERVICE_NAME -n $NAMESPACE -o jsonpath='{.spec.template.spec.containers[0].image}'
echo " <- Current image"
```

Use GitLab and Helm metadata to correlate the running image with a pipeline, branch, and release revision when available.

## Quick Debug Script

When the user wants a repeatable snapshot and the service name is known, provide this script and adapt defaults to the actual namespace and service:

```bash
#!/bin/bash

NAMESPACE="${1:-my-app-namespace}"
SERVICE="${2:-my-service}"

echo "=== Debugging $SERVICE in $NAMESPACE ==="
echo

echo "--- Current Status ---"
kubectl get rollout $SERVICE -n $NAMESPACE 2>/dev/null || kubectl get deployment $SERVICE -n $NAMESPACE
echo

echo "--- Pods ---"
kubectl get pods -n $NAMESPACE -l app.kubernetes.io/name=$SERVICE
echo

echo "--- HPA Status ---"
kubectl get hpa $SERVICE -n $NAMESPACE 2>/dev/null || echo "No HPA found"
echo

echo "--- Recent Events ---"
kubectl get events -n $NAMESPACE --field-selector involvedObject.name=$SERVICE --sort-by='.lastTimestamp' | tail -10
echo

echo "--- Recent Logs ---"
kubectl logs -n $NAMESPACE -l app.kubernetes.io/name=$SERVICE --tail=20 2>/dev/null || echo "No logs available"
echo

echo "--- Last Deployment Info ---"
kubectl get rollout $SERVICE -n $NAMESPACE -o jsonpath='{.metadata.annotations."helm.sh/revision"}' 2>/dev/null && echo " <- Helm Revision"
kubectl get rollout $SERVICE -n $NAMESPACE -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null && echo " <- Current Image"
```

Make it executable and run it:

```bash
chmod +x debug-namespace.sh
./debug-namespace.sh my-app-namespace my-service
```

## Output Conventions

When responding to the user:

- Be evidence-driven and avoid guessing.
- Start with the most relevant finding, not a generic Kubernetes explanation.
- Show the exact commands used or recommended.
- Use actual discovered values in final fix commands.
- Keep read-only diagnostics separate from mutating fix commands.
- Warn before suggesting changes that scale, restart, delete, patch, or otherwise modify resources.
- Mention uncertainty clearly when command output is missing or inconclusive.
- Recommend DevOps/SRE escalation when the issue needs cluster-admin access, audit logs, RBAC changes, node-level investigation, or persistent failures after multiple restarts.

## Limits and Supported Inputs

This skill supports Kubernetes troubleshooting through command-line evidence from `kubectl`. It assumes the user can provide or obtain namespace and workload context and has permission to access the target cluster.

Known limits:

- It cannot access the cluster by itself unless the runtime has authenticated `kubectl` access.
- It cannot safely determine production changes without user confirmation and permissions.
- It does not replace SRE escalation for cluster-level failures, audit-log needs, RBAC changes, or infrastructure exhaustion.
- It should not expose secret values.
- It should not apply destructive or mutating operations without explicit user approval.

## Additional Reference

A detailed Kubernetes namespace debugging cheatsheet is available in `references/kubectl-cheatsheet.md`. Use it as a command reference for namespace status, logs, rollouts, HPA, services, endpoints, ConfigMaps, Secrets metadata, resource quotas, change history, GitLab/Helm annotations, image history, quick scripts, aliases, and escalation guidance.