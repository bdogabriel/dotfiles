# GitLab CLI Reference

Full command reference for glab. Commands support `<id>`, `<branch>`, or `<url>` as the target — glab resolves them automatically.

## Authentication

```bash
glab auth login            # interactive login (token or OAuth)
glab auth status           # check current auth state
glab auth logout           # log out
```

For CI/CD, set `GITLAB_TOKEN` env var. For self-hosted instances: `glab auth login --hostname gitlab.example.com`.

## MR operations

### create

```bash
glab mr create --title "Fix login bug" --description "Changes..." [--draft] [--assignee USER] [--reviewer USER] [--label LABEL]
glab mr create --fill                    # auto-fill title/description from commits, push branch
glab mr create --fill --yes              # skip confirmation prompts
glab mr create --fill --web              # open in browser after creation
glab mr create --related-issue 42        # create MR for issue #42
glab mr create -t "title" -d -           # open editor for description
```

Key flags: `--draft`/`--wip` (draft MR), `--remove-source-branch`, `--squash-before-merge`, `--auto-merge`, `--template NAME` (from `.gitlab/merge_request_templates/`), `--create-source-branch`.

### list

```bash
glab mr list                             # open MRs
glab mr list --assignee=@me              # assigned to you
glab mr list --reviewer=@me              # where you're reviewer
glab mr list --search "keyword"          # text search
glab mr list --label needs-review        # by label
glab mr list --draft                     # draft MRs only
glab mr list --all                       # include closed/merged
```

### view

```bash
glab mr view 123                         # show MR details
glab mr view 123 --comments              # include discussion threads
glab mr view 123 --unresolved            # only unresolved discussions
glab mr view 123 --web                   # open in browser
glab mr view 123 -F json                 # JSON output (use with --jq)
glab mr view                             # MR for current branch
```

### diff

```bash
glab mr diff                             # diff for current branch's MR
glab mr diff 123                         # diff for MR #123
glab mr diff 123 --raw                   # raw format, pipeable
glab mr diff 123 --color=never           # no ANSI color
```

### checkout

```bash
glab mr checkout 123                     # checkout MR #123
glab mr checkout 123 --branch my-review  # custom local branch name
glab mr checkout branch-name             # find MR by source branch
glab mr checkout                         # checkout MR for current branch
glab mr checkout https://gitlab.com/org/repo/-/merge_requests/123
glab mr checkout 12 --set-upstream-to=upstream/main
```

### approve / revoke

```bash
glab mr approve 123                      # approve MR
glab mr approve 123 345                  # approve multiple
glab mr revoke 123                       # revoke approval
```

### merge

```bash
glab mr merge 123                        # merge MR
glab mr merge 123 --squash               # squash commits
glab mr merge 123 --rebase               # rebase
glab mr merge 123 --remove-source-branch # delete source branch after merge
glab mr merge 123 --auto-merge=false     # merge immediately, don't wait for pipeline
```

### update

```bash
glab mr update 23 --ready                # mark as ready
glab mr update 23 --draft                # convert to draft
glab mr update 23 --assignee @me         # assign to self
glab mr update 23 --reviewer @me         # add self as reviewer
glab mr update 23 --fill --yes           # update title/desc from commits
glab mr update 23 --target-branch main   # change target branch
```

### close / reopen / delete

```bash
glab mr close 123                        # close MR
glab mr reopen 123                       # reopen MR
glab mr delete 123                       # delete MR
```

## MR comments (notes)

### create

```bash
glab mr note create 123 -m "Looks good to me!"
glab mr note create -m "LGTM"            # MR for current branch
echo "LGTM" | glab mr note create 123    # pipe message
glab mr note create 123                  # open editor to compose
```

**Threading:**
```bash
glab mr note create 123 --reply abc12345 -m "I agree!"     # reply to discussion
```

**Diff comments:**
```bash
glab mr note create 123 --file main.go --line 42 -m "Needs refactoring"
glab mr note create 123 --file main.go --line 10:15 -m "Extract this block"  # line range
glab mr note create 123 --file main.go --old-line 7 -m "Why was this removed?"  # removed line
glab mr note create 123 --file main.go -m "General comment on this file"  # file-level
```

**Non-blocking comments:**
```bash
glab mr note create 123 -m "Build status: green" --resolvable=false
```

**Idempotent comments:**
```bash
glab mr note create 123 -m "LGTM" --unique  # skip if identical note exists
```

### list

```bash
glab mr note list                         # all discussions for current branch's MR
glab mr note list --state unresolved      # only unresolved
glab mr note list --type diff             # diff comments only
glab mr note list --file src/main.go      # comments on specific file
glab mr note list -F json | jq '.[].notes[].body'   # JSON for scripting
```

### resolve / unresolve

```bash
glab mr note resolve <discussion-id> 123  # resolve a discussion
glab mr note reopen <discussion-id> 123   # reopen a discussion
```

### delete

```bash
glab mr note delete <note-id> 123
```

## CI/CD pipelines

### status / get

```bash
glab ci status                            # pipeline status for current branch
glab ci status --live                     # real-time updates
glab ci status --compact                  # condensed view
glab ci status --branch=main              # specific branch

glab ci get                               # pipeline details for current branch
glab ci get -p 12345                      # specific pipeline by ID
glab ci get --merge-request=42            # head pipeline of MR !42
glab ci get --status=failed --with-job-details  # only failed jobs
glab ci get -F json                       # JSON output
```

### view (interactive)

```bash
glab ci view                              # interactive dashboard for current branch
glab ci view main                         # pipeline for main branch
glab ci view -b main                      # same, using flag
glab ci view -p 12345                     # specific pipeline ID
glab ci view -w                           # open in browser
```

Keyboard shortcuts inside `ci view`:
- `Enter` — toggle job log / trace
- `Ctrl+R` / `Ctrl+P` — run/retry/play a job
- `Ctrl+D` — cancel a job, or quit the view
- `Ctrl+Space` — suspend and view logs (like `ci trace`)
- `Ctrl+Q` — quit
- `Esc` / `q` — close log/trace, return to pipeline
- `vi` bindings and arrow keys for navigation

### trace (job logs)

```bash
glab ci trace                             # interactive job selection
glab ci trace 224356863                   # trace by job ID
glab ci trace lint                        # trace by job name
glab ci trace lint -b main                # on a specific branch
glab ci trace lint -p 12345               # in a specific pipeline
```

### trigger (manual jobs)

```bash
glab ci trigger                           # interactive selection
glab ci trigger 224356863                 # trigger by job ID
glab ci trigger deploy-production         # trigger by job name
```

### retry

```bash
glab ci retry                             # interactive selection
glab ci retry 224356863                   # retry by job ID
glab ci retry lint                        # retry by job name
```

### run (create new pipeline)

```bash
glab ci run                               # run pipeline on current branch
glab ci run --branch main                 # run on specific branch
glab ci run --mr                          # run a merged result pipeline
glab ci run -i DEPLOY:bool(true) -i VERSION:string(1.2.3)  # with inputs
```

### list

```bash
glab ci list                              # recent pipelines
glab ci list --status=failed              # only failed
glab ci list --ref main                   # for a specific ref
glab ci list --source merge_request_event # triggered by MRs
glab ci list -F json                      # JSON output
```

### cancel

```bash
glab ci cancel pipeline 12345             # cancel a pipeline
glab ci cancel job 224356863              # cancel a specific job
```

### lint

```bash
glab ci lint                              # validate .gitlab-ci.yml
```

### child pipelines

glab has no built-in command to navigate child pipelines. Use the GitLab API to find bridge jobs and their downstream pipelines.

**Discover child pipelines from a parent pipeline:**
```bash
# list bridge jobs with downstream pipeline IDs, statuses, and URLs
glab api "projects/:id/pipelines/<parent-id>/bridges" \
  | jq '.[] | {name: .name, status: .status, downstream: .downstream_pipeline | {id, status, web_url}}'
```

**Check jobs in a child pipeline:**
```bash
glab api "projects/:id/pipelines/<child-id>/jobs?per_page=50" \
  | jq '.[] | "\(.status)\t\(.stage)\t\(.name)"' -r | column -t
```

**List all child pipelines for a project (filter by source):**
```bash
glab ci list --source parent_pipeline
```

Use `glab ci get -p <pipeline-id>` on the child pipeline ID once found, or `glab ci trace <job-name> -p <pipeline-id>` for specific job logs.

## Other useful commands

```bash
glab repo view                            # open repo in browser
glab repo clone org/repo                  # clone a repo
glab issue create -t "Bug" -d "Details"   # create an issue
glab issue list --assignee=@me            # my issues
glab api /projects/:id/members            # direct API access
```
