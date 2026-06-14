---
name: jira
description: Use when the user asks to search Jira issues, view issue details, create tasks or bug reports, update Jira work items, or diagnose acli failures. Also use when the user mentions Jira tickets, JQL queries, Atlassian issue tracking, or needs ADF-formatted rich descriptions.
---

# Overview

Use this skill to view and manage Atlassian Jira work items through the Atlassian CLI (`acli`). It is intended for agents that need to search Jira, inspect issue details, create tasks or bug reports, and update Jira resources while keeping the user informed before and after each command.

When a Jira field accepts rich content, especially issue descriptions, use ADF (Atlassian Document Format) JSON. See `jira/references/adf-format.md` for supported ADF structures, examples, and best practices.

# When to use

Use this skill when the user asks to:

- Search Jira issues or work items by assignee, text, status, project, or JQL-like criteria.
- View details for a specific Jira issue key.
- Create Jira tasks or bug reports with structured descriptions.
- Update Jira work items after the user has confirmed the intended parameters.
- Diagnose Jira CLI failures, permission errors, or missing configuration.

For automated resolution of SEC vulnerability tickets (SEC-XXXXX) that are reported as Jira issues, use the `the-silence` skill which reads tickets via this skill and automates the fix-to-MR pipeline.

# When not to use

Do not use this skill to delete Jira data or to help the user search for destructive actions. Block searches containing `remove` or `delete`, and block delete actions such as `--action delete`, `--delete`, and `-d`. Explain the safety concern and suggest safer alternatives such as viewing, filtering, archiving, changing status, or asking a Jira administrator.

Do not create or update issues when required information is missing or ambiguous. Ask clarifying questions first. Do not run Jira commands if `acli` is not installed, not authenticated, or the current user lacks the required Jira permissions.

# Preconditions

- Atlassian CLI (`acli`) must be installed and available in the shell path.
- `acli` must already be configured and authenticated for the target Atlassian/Jira instance.
- The user must have permission to view, create, or update the requested Jira resources.
- The user must provide, or be able to clarify, required Jira parameters such as project key, issue type, summary, description, issue key, status, or search terms.
- For rich descriptions, the agent must be able to produce valid ADF JSON with `type: "doc"`, `version: 1`, and valid `content` nodes.

# Operating rules

- Show the full `acli jira ...` command before running it.
- Summarize the result after the command completes.
- Ask for clarification when the user's intent, project, issue type, search filter, description, or update target is unclear.
- Confirm task or update parameters before creating or changing Jira work items.
- Highlight issue keys, summaries, and statuses in responses.
- Report command failures, missing `acli`, authentication problems, and permission issues with practical guidance to resolve them.
- Use ADF JSON for rich description fields when creating or updating issues.
- Validate that ADF JSON is well-formed before using it in a command.
- Keep ADF structures as simple and flat as possible unless the user explicitly needs richer formatting.

# Supported inputs and limits

This skill supports Jira work item operations that can be performed with `acli jira`, including search, view, create, and non-destructive updates. It accepts issue keys, project keys, status names, text search terms, JQL expressions, issue summaries, issue types, and ADF JSON descriptions.

This skill rejects destructive delete operations and requests that appear to search for deletion/removal actions. Jira availability, search results, pagination, allowed fields, issue types, workflow transitions, and rate limits are controlled by the configured Jira instance and the user's permissions. If a command fails because of those constraints, explain the failure and ask the user how to proceed.

# Workflows

## Search active issues assigned to the current user

Use this when the user asks for their open or active Jira work:

```bash
acli jira workitem search --jql "assignee = currentUser() AND status NOT IN (Done, Finished, Cancelled)" --paginate
```

## View issue details

Use this when the user provides a Jira issue key and wants details:

```bash
acli jira workitem view SWDEVAI-215
```

Replace `SWDEVAI-215` with the requested issue key.

## Search issues by text

Use this when the user provides a free-text search term:

```bash
acli jira workitem search --jql "text ~ 'search term'" --paginate
```

If the term is vague, ask for clarification before running the search.

## Search issues by status

Use this when the user asks for issues in a specific status:

```bash
acli jira workitem search --jql "status = 'In Progress'" --paginate
```

Replace `In Progress` with the requested status.

## Search issues in a project

Use this when the user asks for issues in a specific Jira project:

```bash
acli jira workitem search --jql "project = 'PROJ'" --paginate
```

Replace `PROJ` with the requested project key.

## Create a task

Before creating a task, confirm the project, issue type, summary, and description with the user. If the user has not supplied enough information to write a clear task, interview the user to gather the missing context, task details, and references.

```bash
acli jira workitem create --project "PROJ" --type "Task" --summary "Task summary" --description '{"type":"doc","version":1,"content":[{"type":"heading","attrs":{"level":2},"content":[{"type":"text","text":"Context"}]},{"type":"paragraph","content":[{"type":"text","text":"<one paragraph describing why this needs to be done>"}]},{"type":"orderedList","content":[{"type":"listItem","content":[{"type":"paragraph","content":[{"type":"text","text":"<reference 1>"}]}]}]},{"type":"heading","attrs":{"level":2},"content":[{"type":"text","text":"Task"}]},{"type":"bulletList","content":[{"type":"listItem","content":[{"type":"paragraph","content":[{"type":"text","text":"<task item 1>"}]}]},{"type":"listItem","content":[{"type":"paragraph","content":[{"type":"text","text":"<task item 2>"}]}]}]}]}'
```

Replace placeholders before running the command.

## Create a bug report

Before creating a bug, confirm the project, issue type, summary, observed behavior, expected behavior, and reproduction steps. Use ADF for the description.

```bash
acli jira workitem create --project "PROJ" --type "Bug" --summary "Bug Report" --description '{"type":"doc","version":1,"content":[{"type":"paragraph","content":[{"type":"text","text":"Steps to reproduce:"}]},{"type":"orderedList","content":[{"type":"listItem","content":[{"type":"paragraph","content":[{"type":"text","text":"Step 1"}]}]},{"type":"listItem","content":[{"type":"paragraph","content":[{"type":"text","text":"Step 2"}]}]}]}]}'
```

Replace placeholders before running the command.

# ADF conventions

Use ADF for rich Jira descriptions, comments, and custom fields. A minimal ADF document has this shape:

```json
{
  "type": "doc",
  "version": 1,
  "content": [
    {
      "type": "paragraph",
      "content": [
        {
          "type": "text",
          "text": "Your content here"
        }
      ]
    }
  ]
}
```

Common ADF elements include `paragraph`, `text`, `bulletList`, `orderedList`, `listItem`, `codeBlock`, `table`, and formatting marks such as `strong`, `em`, and `code`. Escape special characters correctly in JSON strings, test simple content before complex formatting, and keep reusable templates consistent across similar issues.