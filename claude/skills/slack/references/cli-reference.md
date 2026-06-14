# Slack CLI Reference

Full command reference for `slack api` — direct access to the Slack Web API.

## CLI Syntax

```bash
slack api <method> [key=value ...] [flags]
```

### Body formats

| Format | Syntax | When |
|---|---|---|
| Form-encoded | `key1=val1 key2=val2` | Multiple key=value pairs (default) |
| JSON | `'{"key":"val"}'` or `--json` | Single JSON argument |
| No body | (no args) | GET-style methods like `auth.test` |

### Global flags

| Flag | Purpose |
|---|---|
| `--token <value>` | Override token (use `$SLACK_USER_TOKEN` for user token) |
| `--json` | Send body as JSON (Bearer token in header) |
| `--data <string>` | Raw form-encoded body string |
| `--no-auth` | Skip authentication entirely |

## Token selection

Commands use the first available token:
1. `--token` flag
2. `--app` flag (installed app's bot token)
3. `SLACK_BOT_TOKEN` env var
4. `SLACK_USER_TOKEN` env var

When both env vars are set, `SLACK_BOT_TOKEN` wins. Use `--token` to force user token.

## Messaging

### Send message

```bash
slack api chat.postMessage channel=<id> text='message'
slack api chat.postMessage channel=D0842GLSVUP text='hello' --token $SLACK_USER_TOKEN
```

Optional: `thread_ts` (reply in thread), `blocks` (Block Kit JSON), `mrkdwn=true`.

### Schedule message

```bash
slack api chat.scheduleMessage channel=<id> text='msg' post_at=<unix_timestamp>
```

### Update/delete message

```bash
slack api chat.update channel=<id> ts=<ts> text='updated'
slack api chat.delete channel=<id> ts=<ts>
```

## Reading messages

### Channel history

```bash
slack api conversations.history channel=<id> limit=50
```

Parameters: `limit` (max 999), `cursor` (pagination), `oldest`/`latest` (Unix timestamps), `inclusive=true`.

### Thread replies

```bash
slack api conversations.replies channel=<id> ts=<parent_ts> limit=50
```

### Pagination

All list/history methods return `response_metadata.next_cursor` when more results exist:

```bash
# First page
slack api conversations.history channel=C11JX3S6N limit=100

# Next page
slack api conversations.history channel=C11JX3S6N limit=100 cursor=<next_cursor_value>
```

## Channels & conversations

### List public channels

```bash
slack api conversations.list types=public_channel exclude_archived=true limit=100
```

Channel types for `types`: `public_channel`, `private_channel`, `mpim`, `im`.

### List your channels

```bash
slack api users.conversations limit=50 --token $SLACK_USER_TOKEN
```

Returns channels the authenticated user is actually a member of. Bot token returns empty.

### Get channel info

```bash
slack api conversations.info channel=<id>
```

### Open DM

```bash
slack api conversations.open users=U084E7FN7E1 --token $SLACK_USER_TOKEN
```

Returns `channel.id` — use this for `chat.postMessage` and `conversations.history`. Calling `conversations.open` for an already-open DM returns `no_op: true` with the existing channel ID.

### Create conversation (when scopes allow)

```bash
slack api conversations.create name=my-channel is_private=false
slack api conversations.create name=my-group is_private=true
slack api conversations.invite channel=<id> users=U084E7FN7E1,U0B8L0TAEUQ
```

Requires `channels:write` (public) or `groups:write` (private) — not in current scopes.

## Users

### List all users

```bash
slack api users.list limit=200
```

### Get user info

```bash
slack api users.info user=U084E7FN7E1
```

### Look up by email

```bash
slack api users.lookupByEmail email=user@example.com
```

Requires `users:read.email` scope — not in current scopes.

## Files

### List files

```bash
slack api files.list count=20 --token $SLACK_USER_TOKEN
```

### Get file info

```bash
slack api files.info file=<file_id>
```

### Get file download URL

The `files.info` response includes `url_private` — use with an auth header:

```bash
curl -H "Authorization: Bearer $SLACK_USER_TOKEN" <url_private> -o file.png
```

## Search (requires MCP — not available via CLI)

All `search.*` methods are blocked on current scopes:
- Bot token: `not_allowed_token_type` (Slack blocks all search on bot tokens)
- User token: `missing_scope` (no `search:read.*` scopes approved)

Use MCP `slack_search_public` or `slack_search_public_and_private` instead.

## Reactions

```bash
slack api reactions.add channel=<id> name=thumbsup timestamp=<ts>
```

Requires `reactions:write` scope — not in current scopes. MCP doesn't expose reactions.

## Troubleshooting

| Error | Cause | Fix |
|---|---|---|
| `not_authed` | No token available | Set `SLACK_BOT_TOKEN` or use `--token` |
| `channel_not_found` | Bot can't see that channel/DM | Use `--token $SLACK_USER_TOKEN` |
| `not_in_channel` | Bot not a member of channel | Use `--token $SLACK_USER_TOKEN` or invite bot |
| `missing_scope` | User token lacks scope | Use MCP as fallback |
| `not_allowed_token_type` | Bot tokens blocked from operation | Use `--token $SLACK_USER_TOKEN` or MCP |
| `method_deprecated` | API method retired | Check Slack changelog for replacement method |
| `invalid_limit` | `--limit` flag not valid | Use `limit=N` key=value syntax instead |
