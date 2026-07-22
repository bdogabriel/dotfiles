# Output Templates

Templates for presenting results to the user. Replace `<placeholder>` values with actual results. Do not change labels, wording, or section ordering.

## Score header

```
## Skill Lint: <skill_name>

**Score:** <passing>/<total> (<percentage>%) | **Status:** <status>
```

Status is `passing` (70%+), `needs_attention` (50-69%), or `failing` (below 50%).

## Spec Compliance

With failures:

```
### Spec Compliance

- [FAIL] <check_id>: <description>
  File: <file_path>:<line_numbers>
```

All passing:

```
### Spec Compliance

All passing.
```

## Description Quality

With failures:

```
### Description Quality

- [FAIL] <check_id>: <description>
  Why: <one-sentence explanation>
```

All passing:

```
### Description Quality

All passing.
```

## Structure & Organization

With failures:

```
### Structure & Organization

- [FAIL] <check_id>: <description>
  File: <file_path>:<line_numbers>
  Why: <one-sentence explanation>
```

All passing:

```
### Structure & Organization

All passing.
```

## Content Quality

With failures:

```
### Content Quality

- [FAIL] <check_id>: <description>
  Why: <one-sentence explanation>
```

All passing:

```
### Content Quality

All passing.
```

## Consistency

With issues:

```
### Consistency

- <issue_description>
```

Without issues:

```
### Consistency

No consistency issues found.
```

## Rules

- Script-evaluated failures get a `File:` pointer. No `Why:` line.
- Agent-evaluated failures get a `Why:` line with one sentence. No `File:` pointer unless the offending content has a specific path.
- Null/unable-to-evaluate: list within the axis as `- [UNABLE] <check_id>: <description>`. Do not count in the score.
- Suppressed checks: list at the bottom as `Suppressed: <check_ids>`. Do not count in the score.
- Check ordering: use the order from `references/checklist.md`.
