# Interpretation Guide

How to diagnose transcript evidence for each axis verdict. The script tells you which axes scored below Acceptable and in what order. This guide tells you what to look for in transcripts.

| Axis | Verdict | Symptom | Look for in transcripts | Fix |
|------|---------|---------|------------------------|-----|
| Effectiveness | critical (negative delta) | Skill made outcomes worse | Did the agent follow the skill's advice and produce worse results? Was the instruction actively wrong, or misinterpreted? | Cite specific instructions that led to failures; correct or remove them |
| Effectiveness | critical (zero delta) | Skill added nothing | Read transcripts for use cases where the skill triggered but assertions didn't improve. Did the agent already know what the skill teaches? Did the skill add unnecessary steps the agent spent time on? | Cut instructions that duplicate training data or add busywork |
| Effectiveness | low | Marginal improvement | Which use cases failed? Does the skill explicitly cover them? | Fill gaps between what the description promises and the body delivers |
| Trigger Accuracy | critical | Fired on <50% of use cases | What did the agent do instead on non-triggered runs? What language in the prompts is absent from the skill's description? | Broaden description to cover the missing phrasings |
| Trigger Accuracy | low | Inconsistent triggering | What distinguishes the prompts where it fired from those where it didn't? | Cover the missing phrasings in the description |
| Efficiency | critical | Cost outweighs benefit | Where were tokens/duration spent? Re-reading large references? Looping on validation? Unnecessary checks the skill prescribed? | Remove or move expensive sections to on-demand references |
| Efficiency | low | Expensive relative to value | Is reference material loaded eagerly vs on demand? Verbose examples or redundant explanations the agent processed without benefit? | Trim or defer non-essential material |
| Discrimination | critical | Most assertions don't measure the skill | Review assertions that passed identically in both configs — they likely test things the model knows from training data | Redesign assertions to test what the skill specifically teaches |
| Discrimination | low | Several non-discriminating assertions | Which assertions passed identically in both configs? | Replace with assertions that exercise skill-specific guidance |
