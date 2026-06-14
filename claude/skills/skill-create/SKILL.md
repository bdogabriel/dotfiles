---
name: skill-create
description: Use when the user asks to create a skill, write a skill, improve a skill, or turn a workflow into a reusable skill. For static definition-quality checks, use skill-lint. For collection-level overlap analysis, use skill-dedup. For runtime effectiveness scoring, use skill-score.
---

# Skill Create

Guides the process of creating and improving Agent Skills. The three sibling skills handle evaluation: `skill-lint` checks definition quality, `skill-dedup` checks collection overlap, `skill-score` measures runtime effectiveness. This skill handles the *generative* work — writing the content, iterating on it, and deciding when to delegate to the evaluation skills.

## When to Use

- User asks to create, write, or build a new skill
- User wants to improve, iterate on, or refactor an existing skill
- User wants to turn an observed workflow into a reusable skill
- User demonstrated a workflow in conversation and wants to capture it

## Core Pattern: RED-GREEN-REFACTOR

Creating a skill follows the same cycle as TDD:

| Phase | Action |
|-------|--------|
| **RED** | Run a task *without* the skill. Document what goes wrong. |
| **GREEN** | Write minimal skill content that addresses those failures. |
| **REFACTOR** | Close loopholes found during testing. Repeat. |

**Iron Law: No skill content without a failing example first.**

If you haven't seen an agent fail at the task without the skill, you don't know what the skill needs to teach. The failing example grounds the skill in reality — it prevents writing instructions for hypothetical problems that don't actually occur.

### Phase 1: Capture Intent

Before writing anything, establish:

1. **What should this skill enable?** A specific capability the agent lacks.
2. **When should it trigger?** Concrete user phrases, contexts, symptoms.
3. **What type of skill is it?** Technique (step-by-step how-to), reference (API/docs lookup), or pattern (mental model / way of thinking).
4. **What's the output?** What the agent should produce or how it should behave differently.

If the user already demonstrated the workflow in conversation, extract the pattern from that session — tools used, corrections made, input/output formats observed.

### Phase 2: RED — Establish the Baseline

Write 2-3 realistic test prompts that exercise what the skill should cover. Prompts must:

- Sound like something a real user would type (casual, concrete, with context)
- Not name the skill directly
- Be substantive enough that the agent would benefit from guidance

Run each prompt *without* the skill available. Document exactly what the agent:
- Did correctly (the skill doesn't need to teach this)
- Did wrong or inefficiently (the skill must address this)
- Rationalized when making poor choices (the skill must counter this)

This is the most important phase. The failures you observe here determine what the skill must contain. Everything in the skill should trace back to a specific observed failure.

### Phase 3: GREEN — Write the Skill

#### Structure

Every skill must comply with the Agent Skills specification. See `references/spec-compliance.md` for the full checklist. At minimum:

```
skill-name/
├── SKILL.md          # Required: YAML frontmatter + Markdown body
├── scripts/          # Optional: executable code
├── references/       # Optional: additional documentation
└── assets/           # Optional: templates, resources
```

#### Frontmatter

Two required fields:
- `name`: 1-64 chars, lowercase letters/numbers/hyphens only, must match the parent directory name
- `description`: 1-1024 chars, describes when to use the skill. Written in third person. Cross-reference sibling skills when relevant.

Optional fields: `license`, `compatibility`, `metadata`, `allowed-tools`.

#### Description

The description is the primary triggering mechanism. The agent decides whether to load a skill based on this field alone.

**Rule: Describe when to use the skill, not what it does internally.**

Summarizing the skill's workflow in the description creates a shortcut — the agent may follow the description instead of reading the full body. Keep the description focused on triggering conditions: user phrases, symptoms, contexts.

```yaml
# BAD: summarizes the workflow
description: Use when creating skills — write test cases, run baselines, iterate

# GOOD: triggering conditions only
description: Use when the user asks to create, improve, or iterate on a skill
```

Include specific keywords the agent would search for: tool names, error messages, file types, domain terminology.

**If the description contains colons, quote the entire value.** Unquoted colons in YAML flow scalars are interpreted as nested mapping key separators, which causes parse errors like "Nested mappings are not allowed in compact mappings."

```yaml
# BAD: colons in unquoted description break YAML parsing
description: Covers the full workflow: pod health checks, stabilization windows

# GOOD: double-quoted
description: "Covers the full workflow: pod health checks, stabilization windows"
```

#### Body Content

Write only what addresses the failures observed in Phase 2. For content patterns (gotchas, templates, checklists, validation loops, plan-validate-execute, conditional workflows), see `references/content-patterns.md`.

Keep SKILL.md under 500 lines. Move detailed reference material to `references/` files and tell the agent when to load them. File references must be one level deep from SKILL.md — avoid chains of references.

#### Progressive Disclosure

The agent loads content in three levels:
1. **Metadata** (name + description) — always in context
2. **SKILL.md body** — loaded when the skill triggers
3. **Bundled resources** — loaded on demand

Structure the skill so the agent only loads what it needs. Point to reference files with specific triggers: "See `references/api-errors.md` if the API returns a non-200 status code" is better than "See references/ for details."

### Phase 4: REFACTOR — Iterate

Run the same test prompts from Phase 2 with the skill available. The agent should now handle the task correctly.

If it doesn't:
- Identify what instruction wasn't clear enough
- Tighten the wording, add a gotcha, or close a loophole
- Re-run and verify

Three iterations is typical. Stop when the agent consistently handles all test prompts correctly.

#### Validate with Sibling Skills

After the skill handles its test prompts:

1. **skill-lint**: Check spec compliance and definition quality
2. **skill-dedup**: If adding to a collection, check for overlaps and boundary issues
3. **skill-score**: Measure runtime effectiveness quantitatively (baseline vs with-skill comparison)

Fix issues found by each before considering the skill complete.

## Quick Reference

### Description Optimization

If triggering is unreliable (skill doesn't activate when it should, or activates when it shouldn't):

1. Write 20 trigger eval queries — 10 that should trigger, 10 near-misses that shouldn't
2. Run each query multiple times (3 minimum) to compute a trigger rate
3. Iterate on the description until trigger rates are above threshold for should-trigger and below threshold for should-not-trigger queries

See `references/description-optimization.md` for the detailed process.

## Common Mistakes

- **Writing before testing**: content not grounded in observed failures drifts into hypotheticals
- **Over-explaining**: the agent already knows what a PDF is, what HTTP does, how git works. Only add context the agent lacks
- **Too many options**: pick a default approach and mention alternatives as fallbacks, not as a menu
- **Summarizing workflow in the description**: the agent follows the description instead of reading the body
- **Windows-style paths**: always use forward slashes (`references/guide.md`)
- **Deeply nested references**: keep file references one level deep from SKILL.md
- **Unquoted colons in description values**: YAML interprets colons in flow scalars as nested mapping keys, causing parse failures. Quote the entire description value when it contains colons
- **Time-sensitive information**: use an "old patterns" section for deprecated approaches instead
