# Content Patterns

Reusable patterns for structuring skill content. Not every skill needs all of these — use the ones that fit the task.

## Gotchas

The highest-value content in many skills. Environment-specific facts that defy reasonable assumptions — things the agent will get wrong without being told:

```markdown
## Gotchas

- The `users` table uses soft deletes. Queries must include
  `WHERE deleted_at IS NULL` or results will include deactivated accounts.
- The user ID is `user_id` in the database, `uid` in the auth service,
  and `accountId` in the billing API. All three refer to the same value.
- The `/health` endpoint returns 200 as long as the web server is running,
  even if the database connection is down. Use `/ready` to check full
  service health.
```

Keep gotchas in SKILL.md where the agent reads them before encountering the situation. When an agent makes a mistake you have to correct, add the correction to the gotchas section.

## Templates for Output Format

When the agent must produce output in a specific format, provide a template. This is more reliable than prose descriptions because agents pattern-match well against concrete structures.

**Strict template** (for API responses, data formats):
```markdown
## Report structure

ALWAYS use this exact template:

# [Analysis Title]

## Executive summary
[One-paragraph overview of key findings]

## Key findings
- Finding 1 with supporting data
- Finding 2 with supporting data

## Recommendations
1. Specific actionable recommendation
2. Specific actionable recommendation
```

**Flexible template** (when adaptation is useful):
```markdown
## Report structure

Here is a sensible default format, but use your best judgment:

# [Analysis Title]

## Executive summary
[Overview]

## Key findings
[Adapt sections based on what you discover]

## Recommendations
[Tailor to the specific context]
```

Short templates live inline in SKILL.md. Longer templates, or templates only needed in certain cases, go in `assets/`.

## Checklists for Multi-Step Workflows

An explicit checklist helps the agent track progress and avoid skipping steps. Include the checklist inline so the agent can copy it and check off items:

```markdown
## Workflow

Copy this checklist and check off items as you complete them:

- [ ] Step 1: Analyze the input
- [ ] Step 2: Create the plan
- [ ] Step 3: Validate the plan
- [ ] Step 4: Execute
- [ ] Step 5: Verify output
```

## Validation Loops

Instruct the agent to validate its own work before moving on. The pattern: do the work, run a validator, fix issues, repeat until clean:

```markdown
## Editing workflow

1. Make your edits
2. Run validation: `python scripts/validate.py output/`
3. If validation fails:
   - Review the error message
   - Fix the issues
   - Run validation again
4. Only proceed when validation passes
```

A reference document can also serve as the validator — instruct the agent to check its work against the reference before finalizing.

## Plan-Validate-Execute

For batch or destructive operations, have the agent create an intermediate plan, validate it against a source of truth, and only then execute:

```markdown
## Workflow

1. Extract the current state: `python scripts/analyze.py input` → `state.json`
2. Create a change plan: edit `changes.json` with intended modifications
3. Validate: `python scripts/validate.py state.json changes.json`
   (checks that every referenced field exists, types are compatible,
   and required fields aren't missing)
4. If validation fails, revise `changes.json` and re-validate
5. Apply: `python scripts/apply.py input changes.json output`
```

The key ingredient is step 3: a validation script that checks the plan against the source of truth. Error messages must give the agent enough information to self-correct.

## Conditional Workflows

When the approach depends on context, guide the agent through decision points:

```markdown
## Workflow

1. Determine the modification type:

   **Creating new content?** → Follow "Creation workflow" below
   **Editing existing content?** → Follow "Editing workflow" below

2. Creation workflow:
   - Build from scratch using the template
   - Export to the target format

3. Editing workflow:
   - Read the existing file
   - Modify in place
   - Validate after each change
```

If workflows become large, push each branch into a separate reference file and tell the agent which to read based on the decision.

## Bundling Reusable Scripts

When the agent independently writes the same logic across multiple test runs (building charts, parsing a format, validating output), that's a signal to write the script once and bundle it in `scripts/`:

```markdown
## Utility scripts

**analyze_form.py**: Extract all form fields from the input

```bash
python scripts/analyze_form.py input.pdf > fields.json
```

**validate_fields.py**: Check field mapping against the form schema

```bash
python scripts/validate_fields.py fields.json
```

**fill_form.py**: Apply field values to the form

```bash
python scripts/fill_form.py input.pdf fields.json output.pdf
```

Make clear whether the agent should execute the script or read it as reference. For most utility scripts, execution is preferred.

## Matching Specificity to Fragility

Calibrate how prescriptive each part of the skill is:

- **High freedom** (text instructions): multiple approaches are valid, decisions depend on context. Example: code review guidelines.
- **Medium freedom** (scripts with parameters): a preferred pattern exists, some variation is acceptable. Example: report generation with a template.
- **Low freedom** (exact commands, no parameters): operations are fragile, consistency is critical. Example: database migration commands.

Most skills have a mix. Calibrate each section independently.

## Defaults, Not Menus

When multiple tools or approaches could work, pick a default and mention alternatives briefly rather than presenting them as equal options:

```markdown
# BAD: too many equal options
You can use pypdf, pdfplumber, PyMuPDF, or pdf2image...

# GOOD: clear default with fallback
Use pdfplumber for text extraction. For scanned PDFs requiring OCR,
use pdf2image with pytesseract instead.
```

## Procedures Over Declarations

Teach the agent *how to approach* a class of problems, not *what to produce* for a specific instance:

```markdown
# BAD: specific answer, only useful for this exact task
Join the `orders` table to `customers` on `customer_id`, filter where
`region = 'EMEA'`, and sum the `amount` column.

# GOOD: reusable method, works for any analytical query
1. Read the schema from `references/schema.yaml` to find relevant tables
2. Join tables using the `_id` foreign key convention
3. Apply any filters from the user's request as WHERE clauses
4. Aggregate numeric columns as needed and format as a markdown table
```
