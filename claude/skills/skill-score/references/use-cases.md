# Extracting Use Cases

How to identify and classify use cases

## What is a use case

A **use case** is a distinct task the skill claims to help with. It is defined by a unique combination of: what the user wants to accomplish + what the skill provides distinct guidance for. If the skill has separate instructions or a separate section for it, it's a distinct use case. Variations of the same pattern with different parameters are the same use case (e.g., "create a merge request" is one use case, not one per branch name).

A use case is distinct if it would require meaningfully different assertions from other use cases. Creating an MR and listing MRs have different correctness criteria, so they are distinct. Conversely, "view an MR" and "list MRs with filters" likely share the same assertion patterns and should be treated as one.

## Environment check

Before committing to use cases, skim the skill for external resources it operates on (MRs, pipelines, services, dashboards) and run a quick smoke test for each. Drop any use case that requires resources absent from the environment -- safe use cases with "nothing to operate on" produce meaningless results.

## Classifying safety

For each use case, set `is_safe`:

- `true`: the worst-case outcome is local side effects (creating/deleting files in a temp directory). Read-only operations against external systems are safe.
- `false`: the task involves mutating external systems (deploying, promoting, sending messages, modifying databases, creating resources).

## All-unsafe evaluations

If all use cases have `is_safe: false`, the evaluation can still produce an Effectiveness score -- the "how would you" reframing measures whether the skill guides the agent to the correct plan. The score is valid but execution-level issues are not captured.
