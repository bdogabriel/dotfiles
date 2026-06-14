---
name: gitlab
description: Use when the user asks to create, view, list, merge, approve, update, or check out merge requests, manage MR comments or discussions (create, reply, resolve, diff comments), interact with CI/CD pipelines (status, logs, trigger jobs, retry, cancel), use glab CLI, or mentions GitLab MR, pipeline, or CI operations. Also use when the user wants to review an MR locally or manage GitLab merge requests from the terminal.
---

# GitLab CLI (glab)

Interact with GitLab merge requests, CI/CD pipelines, and repositories via `glab`.

## Preconditions

- `glab` CLI installed (`brew install glab`)
- Authenticated: `glab auth login` or `GITLAB_TOKEN` env var

Verify setup:
```bash
glab version
glab auth status
```

## Target resolution

Most commands accept `<id>`, `<branch>`, or `<url>` as the target. glab resolves the current branch's open MR automatically when no argument is given.

## MR checkout (review MRs locally)

```bash
glab mr checkout 123                      # checkout MR by ID
glab mr checkout 123 --branch my-review   # custom local branch name
glab mr checkout branch-name              # find MR by source branch
glab mr checkout                          # checkout MR for current branch
glab mr checkout https://gitlab.com/org/repo/-/merge_requests/123
glab mr checkout 12 --set-upstream-to=upstream/main
```

After checkout, view the diff to review:
```bash
glab mr diff                              # diff for current branch's MR
```

## MR comments

### Creating comments

```bash
glab mr note create 123 -m "Looks good to me!"
echo "LGTM" | glab mr note create 123    # pipe from stdin
glab mr note create 123                   # open editor
```

**Diff comments** (on specific file/line):
```bash
glab mr note create 123 --file main.go --line 42 -m "Needs refactoring"
glab mr note create 123 --file main.go --line 10:15 -m "Extract this block"  # range
glab mr note create 123 --file main.go -m "General file comment"
```

**Reply to a discussion thread:**
```bash
glab mr note create 123 --reply abc12345 -m "I agree!"
```

**Non-blocking comments** (for bot/CI updates):
```bash
glab mr note create 123 -m "Build status: green" --resolvable=false
```

**Idempotent** (skip if identical note exists):
```bash
glab mr note create 123 -m "LGTM" --unique
```

### Listing and managing comments

```bash
glab mr note list                         # all discussions
glab mr note list --state unresolved      # only unresolved threads
glab mr note list --type diff             # diff comments only
glab mr note resolve <discussion-id> 123  # resolve a thread
```

## CI/CD pipelines

### Checking pipeline status

```bash
glab ci status                            # current branch, one-shot
glab ci status --live                     # real-time updates
glab ci status --branch=main              # specific branch
```

### Viewing job logs

```bash
glab ci trace                             # interactive job picker
glab ci trace lint                        # job by name
glab ci trace 224356863                   # job by ID
glab ci trace lint -b main                # on a specific branch
```

### Interactive pipeline view

```bash
glab ci view                              # interactive dashboard (current branch)
glab ci view main                         # for a specific branch
```

Inside `ci view`: `Enter` toggles job logs, `Ctrl+R` retries jobs, `Ctrl+D` cancels, `Ctrl+Space` shows live trace, `Ctrl+Q` quits.

### Triggering manual jobs

```bash
glab ci trigger                           # interactive picker
glab ci trigger deploy-production         # by job name
```

### Retrying failed jobs

```bash
glab ci retry                             # interactive picker
glab ci retry lint                        # by job name
```

### Creating a new pipeline

```bash
glab ci run --branch main
glab ci run -i DEPLOY:bool(true) -i VERSION:string(1.2.3)   # with inputs
```

### Listing pipelines

```bash
glab ci list --status=failed              # only failed
glab ci list --ref main                   # for a ref
glab ci list --source merge_request_event # triggered by MRs
```

### Child pipelines

glab has no built-in command to navigate child pipelines. Use the GitLab API (`glab api`) to query bridge jobs and downstream pipelines. See `references/cli-reference.md` for the full pattern.

## Other common MR operations

```bash
glab mr create --fill --yes               # create MR from commits, auto-fill
glab mr list --assignee=@me               # my MRs
glab mr list --reviewer=@me               # MRs I review
glab mr view 123 --comments               # MR details with discussions
glab mr approve 123                       # approve
glab mr merge 123                         # merge
glab mr update 23 --draft                 # mark as draft
glab mr update 23 --ready                 # mark as ready
```

## Reference

- **`references/cli-reference.md`** — Full command reference with all flags, subcommands, and advanced options for MR operations, notes/comments, CI/CD pipelines, repository management, and API access.
