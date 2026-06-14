---
name: skill-lint
description: Statically audits a skill's SKILL.md definition against the Agent Skills spec — no runtime execution. Use when the user asks to lint, audit, or check a skill's definition quality, spec compliance, structure, or description quality. Complements skill-score (runtime evaluation) and skill-dedup (collection overlap analysis).
---

# Skill Lint

Statically audits a skill's definition against the Agent Skills specification and best practices. Complements `skill-score` (runtime evaluation) with definition-quality analysis that runs without executing the skill. For collection-level overlap and duplication analysis, use `skill-dedup`.

## Workflow

1. User points at a target skill directory
2. Run `<skill-lint-path>/.venv/bin/python <skill-lint-path>/scripts/validate.py <target>` — produces JSON with deterministic checks
3. Read the target skill's SKILL.md and any supporting files
4. Evaluate subjective checks against `references/checklist.md`
5. Merge both into a scored report

## Scoring

Every check is binary (pass/fail). The final score is the percentage of checks that pass: `passing / total * 100`.

## Output Template

Render results using the templates in `references/output-templates.md`. Replace `<placeholder>` values with actual results. Do not change labels, wording, or section ordering.

## Edge Cases

- **Directory doesn't exist or has no SKILL.md**: script will report the error. Report it and stop — there's nothing to lint.
- **SKILL.md with valid YAML but empty body**: script checks pass but agent checks will flag content quality issues.
- **Check suppression**: if the user provides a list of check IDs to skip, exclude them from scoring. The report notes which checks were suppressed.
- **Very large reference files**: read only what's needed for the subjective checks. Don't load 500-line reference files in full unless a specific check requires it.
- **Missing optional directories**: `references/` and `scripts/` directories are optional. Their absence is not a failure.
- **YAML parse failure**: most script checks will return `null` (unable to evaluate). Report these distinctly from failures — they indicate the tool couldn't assess, not that the check failed.
