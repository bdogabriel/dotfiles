# Claude Code Agent Configuration

How to create the baseline and eval agents for skill-score in Claude Code.

## Agent files

Create two agent definition files in `.claude/agents/`. These are actual subagent definitions the platform spawns, not JSON descriptions.

Agent files created directly on disk are only loaded at session start. After creating the files, ask the user to restart the session so the agents become available.

Both agents must use `permissionMode: bypassPermissions` so they execute without prompting. They must have generic names, descriptions, and bodies that reveal nothing about evaluation or the skill under test. Both inherit identical tools from the parent (omit `tools`). Do NOT preload skills via `skills` -- the eval agent must discover and invoke the skill naturally through the `Skill` tool, otherwise trigger accuracy cannot be measured.

### Baseline agent

`.claude/agents/skill-score-baseline.md` -- all tools available, but the skill under test is blocked via a `PreToolUse` hook:

```markdown
---
name: skill-score-baseline
description: General-purpose task execution agent
permissionMode: bypassPermissions
hooks:
  PreToolUse:
    - matcher: Skill
      hooks:
        - type: command
          command: python3 -c "import sys,json; d=json.load(sys.stdin); sys.exit(2 if d.get('tool_input',{}).get('skill','')=='<skill_name>' else 0)"
---
```

The hook receives the [PreToolUse input](https://code.claude.com/docs/en/hooks#pretooluse-input) via stdin. When `tool_input.skill` matches `<skill_name>`, it exits with code 2, blocking only that skill invocation. All other skills remain callable.

### Eval agent

`.claude/agents/skill-score-eval.md` -- identical except no hook:

```markdown
---
name: skill-score-eval
description: General-purpose task execution agent
permissionMode: bypassPermissions
---
```

## Verification

Spawn each agent with a prompt that exercises the skill under test:

```
@"skill-score-baseline (agent)" <task that should trigger the skill>
@"skill-score-eval (agent)" <same task>
```

The baseline agent should fail to invoke the skill (hook blocks it). The eval agent should invoke it normally.

