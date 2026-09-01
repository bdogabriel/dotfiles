# Skill Lint Checklist

~40 checks organized by axis. Each check is binary (pass/fail).

## Spec Compliance

Checks that verify conformance to the Agent Skills specification.

| ID | Check | Evaluator |
|----|-------|-----------|
| spec-yaml-valid | YAML frontmatter is valid | script |
| spec-name-present | `name` field present in frontmatter | script |
| spec-description-present | `description` field present in frontmatter | script |
| spec-name-matches-dir | `name` matches parent directory name | script |
| spec-name-length | `name` length <= 64 characters | script |
| spec-name-regex | `name` matches valid format (lowercase letters, digits, hyphens; no consecutive hyphens) | script |
| spec-no-reserved-name | `name` does not contain reserved words (anthropic, claude) | script |
| spec-description-non-empty | `description` is not empty or whitespace-only | script |
| spec-description-length | `description` <= 1024 characters | script |
| spec-no-xml-name | No XML/HTML tags in `name` | script |
| spec-no-xml-description | No XML/HTML tags in `description` | script |
| spec-compatibility-length | `compatibility` field <= 500 characters (if present) | script |
| spec-license-format | `license` field is a string <= 200 characters (if present) | script |
| spec-description-not-placeholder | `description` is not a placeholder (todo, tbd, add description, etc.) | script |
| spec-description-no-unquoted-colons | `description` value is quoted if it contains colons | script |

## Description Quality

Checks that the description triggers correctly and follows CSO principles.

| ID | Check | Evaluator | What to look for |
|----|-------|-----------|------------------|
| desc-use-when | Description starts with "Use when..." or equivalent triggering language | agent | Description should focus on triggering conditions, not summarize the skill's workflow. Look for descriptions that describe what the skill DOES instead of when to USE it. |
| desc-third-person | Description written in third person | agent | No "I", "we", "you", "your", "me", "my", "our". The description is injected into the system prompt, so first/second person reads as the agent talking to itself. |
| desc-specific | Description includes specific triggers, symptoms, and contexts | agent | Vague descriptions (e.g., "Use when working with data") don't help discovery. Look for concrete scenarios, tool names, error patterns, or situations. |
| desc-keyword-coverage | Description contains keywords agents would search for | agent | The description should include synonyms and variations for the skill's domain. Missing keywords mean the skill won't be found when agents search with different terms. |
| desc-no-workflow-summary | Description does not summarize the skill's process or workflow | agent | When the description summarizes the workflow, agents may follow the description shortcut instead of reading the full skill. The description should only say WHEN, not HOW. |
| desc-concise | Description is concise and doesn't include unnecessary context | agent | Descriptions over ~300 characters rarely add discovery value. Extra length should justify itself with additional triggering conditions. |

## Structure & Organization

Checks that the skill's files and layout follow conventions.

| ID | Check | Evaluator | What to look for |
|----|-------|-----------|------------------|
| struct-skill-md-exists | Directory contains SKILL.md | script | |
| struct-skill-md-lines | SKILL.md line count <= 500 | script | |
| struct-no-windows-paths | No Windows-style paths (`\\`) in skill files | script | |
| struct-reference-depth | No nested references beyond one level from SKILL.md | script | |
| struct-progressive-disclosure | Details deferred to reference files, not all inline in SKILL.md | agent | SKILL.md should be scannable. Long code blocks, exhaustive API docs, or verbose examples should live in reference files. SKILL.md should tell the agent what to do, references should tell it how. |
| struct-section-ordering | Sections follow conventional ordering (Overview, When to Use, Core Pattern, Quick Reference, Common Mistakes) | agent | Skills with non-standard section ordering or missing standard sections are harder to scan. Agents expect consistent structure across skills. |
| struct-supporting-files | Supporting files only for heavy reference (100+ lines) or reusable tools | agent | Extra files that could be inline (short reference, trivial scripts) add navigation cost without benefit. Each file should justify its existence. |
| struct-no-duplicate-content | No duplicate content across skill files | agent | Same information repeated in SKILL.md and a reference file means one copy will go stale. Information should have a single canonical location. |

## Content Quality

Checks that the skill's prose and examples are effective.

| ID | Check | Evaluator | What to look for |
|----|-------|-----------|------------------|
| content-terminology-consistent | Terminology is consistent throughout the skill | agent | Same concept called by different names in different sections. Internal tools or domain terms used without definition. |
| content-gotchas | Gotchas or Common Mistakes section present | agent | Skills without a gotchas section miss the chance to prevent known mistakes. Not every skill needs one, but its absence should be intentional, not an oversight. |
| content-no-too-many-options | Doesn't present too many equivalent options without guidance | agent | Lists of 4+ tools/approaches without a recommendation force the agent to guess. Present the recommended path and mention alternatives only if they have clear trade-offs. |
| content-no-time-sensitive | No time-sensitive information without explicit dates | agent | "Currently", "now", "latest version is X", "as of this writing", these rot silently. Either include a date or phrase it as a permanent fact. |
| content-no-tool-assumptions | Doesn't assume specific tools are available | agent | Mentioning tools without noting they may not be installed, or using tool-specific commands as if universal. If a tool is required, state it as a precondition. |
| content-examples-concrete | Examples use real commands and values, not placeholders | agent | `<your-project>`, `example.com`, `my-app`, these force the agent to translate instead of copy-paste. Concrete examples are immediately usable. |
| content-no-narrative | No narrative storytelling about past incidents | agent | "In session 2025-10-03, we discovered...", these are too specific to be reusable and add word count without guidance value. |
| content-scripts-have-error-handling | Scripts fail loudly, no bare try/except pass | agent | Scripts that silently catch exceptions and continue hide problems. Errors should propagate. |
| content-scripts-no-punt | Scripts don't punt decisions to Claude | agent | "Claude will figure it out" in a script comment, or returning ambiguous results expecting the agent to interpret. Scripts should produce definitive output. |
| content-no-grammar-errors | No grammar mistakes, spelling errors, or typos | agent | Misspelled words, subject-verb disagreement, missing articles, run-on sentences, or punctuation errors make the skill look sloppy and can cause ambiguity. |
| content-english-only | Skill content is written entirely in English | agent | Mixed-language skills (non-English words, phrases, or sections) break agent understanding since the system prompt is English. All prose, headings, and reference material must be in English. |
| content-constants-justified | Magic numbers and constants are self-explanatory or documented | agent | Unjustified thresholds (why 500 lines? why 64 chars?) make the skill's rules feel arbitrary. Either derive from the spec or name the constant descriptively. |
