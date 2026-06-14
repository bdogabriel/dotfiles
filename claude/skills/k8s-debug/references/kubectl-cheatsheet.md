# Kubernetes Namespace Debugging Cheatsheet

Quick reference for debugging deployments and investigating issues in a Kubernetes namespace.

## Usage

Replace `NAMESPACE` with your target namespace (e.g., `my-app-namespace`)
Replace `SERVICE_NAME` with your service name (e.g., `my-service`)

---

## 1. Current Namespace Status

### Get All Resources Overview
```bash
NAMESPACE="my-app-namespace"
SERVICE_NAME="my-service"

# Quick overview of all resources
kubectl get all -n $NAMESPACE

# Detailed view with wide output
kubectl get all -n $NAMESPACE -o wide
```

### Pods Status
```bash
# List all pods with status
kubectl get pods -n $NAMESPACE

# Filter by service/app label
kubectl get pods -n $NAMESPACE -l app.kubernetes.io/name=$SERVICE_NAME

# Get pod details with age, restarts, and status
kubectl get pods -n $NAMESPACE -o wide

# Describe a specific pod (replace POD_NAME)
kubectl describe pod POD_NAME -n $NAMESPACE

# Check pod events (last 10)
kubectl get events -n $NAMESPACE --field-selector involvedObject.kind=Pod --sort-by='.lastTimestamp' | tail -10
```

### Container Status (3/3 means 3 containers in 1 pod)
```bash
# See all containers in a pod
kubectl get pod POD_NAME -n $NAMESPACE -o jsonpath='{.spec.containers[*].name}'
echo

# Check which containers are ready
kubectl get pod POD_NAME -n $NAMESPACE -o jsonpath='{range .status.containerStatuses[*]}{.name}{"\t"}{.ready}{"\n"}{end}'
```

### Recent Logs
```bash
# Get logs from main container (last 50 lines)
kubectl logs -n $NAMESPACE -l app.kubernetes.io/name=$SERVICE_NAME --tail=50

# Get logs from specific container in pod
kubectl logs POD_NAME -n $NAMESPACE -c CONTAINER_NAME --tail=50

# Follow logs in real-time
kubectl logs -n $NAMESPACE -l app.kubernetes.io/name=$SERVICE_NAME -f

# Get logs from previous crashed container
kubectl logs POD_NAME -n $NAMESPACE --previous

# Logs with timestamps
kubectl logs -n $NAMESPACE -l app.kubernetes.io/name=$SERVICE_NAME --tail=50 --timestamps
```

### Deployments & Rollouts
```bash
# Check if using Deployment or Rollout (Argo CD)
kubectl get deployment $SERVICE_NAME -n $NAMESPACE 2>/dev/null || echo "Not a Deployment"
kubectl get rollout $SERVICE_NAME -n $NAMESPACE 2>/dev/null || echo "Not a Rollout"

# For Deployments:
kubectl get deployment $SERVICE_NAME -n $NAMESPACE
kubectl describe deployment $SERVICE_NAME -n $NAMESPACE

# For Rollouts (Argo CD):
kubectl get rollout $SERVICE_NAME -n $NAMESPACE
kubectl describe rollout $SERVICE_NAME -n $NAMESPACE

# Check current vs desired replicas
kubectl get rollout $SERVICE_NAME -n $NAMESPACE -o jsonpath='{.spec.replicas}' && echo " <- Current spec.replicas"
kubectl get rollout $SERVICE_NAME -n $NAMESPACE -o jsonpath='{.status.replicas}' && echo " <- Actual running replicas"
```

### ReplicaSets
```bash
# List all replicasets (shows deployment history)
kubectl get replicasets -n $NAMESPACE

# Current active replicaset
kubectl get replicasets -n $NAMESPACE | grep -v " 0 "
```

### HPA (Horizontal Pod Autoscaler)
```bash
# Get HPA status
kubectl get hpa -n $NAMESPACE

# Detailed HPA info
kubectl describe hpa $SERVICE_NAME -n $NAMESPACE

# Check HPA metrics
kubectl get hpa $SERVICE_NAME -n $NAMESPACE -o jsonpath='{.spec.minReplicas}' && echo " <- Min replicas"
kubectl get hpa $SERVICE_NAME -n $NAMESPACE -o jsonpath='{.spec.maxReplicas}' && echo " <- Max replicas"
kubectl get hpa $SERVICE_NAME -n $NAMESPACE -o jsonpath='{.status.currentReplicas}' && echo " <- Current replicas"
```

### Services & Endpoints
```bash
# List services
kubectl get svc -n $NAMESPACE

# Check service endpoints (are pods registered?)
kubectl get endpoints $SERVICE_NAME -n $NAMESPACE

# Describe service
kubectl describe svc $SERVICE_NAME -n $NAMESPACE
```

### ConfigMaps & Secrets
```bash
# List configmaps
kubectl get configmap -n $NAMESPACE

# List secrets (names only, not values)
kubectl get secrets -n $NAMESPACE

# Get configmap content
kubectl get configmap CONFIGMAP_NAME -n $NAMESPACE -o yaml

# Describe secret (without showing values)
kubectl describe secret SECRET_NAME -n $NAMESPACE
```

### Namespace Age & Resource Quotas
```bash
# Namespace details
kubectl get namespace $NAMESPACE

# Namespace creation time
kubectl get namespace $NAMESPACE -o jsonpath='{.metadata.creationTimestamp}'

# Resource quotas (if any)
kubectl get resourcequota -n $NAMESPACE

# Limit ranges
kubectl get limitrange -n $NAMESPACE
```

---

## 2. Last Modifications & Change History

### Recent Events (Most Important!)
```bash
# All recent events in namespace (last 20)
kubectl get events -n $NAMESPACE --sort-by='.lastTimestamp' | tail -20

# Events from last hour
kubectl get events -n $NAMESPACE --sort-by='.lastTimestamp' | awk -v date="$(date -u -d '1 hour ago' '+%Y-%m-%dT%H:%M:%S')" '$1 > date'

# Scale-related events
kubectl get events -n $NAMESPACE --sort-by='.lastTimestamp' | grep -i "scale"

# Error/Warning events only
kubectl get events -n $NAMESPACE --field-selector type=Warning --sort-by='.lastTimestamp'

# Events for specific resource
kubectl get events -n $NAMESPACE --field-selector involvedObject.name=$SERVICE_NAME --sort-by='.lastTimestamp'
```

### Rollout/Deployment History
```bash
# Rollout revision history
kubectl rollout history rollout/$SERVICE_NAME -n $NAMESPACE

# Deployment revision history
kubectl rollout history deployment/$SERVICE_NAME -n $NAMESPACE

# Details of specific revision
kubectl rollout history rollout/$SERVICE_NAME -n $NAMESPACE --revision=22

# Rollout status
kubectl rollout status rollout/$SERVICE_NAME -n $NAMESPACE
```

### Who Made Changes? (Managed Fields)
```bash
# Get managed fields (shows which tools/users modified the resource)
kubectl get rollout $SERVICE_NAME -n $NAMESPACE -o yaml | grep -A 30 "managedFields:"

# Extract manager and time info
kubectl get rollout $SERVICE_NAME -n $NAMESPACE -o jsonpath='{.metadata.managedFields[*].manager}' | tr ' ' '\n' | sort -u
echo "Recent modifications:"
kubectl get rollout $SERVICE_NAME -n $NAMESPACE -o jsonpath='{range .metadata.managedFields[*]}{.time}{"\t"}{.manager}{"\t"}{.operation}{"\n"}{end}' | sort

# Check annotations for deployment metadata
kubectl get rollout $SERVICE_NAME -n $NAMESPACE -o jsonpath='{.metadata.annotations}' | jq .
```

### Replica Changes Investigation
```bash
# Current vs previous replicas
kubectl get rollout $SERVICE_NAME -n $NAMESPACE -o jsonpath='{.spec.replicas}' && echo " <- Current spec.replicas"
kubectl get rollout $SERVICE_NAME -n $NAMESPACE -o jsonpath='{.metadata.annotations.previous-replicas}' && echo " <- Previous replicas (Helm annotation)"

# Check if replicas were manually scaled
kubectl get events -n $NAMESPACE | grep -i "scaled"

# Full rollout spec and status
kubectl get rollout $SERVICE_NAME -n $NAMESPACE -o yaml > /tmp/rollout-debug.yaml
grep -E "replicas|lastUpdate|message:" /tmp/rollout-debug.yaml
```

### Git/CI/CD Metadata
```bash
# Check all annotations for CI/CD metadata
kubectl get rollout $SERVICE_NAME -n $NAMESPACE -o jsonpath='{.metadata.annotations}' | jq .

# Common annotation patterns (adjust keys for your platform):
kubectl get rollout $SERVICE_NAME -n $NAMESPACE -o jsonpath='{.metadata.annotations."helm.sh/revision"}'
echo " <- Helm Revision"
```

### Helm Release Info
```bash
# List Helm releases in namespace
kubectl get secrets -n $NAMESPACE | grep helm.release

# Get current Helm release data
kubectl get secret -n $NAMESPACE -l name=$SERVICE_NAME,owner=helm -o yaml | grep -A 5 "data:"

# Helm revision from annotations
kubectl get rollout $SERVICE_NAME -n $NAMESPACE -o jsonpath='{.metadata.annotations."helm.sh/revision"}'
echo " <- Current Helm revision"
```

### Resource Changes Over Time
```bash
# Get resource versions (increments with each change)
kubectl get rollout $SERVICE_NAME -n $NAMESPACE -o jsonpath='{.metadata.resourceVersion}'
echo " <- Resource version (higher = more recent)"

# Generation (spec changes only)
kubectl get rollout $SERVICE_NAME -n $NAMESPACE -o jsonpath='{.metadata.generation}'
echo " <- Generation (increments when spec changes)"

# Last applied configuration
kubectl get rollout $SERVICE_NAME -n $NAMESPACE -o jsonpath='{.metadata.annotations.kubectl\.kubernetes\.io/last-applied-configuration}' | jq .
```

### Image History
```bash
# Current image being used
kubectl get rollout $SERVICE_NAME -n $NAMESPACE -o jsonpath='{.spec.template.spec.containers[0].image}'
echo " <- Current image"

# Images in all replicasets (deployment history)
kubectl get replicasets -n $NAMESPACE -l app.kubernetes.io/name=$SERVICE_NAME -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.template.spec.containers[0].image}{"\n"}{end}'
```

---

## 3. Quick Debugging Workflow

```bash
#!/bin/bash
# Quick debug script - save as debug-namespace.sh

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

echo "--- Replicas ---"
echo -n "Spec replicas: "
kubectl get rollout $SERVICE -n $NAMESPACE -o jsonpath='{.spec.replicas}' 2>/dev/null
echo
echo -n "Previous replicas (annotation): "
kubectl get rollout $SERVICE -n $NAMESPACE -o jsonpath='{.metadata.annotations.previous-replicas}' 2>/dev/null
echo
echo

echo "--- HPA Status ---"
kubectl get hpa $SERVICE -n $NAMESPACE 2>/dev/null || echo "No HPA found"
echo

echo "--- Recent Events (last 10) ---"
kubectl get events -n $NAMESPACE --field-selector involvedObject.name=$SERVICE --sort-by='.lastTimestamp' | tail -10
echo

echo "--- Recent Logs (last 20 lines) ---"
kubectl logs -n $NAMESPACE -l app.kubernetes.io/name=$SERVICE --tail=20 2>/dev/null || echo "No logs available"
echo

echo "--- Last Deployment Info ---"
kubectl get rollout $SERVICE -n $NAMESPACE -o jsonpath='{.metadata.annotations."helm.sh/revision"}' 2>/dev/null && echo " <- Helm Revision"
kubectl get rollout $SERVICE -n $NAMESPACE -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null && echo " <- Current Image"
```

Make it executable:
```bash
chmod +x debug-namespace.sh
./debug-namespace.sh my-app-namespace my-service
```

---

## 4. Common Issues & Solutions

### Issue: No Pods Running (0/0 or 0/1)

```bash
# Check replicas are set
kubectl get rollout $SERVICE_NAME -n $NAMESPACE -o jsonpath='{.spec.replicas}'

# Check for errors in events
kubectl get events -n $NAMESPACE --field-selector type=Warning

# Check HPA
kubectl describe hpa $SERVICE_NAME -n $NAMESPACE
```

**Possible causes:**
- Replicas set to 0 (weekend automation?)
- HPA scaled down due to low usage
- Resource constraints (insufficient CPU/memory in cluster)
- Image pull errors

### Issue: Pods Crash Looping

```bash
# Get pod status
kubectl get pods -n $NAMESPACE

# Check logs from crashed container
kubectl logs POD_NAME -n $NAMESPACE --previous

# Describe pod for events
kubectl describe pod POD_NAME -n $NAMESPACE
```

### Issue: 3/3 vs Expected Container Count

```bash
# List all containers in pod
kubectl get pod POD_NAME -n $NAMESPACE -o jsonpath='{range .spec.containers[*]}{.name}{"\n"}{end}'

# Common sidecars:
# - istio-proxy (service mesh)
# - datadog-agent (APM)
# - vault-agent (secrets injection)
```

---

## 5. Weekend Automation Check

```bash
# Check for CronJobs that might scale down services
kubectl get cronjobs -A | grep -i scale

# Check for recent scale operations around weekend
kubectl get events -A --sort-by='.lastTimestamp' | grep -i scale | grep -E "(Fri|Sat|Sun|Mon)"

# Ask your team:
# "Do we have automated weekend scale-down for sandbox environments?"
```

---

## Tips

1. **Always check events first** - they tell you what happened recently
2. **Compare current vs previous replicas** - helps identify manual scaling
3. **Check on Monday mornings** - weekend automation might have scaled things down
4. **Use `-o wide`** for more details in output
5. **Use `--sort-by='.lastTimestamp'`** to see most recent events
6. **Save full YAML** when debugging: `kubectl get rollout NAME -n NS -o yaml > debug.yaml`

---

## Environment Variables for Quick Access

Add to your `~/.zshrc` or `~/.bashrc`:

```bash
# Kubernetes aliases
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgpw='kubectl get pods -o wide'
alias kdp='kubectl describe pod'
alias kl='kubectl logs'
alias kgr='kubectl get rollout'
alias kge='kubectl get events --sort-by=.lastTimestamp'

# Project specific
export NS_MYAPP="my-app-namespace"
export SVC_MYAPP="my-service"

# Quick commands
alias myapp-pods='kubectl get pods -n $NS_MYAPP -l app.kubernetes.io/name=$SVC_MYAPP'
alias myapp-logs='kubectl logs -n $NS_MYAPP -l app.kubernetes.io/name=$SVC_MYAPP --tail=50'
alias myapp-status='kubectl get rollout $SVC_MYAPP -n $NS_MYAPP'
alias myapp-events='kubectl get events -n $NS_MYAPP --field-selector involvedObject.name=$SVC_MYAPP --sort-by=.lastTimestamp'
```

Reload: `source ~/.zshrc`

---

## When to Escalate

Escalate to DevOps/SRE when:
- Persistent pod failures after multiple restarts
- Cluster resource exhaustion
- Need to modify cluster-level resources (namespaces, RBAC, etc.)
- Suspecting cost-saving automation needs adjustment
- Audit logs needed (requires cluster admin access)

---

**Tip:** Check for automated scale-down jobs if pods disappear over weekends.
