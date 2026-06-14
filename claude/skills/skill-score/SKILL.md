---
name: skill-score
description: Computes a numeric quality score (0.0-1.0) by comparing agent performance with vs without a skill through independent agent runs. Use when asked to score, rate, or quantitatively evaluate a skill's effectiveness. For static definition-quality checks without execution, use skill-lint. For collection-level overlap analysis, use skill-dedup.
---

# Skill Score

Evaluates a skill by comparing agent performance with and without the skill, producing a numeric quality score from 0.0 to 1.0 across four axes: Effectiveness, Trigger Accuracy, Efficiency, and Discrimination. For static definition-quality checks (spec compliance, structure) without runtime execution, use `skill-lint`.

This skill owns the orchestration framework. The harness owns execution. The script owns all scoring logic, formulas, verdicts, and recommendations.

## Harness Requirements

To use this skill, a harness must be able to:

1. **Spawn agents with controlled skill access.** Create agents that either allow or deny a specific skill, while keeping all other skills and tools identical.
2. **Detect skill invocation.** Observe whether an agent invoked the skill under test during a run. Must not rely on prompting the agent to self-report — the agent must not know it is being evaluated.
3. **Collect per-run metrics.** Capture token count and duration for each agent run.
4. **Capture execution transcripts.** Save the full agent transcript (tool calls, outputs, reasoning) for each run. Transcripts are essential for diagnosing *why* an assertion failed.

---

## Orchestration

Follow these phases in order. All file paths are relative to `.skill-score/`. Create this directory at the root of the project being evaluated.

```
.skill-score/
├── eval_design.json
├── agents/
├── baseline_results.json
├── eval_results.json
├── eval_aggregate.json
├── results.json
└── transcripts/
```

### Iron Law

**No data point without an independent agent run.**

Every assertion pass/fail, every trigger count, every token number must come from an agent that executed the task in isolation. Never estimate, simulate, or reason analytically about whether a skill would work. If you didn't spawn an agent and grade its output, you don't have a data point.

**Exception:** unsafe use cases use a reframed prompt that asks the agent to plan without executing. The agent states what it would do; the grader verifies the stated plan. The data point is still from an independent agent run — only the execution is simulated, not the reasoning.

### Phase 0: Configure agents

The evaluation needs two agents. The only difference between them is whether the skill under test is accessible.

**Baseline agent** — all skills and tools the environment normally provides, EXCEPT the skill under test.

**Eval agent** — all skills and tools the environment normally provides, INCLUDING the skill under test.

See `references/agents-setup` folder for harness-specific setup. Before creating the agents, check whether they already exist. If they do, ask: "Agent definitions found. Reuse them?" Skip the question if the user already answered it.

Verify that the only difference between the two agent definitions is the permission for the skill under test. Any other difference invalidates the comparison.

### Phase 1: Design the evaluation

Read the skill's SKILL.md and extract every use case it claims to cover. See `references/use-cases.md` for how to identify and classify use cases.

For each use case:

1. Set `is_safe` (see reference for criteria).
2. Write a realistic prompt. The prompt must not name the skill directly.
3. Define at least one binary assertion. See `references/assertions.md`.

Save the eval design. See `references/examples/eval_design.json` for the expected format.

### Phase 2: Capture baselines

Before spawning agents, check whether `.skill-score/baseline_results.json` exists for the same model version and eval design (same use case IDs and assertion counts). If it does, ask: "Baselines found for model <version>. Reuse them?" Skip the question if the user already answered it. If the user says no, or the baseline results are missing, re-capture.

Run each use case prompt once with the **baseline agent** (skill under test denied).

- **Safe use cases:** Spawn the agent with the prompt. The agent executes normally. Grade the output against assertions.
- **Unsafe use cases:** Reframe the prompt as a "how would you" or "make a plan for" question. The agent produces a plan but does not execute. Grade the plan against assertions.

Record token count, duration, and save the full execution transcript to `.skill-score/transcripts/<use_case_id>-baseline.json`. Save results to `.skill-score/baseline_results.json`. See `references/examples/baseline_results.json` for the expected format.

### Phase 3: Evaluate with skill

Run each use case prompt once with the **eval agent** (skill under test allowed). Same prompts, same assertions, same "how would you" reframing for unsafe use cases.

Record the same data as Phase 2, plus `skill_triggered`: a boolean indicating whether the agent invoked the skill under test. Save transcripts to `.skill-score/transcripts/<use_case_id>-eval.json` and results to `.skill-score/eval_results.json`. See `references/examples/eval_results.json` for the expected format.

### Phase 4: Compute

Run the scoring script:

```
python <path-to-skill>/scripts/compute_score.py .skill-score [--verbose]
```

The script reads `baseline_results.json` and `eval_results.json`, performs all aggregation and scoring, and writes both `eval_aggregate.json` (for auditability) and `results.json` to `.skill-score/`. It prints the score to stdout and always persists the full result. Pass `--verbose` for the per-axis breakdown.

### Phase 5: Interpret and recommend

Read `.skill-score/results.json`. The script provides scores, verdicts, all applicable warnings (deterministic text — render directly), and a `priorities` array that lists non-acceptable axes in display order. The script does NOT produce recommendation text — you write that from transcript evidence.

**Step 1: Render the score table.** Use the templates in `references/output-templates.md`. Every value comes directly from `results.json`. List each `warnings` entry as a bullet point after the table.

**Step 2: Diagnose from transcripts.** For each axis in `priorities`, read the relevant transcripts from `.skill-score/transcripts/` and write a specific, evidence-backed recommendation. Follow the diagnosis guide in `references/interpretation-guide.md`.

**Step 3: Present recommendations.** Use the format from `references/output-templates.md`. Sort by `priority` descending (already done by the script).
