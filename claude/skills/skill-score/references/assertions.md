# Writing Assertions

How to design assertions that measure what the skill teaches.

## General Rules

Write realistic prompts a real user would send. The prompt must not name the skill directly -- it describes a task, and the agent must decide whether to invoke the skill.

Design assertions that test what the model is unlikely to know from training data. If the skill is a CLI wrapper, the model already knows the subcommands — assertions like "the agent used `glab mr checkout`" will pass in both configurations. Test specific flag combinations, error recovery patterns, multi-step workflows, or platform-specific defaults the skill prescribes.

Prompts that are trivial enough that an agent handles correctly without the skill prove nothing. Every prompt must exercise something the skill teaches.

Define at least one binary assertion per use case. Grade each assertion against the actual output and record evidence — a specific quote or file reference, not an opinion.

## Safe Use Cases

Safe use cases have `is_safe: true` — the worst-case outcome is local side effects. The agent executes the prompt normally and assertions verify actual outcomes.

Assertions must be binary and objectively verifiable:

| Good | Weak | Why the weak one fails |
|------|------|------------------------|
| "the output file is valid JSON" | "the output is good" | too vague to grade |
| "the bar chart has labeled axes" | "the chart looks correct" | subjective |
| "the report includes at least 3 recommendations" | "the report uses exactly the phrase 'Total Revenue: $1,234.56'" | too brittle |
| "the agent specified the `--no-verify` flag when committing" | "the agent committed the changes" | the model already knows how to commit; test what the skill specifically teaches |

## Unsafe Use Cases

Unsafe use cases involve mutating external systems (deploying, promoting, sending messages, modifying databases, creating resources). These must be tested without executing those mutations.

Reframe the prompt as a "how would you" or "make a plan for" question — the agent describes what it would do without performing any mutation. Grade the plan against assertions, not execution outcomes.

### Writing assertions for unsafe use cases

Assertions must target the plan, not the outcome:

| Bad (execution outcome) | Good (plan correctness) |
|-------------------------|------------------------|
| "the deployment was completed successfully" | "the agent correctly identified the deployment status and reported completion" |
| "the Slack message was sent to #alerts" | "the agent correctly specified the channel as #alerts and included the incident ID in the message body" |
| "the database migration completed" | "the agent correctly identified the migration order: schema first, then data backfill" |

### What plan-mode evaluation does NOT test

Plan-mode evaluation tests whether the skill guides the agent to the correct decision. It does not test:
- Whether the actual command syntax is correct (the agent may hallucinate flags)
- Whether the external system would accept the operation (auth, permissions, state)
- Whether side effects would cascade (the plan may miss downstream impacts)

A skill where all use cases are unsafe can still be scored, but the score reflects decision guidance quality, not execution quality.
