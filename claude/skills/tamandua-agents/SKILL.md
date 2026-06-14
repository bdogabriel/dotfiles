---
name: tamandua-agents
description: Use when the user mentions tamandua or when a task involves Tamandua workflows, runs, steps, agents, worktrees, dashboard/control-plane services, logs, pause/resume, or Tamandua-specific output contracts and documentation.
---

# Tamandua Agents

Instructions for operating as a Tamandua workflow agent.

## 1. Confirm CLI access

Use the `tamandua` CLI if available on PATH.

```bash
tamandua version
tamandua source-path
tamandua skill-path
```

If the binary is not on PATH, use the Node entrypoint directly:

```bash
node /path/to/tamandua/dist/cli/cli.js <command>
```

If neither the `tamandua` binary nor the Node entrypoint can be found, clone and install Tamandua from its GitHub repository:

```bash
git clone https://github.com/igorhvr/tamandua ~/my-tamandua
cd ~/my-tamandua
./build
./install
```

This places a `tamandua` symlink at `~/.local/bin/tamandua`. Verify the install worked by running `tamandua version`.

## 2. Follow the step lifecycle exactly

Always execute step commands in this order:

1. `tamandua step peek <agent-id> --run-id <run-id>`
2. If result is `HAS_WORK`, run `tamandua step claim <agent-id> --run-id <run-id>`
3. Parse claim JSON: `{"stepId":"...","runId":"...","input":"..."}`
4. **SAVE `stepId` immediately** and execute the `input` task
5. Report with the saved step id:
   - Success: `tamandua step complete <stepId>` (send status output through stdin)
   - Failure: `tamandua step fail <stepId> "<reason>"`

Use the run ID supplied by your scheduler prompt or workflow context. `step peek` and `step claim` require `--run-id` so agents serving concurrent runs cannot claim each other's work.

Never call `step complete` or `step fail` with an agent ID. They require the claimed step UUID.

## 3. Completion contract

On success, provide structured output that includes:

- `STATUS: done`
- `CHANGES: ...`
- `TESTS: ...`

Then pipe that output into `tamandua step complete <stepId>`.

On failure, call `tamandua step fail <stepId> "<clear reason>"` with actionable detail.

### Polling loop example

```bash
# Phase 1: Peek
tamandua step peek feature-dev_developer --run-id 7aeb4da9-1111-4222-8333-abcdefabcdef
# -> NO_WORK (stop) OR HAS_WORK (continue)

# Phase 2: Claim
tamandua step claim feature-dev_developer --run-id 7aeb4da9-1111-4222-8333-abcdefabcdef
# -> {"stepId":"87409f73-...","runId":"7aeb4da9-...","input":"Implement ..."}
# Save stepId=87409f73-...

# Execute the input task...

# Success report (uses saved stepId)
echo 'STATUS: done
CHANGES: Added skill docs and tests
TESTS: node --test tests/*.test.ts' | tamandua step complete 87409f73-4ba6-492a-be44-30b2b6ffbadb

# Failure alternative
# tamandua step fail 87409f73-4ba6-492a-be44-30b2b6ffbadb "Missing repository path"
```

### Manual step inspection

```bash
tamandua step stories <run-id>
```

Use `step stories` to inspect current story status for a run when diagnosing blocked pipelines.

## Reference files

- **`references/cli-reference.md`** — All CLI commands: workflow management, MCP, logs, dashboard, worktree, control plane, system status, get-ready setup, hermes harness, uninstall, and artifact review guidance.
- **`references/autoresearch.md`** — AutoResearch commands: init, run-experiment, log-experiment, loop, run-loop-iteration, status, next, prune, and wizard.
