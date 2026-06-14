# GWS Services Reference

Detailed resource trees and methods for supported Google Workspace services.

## Gmail

```
gws gmail <command>
```

### Helpers

| Command | Purpose |
|---------|---------|
| `+triage` | Unread inbox summary (sender, subject, date) |
| `+send` | Send an email |
| `+read` | Read a message, extract body or headers |
| `+reply` | Reply to a message (auto-threading) |
| `+reply-all` | Reply-all to a message (auto-threading) |
| `+forward` | Forward a message to new recipients |
| `+watch` | Stream new emails as NDJSON |

### Resource: users

```
gws gmail users <sub-resource> <method>
```

| Sub-resource | Common Methods |
|-------------|----------------|
| `messages` | list, get, send, delete, modify, insert, batchDelete, batchModify, import, trash, untrash |
| `threads` | list, get, delete, modify, trash, untrash |
| `labels` | list, get, create, delete, patch, update |
| `drafts` | list, get, create, delete, send, update |
| `settings` | getAutoForwarding, updateAutoForwarding, getImap, updateImap, getPop, updatePop, getVacation, updateVacation |
| `settings.filters` | list, get, create, delete |
| `settings.sendAs` | list, get, create, delete, patch, update, verify |
| `history` | list |

### Common `+read` usage

```
gws gmail +read --id '<id>'          # plain text body
gws gmail +read --id '<id>' --headers  # body + headers
gws gmail +read --id '<id>' --format json  # JSON output
```

### Common `+send` usage

```
gws gmail +send --to '...' --cc '...' --bcc '...' --subject '...' --body '...'
```

### Message search

Use the `q` parameter with `messages list`:

```
gws gmail users messages list --params '{"userId":"me","q":"from:example@domain.com","maxResults":10}'
```

Standard Gmail search operators work: `from:`, `to:`, `subject:`, `before:`, `after:`, `is:unread`, `has:attachment`, etc.

---

## Calendar

```
gws calendar <command>
```

### Helpers

| Command | Purpose |
|---------|---------|
| `+agenda` | Show upcoming events across all calendars |
| `+insert` | Create a new event |

### Resources

```
gws calendar <resource> <method>
```

| Resource | Common Methods |
|----------|---------------|
| `calendars` | get, clear, delete, insert, patch, update |
| `events` | list, get, insert, delete, patch, update, move, quickAdd, watch, import, instances |
| `acl` | list, get, insert, delete, patch, update, watch |
| `calendarList` | list, get, insert, delete, patch, update, watch |
| `freebusy` | query |
| `settings` | list, get |
| `colors` | get |

### Common event list parameters

```
--params '{"calendarId":"primary","timeMin":"<ISO>","timeMax":"<ISO>","maxResults":20,"singleEvents":true,"orderBy":"startTime"}'
```

### Common event insert parameters

```
--params '{"calendarId":"primary","summary":"...","location":"...","description":"...","start":"<ISO>","end":"<ISO>","attendees":[{"email":"..."}]}'
```

---

## Sheets

```
gws sheets <command>
```

### Helpers

| Command | Purpose |
|---------|---------|
| `+read` | Read values from a spreadsheet |
| `+append` | Append a row to a spreadsheet |

### Resource: spreadsheets

```
gws sheets spreadsheets <method>
```

| Method | Purpose |
|--------|---------|
| `get` | Get spreadsheet metadata |
| `create` | Create a new spreadsheet |
| `batchUpdate` | Apply multiple updates (format, add sheets, etc.) |

### Sub-resource: spreadsheets.values

```
gws sheets spreadsheets values <method>
```

| Method | Purpose |
|--------|---------|
| `get` | Read values from a range |
| `update` | Write values to a range |
| `append` | Append values to a range |
| `clear` | Clear a range |
| `batchGet` | Read multiple ranges |
| `batchUpdate` | Write multiple ranges |
| `batchClear` | Clear multiple ranges |

### Sub-resource: spreadsheets.sheets

```
gws sheets spreadsheets sheets copyTo
```

### Common `+read` usage

```
gws sheets +read --spreadsheet '<id>' --range 'Sheet1!A1:Z100'
```

### Common `values.get` usage

```
gws sheets spreadsheets values get --params '{"spreadsheetId":"<id>","range":"<sheet>!<range>","valueRenderOption":"FORMATTED_VALUE"}'
```

---

## Docs

```
gws docs <command>
```

### Helpers

| Command | Purpose |
|---------|---------|
| `+write` | Append text to a document |

### Resource: documents

```
gws docs documents <method>
```

| Method | Purpose |
|--------|---------|
| `get` | Get document content and metadata |
| `create` | Create a new document |
| `batchUpdate` | Modify document content and formatting |

### Common `get` usage

```
gws docs documents get --params '{"documentId":"<id>"}'
```

### Common `+write` usage

```
gws docs +write --document '<id>' --text 'Content to append at the end'
```

### Batch update for complex edits

Use `--json` to send batch update requests:

```
gws docs documents batchUpdate --params '{"documentId":"<id>"}' --json '{"requests":[...]}'
```

---

## Slides

```
gws slides <command>
```

### Resource: presentations

```
gws slides presentations <method>
```

| Method | Purpose |
|--------|---------|
| `get` | Get presentation metadata and content |
| `create` | Create a new presentation |
| `batchUpdate` | Modify slides (add/delete slides, add shapes, text, etc.) |

### Sub-resource: presentations.pages

```
gws slides presentations pages get --params '{"presentationId":"<id>","pageObjectId":"<pageId>"}'
```

### Common `get` usage

```
gws slides presentations get --params '{"presentationId":"<id>"}'
```

### Common `create` usage

```
gws slides presentations create --json '{"title":"Presentation Title"}'
```

---

## Meet

```
gws meet <command>
```

### Resources

| Resource | Common Methods | Purpose |
|----------|---------------|---------|
| `conferenceRecords` | list, get | View past meeting records |
| `spaces` | get, create, update, patch, endActiveConference | Manage meeting spaces |

### Sub-resources

```
gws meet conferenceRecords participants list
gws meet conferenceRecords participants recordings list
gws meet conferenceRecords participants transcripts list
gws meet conferenceRecords recordings get
gws meet conferenceRecords transcripts get
```

### Common usage

```
# List conference records
gws meet conferenceRecords list --format table

# Get a specific conference
gws meet conferenceRecords get --params '{"name":"conferenceRecords/<id>"}'

# List participants of a conference
gws meet conferenceRecords participants list --params '{"parent":"conferenceRecords/<id>"}'
```
