---
name: skill-dedup
description: Use when the user asks to check skills for duplication, find skills that should be merged or split, or analyze a skill collection for unclear boundaries and trigger collisions. For single-skill definition quality, use skill-lint. For single-skill runtime effectiveness scoring, use skill-score.
---

# Skill Dedup

## Overview

Audit a collection of skills for duplication, overlapping responsibilities, unclear boundaries, and description-level trigger collisions. Produces a structured report with severity-ranked findings and actionable recommendations. After the report, offer to apply all fixes.

## Methodology

Follow these phases in order. Do not skip phases.

### Phase 0: Discover Skill Sources

Before reading any skill files, discover ALL locations where skills live:

1. **User skills directory.** The user will specify a target, or it defaults to the repo's skills directory. Resolve symlinks — if two paths point to the same directory (e.g., stow'd `claude/skills/` and `~/.claude/skills/`), pick one and note the duplicate.
2. **Plugin skills.** Check `<plugin-cache-dir>/superpowers/<version>/skills/` for superpowers skills. Use `find` or `ls` to discover the exact path — do not hardcode versions. Also check any other plugin cache directories that contain skills.

List all discovered locations before proceeding. The user may tell you to skip plugin skills.

**Directory extraction command.** Run one command to get the list of skill directories and their SKILL.md paths:

```
find <skill-dir> -maxdepth 2 -name SKILL.md -type f | sort
```

Do the same for each plugin skills directory found.

### Phase 1: Read Every Skill Once

For each SKILL.md path from Phase 0, use the **Read tool** to load the full file. Never use `head`, `cat`, or `grep` via bash — these produce truncated or noisy output and force re-reads later.

From each file, extract:
- `name` (frontmatter)
- `description` (frontmatter, **full text** — do not truncate)
- Directory name (the parent directory of SKILL.md; for plugin skills, prefix with the plugin name, e.g. `superpowers:brainstorming`)
- Dependencies — skill names referenced in the body. Scan for these patterns:
  - Backtick-quoted skill names: `` `skill-name` ``
  - "the X skill" or "use the X skill"
  - "use X" where X matches a known skill name
  - "delegates to the X skill"
  - Explicit cross-reference sections ("Related Skills", "When NOT to Use")

Build the inventory as you go. Do not plan to re-read files later — extract everything on the first pass.

### Phase 2: Description Collision Scan

Compare every pair of skill descriptions (user-to-user, user-to-plugin, plugin-to-plugin) using the full description text from Phase 1. Flag pairs where:
- Both descriptions share trigger keywords (same verbs, same nouns, same scenarios)
- One description claims a use case the other owns
- A user's natural-language request could reasonably match both

Description collisions are HIGH severity — they cause routing ambiguity before any body content is read.

### Phase 3: Body Overlap Analysis

For each pair flagged in Phase 2 (and any others that seem suspicious from the Phase 1 data), use the body content already extracted in Phase 1. Identify:
- **Functional overlap**: both skills perform the same operation, even with different tools
- **Domain overlap**: both skills operate in the same domain (e.g., both touch K8s, both touch Datadog) but from different angles
- **Dependency overlap**: one skill delegates to another — is the delegation chain clean or fragile?

### Phase 4: Cross-Reference Audit

Build a matrix: which skills reference which other skills? Use **full skill names** as both row and column headers. Never abbreviate. A matrix full of abbreviations (ca, cp, db, dd) is unreadable — delete it and rebuild with full names if you catch yourself doing this.

| Skill | -> alpha | -> beta | -> gamma |
|--------|----------|---------|----------|
| alpha  | self     | YES     | NO       |
| beta   | NO       | self    | NO       |
| gamma  | NO       | NO      | self     |

Skills with no outgoing references are isolation risks — they may duplicate functionality that other skills already provide, or fail to guide the agent on when to switch.

### Phase 5: Severity Classification

Apply these criteria consistently:

| Severity | Criteria |
|----------|----------|
| HIGH | Descriptions collide (trigger ambiguity), or bodies perform the same operation, or a merge would eliminate a fragile delegation chain |
| MEDIUM | Same domain without clear boundary documentation, or one skill is missing cross-references to a related skill |
| LOW | Minor wording issues in descriptions, name/directory mismatches, missing "when NOT to use" clauses |

### Phase 6: Recommendations

For each finding, recommend one of:

- **Merge**: skills do the same thing or one is always used with the other. Name the target skill.
- **Cross-reference**: skills are distinct but should reference each other. Specify which skill needs the reference and what it should say.
- **Sharpen descriptions**: skills are distinct but descriptions collide. Propose concrete wording changes.
- **Rename**: name is cryptic or doesn't match directory. Propose the new name.
- **No action**: overlap is benign (e.g., legitimate dependency).

Use this decision framework:

| Situation | Action |
|-----------|--------|
| Same operation, different tools | Merge into the broader skill |
| Always used together (A calls B) | Merge B into A |
| Same domain, different layer (infra vs app) | Cross-reference with boundary clarification |
| Descriptions collide but bodies are distinct | Sharpen descriptions |
| One-way dependency, no back-reference | Add cross-reference in the dependent skill |

### Phase 7: Offer to Fix

After presenting the report, ask: "Apply all recommendations?" Do not wait for the user to initiate — they may not know this is an option. If they say yes, apply every recommendation by editing the affected SKILL.md files. If they want to pick and choose, let them specify which findings to fix.

## Report Template

ALWAYS use this exact structure:

```
# Skill Dedup Report

## Inventory
<Table: # | Skill | Directory | Description | Dependencies>

## Findings

### Finding N: <Title> (<SEVERITY>)
**Skills involved:** <list>
**What overlaps:** <specific description>
**Recommendation:** <action> — <rationale>

<repeat for each finding>

## Cross-Reference Matrix
<Matrix with full skill names — no abbreviations>

## Summary
| Severity | Count |
|----------|-------|
| HIGH     | N     |
| MEDIUM   | N     |
| LOW      | N     |

Net change if all recommendations applied: <N> skills (<old> -> <new>)
```

## Common Mistakes

- **Skipping Phase 0**: diving into user skills without discovering plugin skills. Plugin skills share the same namespace and can collide with user skills.
- **Reading files with bash instead of the Read tool**: `head`, `cat`, `grep` produce truncated or noisy output. Use the Read tool for every SKILL.md. Bash is only for `find`/`ls` discovery, not for reading file contents.
- **Reading the same file multiple times**: extracting descriptions in one pass, bodies in another, dependencies in a third. Extract everything from a single Read tool call.
- **Using abbreviations in the cross-reference matrix**: write full skill names. "ca, cp, db, dd" is unreadable without a legend. If the matrix doesn't fit with full names, split it into groups.
- **Ignoring descriptions**: only analyzing bodies and missing trigger-level collisions. Descriptions are the user's entry point — if they collide, bodies don't matter.
- **Inconsistent severity**: calling a description collision "LOW" because the bodies are distinct. Description collisions are always HIGH — the agent won't load the bodies.
- **Recommending merges without checking dependencies**: proposing to merge A into B when C depends on A's specific output format.
- **Missing isolated skills**: skills that reference no others and are referenced by no others. These are invisible in pairwise analysis but often have the worst boundary problems.
- **Not offering to apply fixes**: producing a report and stopping. Always offer to apply all recommendations.
- **Re-discovering plugin paths on every run**: the plugin cache directory varies. Run `find` to locate it each time — do not hardcode a path from last time.
