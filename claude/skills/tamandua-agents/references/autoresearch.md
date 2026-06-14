# AutoResearch

AutoResearch runs durable optimization experiment loops. Sessions are stored in project-local files (`autoresearch.config.json`, `autoresearch.jsonl`, `autoresearch.md`). The three core commands are init, run-experiment, and log-experiment.

## Init

`tamandua autoresearch init` creates a new AutoResearch session.

```bash
tamandua autoresearch init --goal <text> --metric <name> --direction <lower|higher> --command <cmd> [options]
```

Required options:
- `--goal <text>` -- description of the optimization target
- `--metric <name>` -- name of the primary metric (e.g. `total_ms`, `val_bpb`)
- `--direction <lower|higher>` -- whether lower or higher is better
- `--command <cmd>` -- benchmark command to run for each experiment

Optional options:
- `--unit <unit>` -- metric unit (e.g. `seconds`, `ms`, `bpb`, `auc`)
- `--metric-regex <regex>` -- regex with the metric value in capture group 1
- `--checks-command <cmd>` -- correctness command to run after successful benchmarks
- `--cwd <dir>` -- project directory (default: current directory)
- `--overwrite` -- replace existing autoresearch files

Example:

```bash
tamandua autoresearch init \
  --goal "speed up test suite" \
  --metric total_ms \
  --unit ms \
  --direction lower \
  --command "pnpm test --run"
```

## Run-Experiment

`tamandua autoresearch run-experiment` executes the configured benchmark command, captures output, parses the metric, runs optional checks, and appends a result to `autoresearch.jsonl`.

```bash
tamandua autoresearch run-experiment [options]
```

Options:
- `--cwd <dir>` -- project directory (default: current directory)
- `--command <cmd>` -- override the configured command for this run
- `--metric-regex <regex>` -- override metric parser for this run
- `--checks-command <cmd>` -- override or provide correctness checks
- `--timeout-seconds <n>` -- command timeout (default: 1800)

Example:

```bash
tamandua autoresearch run-experiment
```

## Log-Experiment

`tamandua autoresearch log-experiment` records the keep/discard decision, learning, and next focus for an experiment. By default, `--status auto` classifies the latest measured result by comparing it with prior accepted runs.

```bash
tamandua autoresearch log-experiment --description <text> [options]
```

Options:
- `--cwd <dir>` -- project directory (default: current directory)
- `--status <status>` -- `auto`, `baseline`, `keep`, `discard`, `crash`, or `checks_failed`
- `--metric <number>` -- metric value if no latest run_result should be used
- `--description <text>` -- what changed in this experiment
- `--hypothesis <text>` -- hypothesis tested
- `--learned <text>` -- evidence learned from the result
- `--next-focus <text>` -- next experiment direction
- `--commit` -- commit kept/baseline results with git
- `--revert-discard` -- revert non-autoresearch tracked files on discard

Example:

```bash
tamandua autoresearch log-experiment \
  --status auto \
  --description "cache parser hot path" \
  --learned "faster but flaky on invalid input" \
  --next-focus "fix cache invalidation"
```

## Loop

`tamandua autoresearch loop` runs a bounded experiment loop with live terminal progress.

```bash
tamandua autoresearch loop [options]
```

An action mode is REQUIRED -- the loop will fail without one.

Action modes:
- `--measure-only` -- Repeated benchmark only (no optimization). Honest measurement; no code/config changes between iterations.
- `--prompt` -- pi-driven optimization. Between iterations, spawns pi to make one small code change guided by AutoResearch history.

Options:
- `--target-metric <number>` -- Stop loop when the target metric is reached (compared via the configured direction)
- `--max-iterations <number>` -- Maximum number of iterations (default: 20)
- `--max-consecutive-failures <n>` -- Stop after N consecutive failures (default: 3)
- `--timeout <duration>` -- Per-pi-action timeout (default: 5m). Format: `<number><s|m|h>` (e.g. `300s`, `10m`, `1h`)
- `--cwd <dir>` -- Project directory (default: current directory)

Stop conditions (the loop stops when any one is met):
- Target metric reached (requires `--target-metric` or config target)
- Max iterations reached (`--max-iterations`)
- Too many consecutive failures (`--max-consecutive-failures`)
- User cancels with Ctrl-C / SIGINT

Progress display shows for each iteration: action mode label (`[measure-only]` or `[prompt]`), `[N/MAX]` iteration number, current focus, measured metric, decision (`keep`/`discard`/`crash`), best metric (loop + all-time), failure count, and stop reason.

After the loop ends, a final summary prints: total iterations, best metric (this loop and all-time), best run number, and kept/discarded/crashed counts.

Cancellation (Ctrl-C / SIGINT) prints the last completed iteration info and leaves `autoresearch.jsonl` in a consistent state.

Examples:

```bash
tamandua autoresearch loop --measure-only --max-iterations 10
tamandua autoresearch loop --prompt --target-metric 0.5 --max-iterations 30
tamandua autoresearch loop --prompt --max-consecutive-failures 5
tamandua autoresearch loop --prompt --timeout 10m --max-iterations 10
```

## Run-Loop-Iteration

`tamandua autoresearch run-loop-iteration` runs a single transactional experiment iteration.

```bash
tamandua autoresearch run-loop-iteration [options]
```

Transactional lifecycle:
1. If `--prompt` is provided, invokes pi to make one candidate code change.
2. Runs the configured experiment command and measures the metric.
3. Logs the result to `autoresearch.jsonl`:
   - `keep`/`baseline` results are committed (`autoresearch*` files excluded).
   - `discard` results are reverted (candidate changes rolled back).
   - `crash`/`checks_failed` results are reverted.
4. Ensures the working tree has no dirty non-autoresearch files.

Options:
- `--cwd <dir>` -- Project directory (default: current directory)
- `--prompt <text>` -- pi agent prompt for code change (optional)
- `--command <cmd>` -- Override the configured experiment command
- `--timeout <duration>` -- Per-pi-action timeout (default: 5m). Format: `<number><s|m|h>` (e.g. `300s`, `10m`, `1h`)
- `--iteration <n>` -- Iteration number (for logging)
- `--description <text>` -- Description of the experiment

Output: JSON object with run number, status, metric, agent success, committed/reverted flags, and the full log entry.

Examples:

```bash
tamandua autoresearch run-loop-iteration --prompt "try smaller LR" --iteration 1
tamandua autoresearch run-loop-iteration --command "uv run train.py" --iteration 5
tamandua autoresearch run-loop-iteration --prompt test --iteration 1
```

## Status

`tamandua autoresearch status` summarizes the experiment loop state.

```bash
tamandua autoresearch status [--cwd <dir>]
```

Status output includes:
- **Baseline** -- the initial measurement before any optimization
- **Best result** -- the best metric seen so far (this session and all-time)
- **Keep count** -- experiments accepted as improvements
- **Discard count** -- experiments that did not improve or were worse
- **Crash count** -- experiments that failed to complete
- **Ratchet prompt** -- evidence-driven prompt for the next experiment
- **Run count** -- total experiments executed

If no session has been initialized, status reports that no AutoResearch session exists.

## Next

`tamandua autoresearch next` prints the evidence-driven ratchet prompt that agents should read before proposing the next experiment.

```bash
tamandua autoresearch next [--cwd <dir>]
```

The ratchet prompt includes: the current baseline and best result, a summary of what was tried in prior experiments, what was learned, and suggested focus direction for the next experiment.

This is the same ratchet prompt displayed by `autoresearch status`. It is intended to be consumed programmatically by agents or scripts.

## Prune

`tamandua autoresearch prune` removes stale session registry rows from the SQLite database. It does **not** touch project-local `autoresearch.jsonl` or `autoresearch.config.json` -- those files remain safe on disk.

```bash
tamandua autoresearch prune --older-than <duration> [--missing] [--dry-run]
```

Options:
- `--older-than <duration>` -- prune sessions older than this duration (**required**)
- `--missing` -- only prune sessions whose project files no longer exist on disk
- `--dry-run` -- show what would be pruned without deleting anything

Duration format: `<number><d|h|m>` (e.g. `30d` = 30 days, `24h` = 24 hours, `30m` = 30 minutes).

Without `--missing`, all sessions older than the duration are pruned. With `--missing`, only sessions whose working directory or config files are no longer accessible are pruned.

## Wizard

`tamandua autoresearch wizard` launches an interactive setup flow that guides you through creating a new AutoResearch session.

```bash
tamandua autoresearch wizard [--cwd <dir>]
```

The wizard interactively asks:
- **Goal** -- what you want to optimize
- **Metric name** -- what to measure (e.g. `total_ms`, `val_bpb`)
- **Direction** -- whether lower or higher is better
- **Command** -- the benchmark command to run for each experiment
- **Unit** (optional) -- metric unit (e.g. `seconds`, `ms`, `bpb`)
- **Checks command** (optional) -- correctness validation after benchmarks

After collecting answers, the wizard generates the exact `tamandua autoresearch init` command needed. If initialization is requested, it optionally executes the init command, then generates the `tamandua autoresearch loop` command to start the optimization loop. No project files are created directly by the wizard -- it delegates to the init command.
