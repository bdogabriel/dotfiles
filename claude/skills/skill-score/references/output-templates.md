# Output Templates

Templates for presenting results to the user in Phase 5. Every value comes directly from `results.json`.

## Standard result

```
## Skill Score: <skill_name>

**Score:** <score> | **Model:** <model_version>

| Axis | Score | Weight | Verdict |
|------|-------|--------|---------|
| Effectiveness | <axes.effectiveness.score> | <axes.effectiveness.weight> | <axes.effectiveness.verdict> |
| Trigger Accuracy | <axes.trigger_accuracy.score> | <axes.trigger_accuracy.weight> | <axes.trigger_accuracy.verdict> |
| Efficiency | <axes.efficiency.score> | <axes.efficiency.weight> | <axes.efficiency.verdict> |
| Discrimination | <axes.discrimination.score> | <axes.discrimination.weight> | <axes.discrimination.verdict> |

**Duration:** <duration.without_skill_s>s baseline. <duration.with_skill_s>s with skill. <duration.delta_label> <abs(duration.delta_s)>s.
```

After the table, list each entry in `warnings` as a bullet point.

## Priorities section

The `priorities` array lists axes that scored below Acceptable, sorted by `priority` descending. It defines display order only — the script does not produce recommendation text. You write recommendations from transcript evidence.

For each entry in `priorities`, read the relevant transcripts from `.skill-score/transcripts/` and use the interpretation guide (`references/interpretation-guide.md`) to write a specific, evidence-backed recommendation.

```
### Recommendations

1. **<axis> (<priority>):** <recommendation backed by transcript evidence>
2. **<axis> (<priority>):** <recommendation backed by transcript evidence>
```

## VOID result

When `score` is `"VOID"`:

```
## Skill Score: <skill_name>

**Score:** VOID | **Model:** <model_version>

Evaluation is void: no discriminating assertions — every assertion passed or failed identically in both configurations.
```
