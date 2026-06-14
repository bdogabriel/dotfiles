# Description Optimization

The `description` field in SKILL.md frontmatter is the primary mechanism that determines whether an agent invokes a skill. An under-specified description means the skill won't trigger when it should; an over-broad description means it triggers when it shouldn't.

## How Triggering Works

Agents use progressive disclosure to manage context. At startup, they load only the `name` and `description` of each available skill. When a user's task matches a description, the agent reads the full SKILL.md into context.

The description carries the entire burden of triggering. If it doesn't convey when the skill is useful, the agent won't know to reach for it.

One nuance: agents typically only consult skills for tasks that require knowledge beyond what they can handle alone. Simple, one-step requests may not trigger a skill even if the description matches. Tasks that involve specialized knowledge — an unfamiliar API, a domain-specific workflow, or an uncommon format — are where descriptions matter most.

## Writing Effective Descriptions

- **Use third person.** The description is injected into the system prompt. Write "Processes Excel files and generates reports" not "I can help you process Excel files."
- **Focus on triggering conditions, not internal workflow.** Summarizing the skill's process in the description creates a shortcut — the agent may follow the description instead of reading the full body.
- **Be specific.** Include concrete triggers: user phrases, contexts, symptoms, tool names, file types.
- **Err on the side of being pushy.** Explicitly list contexts where the skill applies, including cases where the user doesn't name the domain directly.
- **Keep it concise.** A few sentences to a short paragraph. The spec enforces a hard limit of 1024 characters.

```yaml
# BAD: vague
description: Helps with documents.

# BAD: summarizes workflow (agent may skip reading the body)
description: Use when creating skills — write test cases, run baselines, iterate

# GOOD: specific triggering conditions
description: Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.
```

## Optimization Loop

1. **Create eval queries.** Write 20 queries — 10 that should trigger the skill, 10 near-misses that shouldn't. Near-misses are critical: they share keywords or concepts with the skill but need something different.

2. **Split into train and validation.** 60% train (guide improvements), 40% validation (check generalization). Keep the split fixed across iterations.

3. **Test trigger rates.** Run each query multiple times (3 minimum) and compute the fraction of runs where the skill was invoked. Nondeterministic behavior means a single run isn't reliable.

4. **Iterate on the description.** Address failures:
   - Should-trigger queries not triggering: description may be too narrow. Broaden the scope.
   - Should-not-trigger queries false-triggering: description may be too broad. Add specificity about what the skill does *not* cover.
   - Avoid adding specific keywords from failed queries — find the general category and address that.

5. **Select the best description.** Choose by validation pass rate, not train pass rate. Five iterations is usually enough. If performance isn't improving, the issue may be with the queries rather than the description.
