---
name: google-workspace
description: Use when the user asks to send email, read inbox, check calendar, list or create events, read or write spreadsheets, work with Google Docs, create or read Google Slides presentations, manage Google Meet, or uses the gws CLI.
---

# Google Workspace CLI (gws)

Interact with Google Workspace services (Gmail, Calendar, Sheets, Docs, Slides, Meet) through the `gws` command-line tool.

## Preconditions

- `gws` installed at `/opt/homebrew/bin/gws` (v0.22.5)
- Authenticated via OAuth2 (`gws auth login`)
- Credentials stored encrypted in macOS keychain

## Command Pattern

```
gws <service> <resource> [sub-resource] <method> [flags]
```

## Flag conventions

**Helpers (`+` prefix)** use direct named flags: `--to`, `--subject`, `--document`, `--text`, etc.

**Raw API methods** use `--params '<JSON>'` for query/URL parameters and `--json '<JSON>'` for request bodies.

## Universal Flags

| Flag | Purpose |
|------|---------|
| `--params '<JSON>'` | Query/URL parameters (raw API methods only) |
| `--json '<JSON>'` | Request body for POST/PATCH/PUT (raw API methods only) |
| `--format <FMT>` | Output format: `json` (default), `table`, `yaml`, `csv` |
| `--page-all` | Auto-paginate, one JSON line per page (NDJSON) |
| `--page-limit <N>` | Max pages with `--page-all` (default: 10) |
| `--page-delay <MS>` | Delay between pages in ms (default: 100) |
| `--dry-run` | Validate request without executing |

## Service Overview

### Gmail

Helpers (prefixed with `+`):

- `gws gmail +triage` --- unread inbox summary (sender, subject, date)
- `gws gmail +send` --- send an email
- `gws gmail +read` --- read a message and extract body or headers
- `gws gmail +reply` / `+reply-all` --- reply to a message
- `gws gmail +forward` --- forward a message
- `gws gmail +watch` --- stream new emails as NDJSON

Direct API access via `gws gmail users <resource> <method>` where resource is `messages`, `threads`, `labels`, `drafts`, `settings`, or `history`.

### Calendar

Helpers:

- `gws calendar +agenda` --- upcoming events across all calendars
- `gws calendar +insert` --- create a new event

Direct API: `gws calendar <resource> <method>` where resource is `calendars`, `events`, `acl`, `calendarList`, `freebusy`, `settings`, or `colors`.

### Sheets

Helpers:

- `gws sheets +read` --- read values from a spreadsheet
- `gws sheets +append` --- append a row to a spreadsheet

Direct API: `gws sheets spreadsheets <method>` (get, create, batchUpdate, values.get, values.update, etc.)

### Docs

Helpers:

- `gws docs +write` --- append text to a document

Direct API: `gws docs documents <method>` (get, create, batchUpdate)

### Slides

Direct API: `gws slides presentations <method>` (get, create, batchUpdate)

### Meet

Direct API: `gws meet <resource> <method>` where resource is `conferenceRecords` or `spaces`.

## Schema Discovery

To see available methods, parameters, and descriptions for any API endpoint:

```
gws schema <service>.<resource>.<method>
```

Examples:

```
gws schema gmail.users.messages.list
gws schema calendar.events.insert
gws schema sheets.spreadsheets.values.get
```

The response includes HTTP method, parameter names, types, required/optional status, enums, and descriptions.

## Output Formats

Default is `json`. Use `--format table` for human-readable output on list operations. Use `--format yaml` or `--format csv` as needed.

When binary content is expected (e.g., Gmail attachment, exported file), use `--output <PATH>` to write to a file instead of stdout.

## Pagination

Most list methods support pagination. Use `--page-all` to fetch all pages, adding `--page-limit` if a cap is needed. Each page is emitted as a separate JSON line (NDJSON format).

## Common Tasks

### Gmail

```
# Unread inbox summary
gws gmail +triage

# List recent messages
gws gmail users messages list --params '{"userId":"me","maxResults":10}' --format table

# Send email
gws gmail +send --to email@example.com --subject 'Hello' --body 'Message text'

# Read a specific message
gws gmail +read --id '<id>'

# Watch for new emails (streaming)
gws gmail +watch
```

### Calendar

```
# Upcoming events
gws calendar +agenda

# List events for a date range
gws calendar events list --params '{"calendarId":"primary","timeMin":"2026-06-02T00:00:00Z","timeMax":"2026-06-09T00:00:00Z"}' --format table

# Create an event
gws calendar +insert --summary 'Team Sync' --start '2026-06-03T14:00:00' --end '2026-06-03T15:00:00'

# List calendars
gws calendar calendarList list --format table
```

### Sheets

```
# Read values from a range
gws sheets +read --spreadsheet '<id>' --range 'Sheet1!A1:D10'

# Get spreadsheet metadata
gws sheets spreadsheets get --params '{"spreadsheetId":"<id>"}'

# Append a row
gws sheets +append --spreadsheet '<id>' --values 'col1,col2,col3'
```

### Docs

```
# Get document content
gws docs documents get --params '{"documentId":"<id>"}'

# Create a new document
gws docs documents create --json '{"title":"My Document"}'

# Append text to a document
gws docs +write --document '<id>' --text 'Content to append'
```

### Slides

```
# Get presentation metadata
gws slides presentations get --params '{"presentationId":"<id>"}'

# Create a presentation
gws slides presentations create --json '{"title":"My Presentation"}'
```

### Meet

```
# List conference records
gws meet conferenceRecords list --format table

# Get a space
gws meet spaces get --params '{"name":"spaces/<id>"}'
```

## Input Conventions

- All IDs (messageId, spreadsheetId, documentId, presentationId, fileId, calendarId) must be raw strings from Google Workspace URLs.
- Calendar can accept `"primary"` as the calendarId for the user's default calendar.
- For Gmail, `userId` can be `"me"` for the authenticated user.
- Dates use ISO 8601 format (`2026-06-02T14:00:00Z`).

## Limits and Known Constraints

- Rate limits are imposed by the underlying Google APIs. If a request fails with a quota error, back off and retry.
- Binary data (attachments, exports) requires the `--output` flag to write to a file.
- Some admin-level operations may not be available depending on the authenticated user's Workspace permissions.
- Schema discovery is read-only and does not consume API quota.

## Additional Resources

- **`references/services-reference.md`** --- detailed resource trees and method lists for Gmail, Calendar, Sheets, Docs, Slides, and Meet.
