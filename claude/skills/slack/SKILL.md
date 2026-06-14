---
name: slack
description: Use when the user asks to send Slack messages, read channel or DM history, list channels or users, read threads, search Slack messages or channels, view user profiles, manage canvases, or schedule messages. Also use when the user mentions interacting with Slack, querying Slack data, or needs to communicate via Slack. Covers both slack CLI (preferred) and Slack MCP tools (fallback for operations blocked by limited CLI scopes).
---

# Slack

Interact with Slack via `slack api` (CLI) and Slack MCP tools.

## Preconditions

- `slack` CLI installed (`brew install slack`)
- Bot token: `SLACK_BOT_TOKEN` env var (Navi bot, `xoxb-...`)
- User token: `SLACK_USER_TOKEN` env var (acts as you, `xoxp-...`)

Verify setup:
```bash
slack version
slack api auth.test
slack api auth.test --token $SLACK_USER_TOKEN
```

## Token resolution

When both env vars are set, `SLACK_BOT_TOKEN` wins. Use `--token $SLACK_USER_TOKEN` explicitly for user-token operations:

```
1. --token flag
2. --app flag
3. SLACK_BOT_TOKEN env var
4. SLACK_USER_TOKEN env var
```

## Slack CLI (`slack api`)

Call any Slack Web API method directly. Parameters use `key=value` syntax:

```bash
slack api <method> key1=value1 key2=value2
```

For JSON bodies, use a single `{...}` argument or `--json`:

```bash
slack api chat.postMessage channel=C11JX3S6N text='hello'
slack api chat.postMessage --json '{"channel":"C11JX3S6N","text":"hello"}'
```

### Bot vs User token

| Operation | Bot token | User token |
|---|---|---|
| Send messages | Only channels/DMs Navi is in | Channels/DMs you can access |
| Read public channels | Only channels Navi is in | All public channels |
| Read private channels | Only channels Navi is in | Only channels you're a member of |
| Read DMs | Only Navi DM (D0B7KF37DS7) | Your DMs |
| List all public channels | Yes | Yes |
| List my channels | No (bot isn't a member) | Yes |
| List users | Yes | Yes |
| Search | Blocked (`not_allowed_token_type`) | Blocked (missing `search:read.*`) |

Use bot token by default (no `--token` flag). Use user token (`--token $SLACK_USER_TOKEN`) when:
- Reading your own DMs (self-DM: D0842GLSVUP)
- Reading channels you're a member of that Navi isn't in
- Sending messages from your identity
- Listing your channel memberships

## Core Workflows

### A. Send a message

```bash
# Bot token: only channels/DMs Navi is in
slack api chat.postMessage channel=C11JX3S6N text='message'

# User token: any channel you can access
slack api chat.postMessage channel=D0842GLSVUP text='self-dm message' --token $SLACK_USER_TOKEN
```

**AI disclaimer (REQUIRED when using user token):** When sending messages with `--token $SLACK_USER_TOKEN`, ALWAYS use `--json` with Block Kit and append a context block as the last block to indicate the message was sent by an AI assistant. This makes it clear to recipients that the message was not typed manually.

```bash
slack api chat.postMessage --json '{
  "channel": "CHANNEL_ID",
  "text": "fallback plain text",
  "blocks": [
    {"type": "section", "text": {"type": "mrkdwn", "text": "your message here"}},
    {"type": "context", "elements": [{"type": "mrkdwn", "text": "Sent by a harness using Slack CLI"}]}
  ]
}' --token $SLACK_USER_TOKEN
```

The `text` field serves as fallback for notifications and accessibility. The context block is always the last block in the array, after all message content blocks.

### B. Read channel history

```bash
# Public channel (user token for channels Navi isn't in)
slack api conversations.history channel=C11JX3S6N limit=10 --token $SLACK_USER_TOKEN

# DM history
slack api conversations.history channel=D0842GLSVUP limit=10 --token $SLACK_USER_TOKEN
```

Paginate with `cursor` from `response_metadata.next_cursor`.

### C. Read thread replies

```bash
slack api conversations.replies channel=C11JX3S6N ts=1780695717.739429 --token $SLACK_USER_TOKEN
```

### D. List channels

```bash
# All public channels (bot token)
slack api conversations.list types=public_channel exclude_archived=true

# Channels you're actually in (user token)
slack api users.conversations limit=50 --token $SLACK_USER_TOKEN
```

### E. List users

```bash
slack api users.list
```

No `--token` needed — bot token works. Paginates with `cursor`.

### F. Open a DM

```bash
slack api conversations.open users=U084E7FN7E1 --token $SLACK_USER_TOKEN
```

Returns the channel ID to use for sending/reading messages.

### G. File operations

```bash
slack api files.list count=10 --token $SLACK_USER_TOKEN
slack api files.info file=F0B8ST9E22Y --token $SLACK_USER_TOKEN
```

### H. Any other API method

```bash
slack api <method> key=value
```

Full method list: https://docs.slack.dev/reference/methods

## CLI vs MCP

The MCP uses an agent gateway with a separate Slack app that has all scopes. It supplements the CLI — not replaces it.

**Always try CLI first.** Use MCP only when CLI scopes block the operation.

### When MCP is required

| Capability | Why CLI can't do it |
|---|---|
| Search messages/channels | `search:read.*` scopes blocked by security |
| Search users | `search:read.users` scope blocked |
| Read user profiles | `users:read.email` scope blocked |
| Create/read/update canvases | `canvases:read/write` scopes not approved |
| Draft messages | No CLI equivalent |
| Schedule messages | No CLI equivalent |

### MCP tools

| Tool | Purpose |
|---|---|
| `slack_send_message` | Send to any channel/DM |
| `slack_read_channel` | Read channel history (newest first) |
| `slack_read_thread` | Read thread replies |
| `slack_search_public` | Search public channels |
| `slack_search_public_and_private` | Search all channels + DMs |
| `slack_search_channels` | Find channels by name |
| `slack_search_users` | Find users by name/email |
| `slack_read_user_profile` | Get detailed user profile |
| `slack_create_canvas` | Create canvas document |
| `slack_read_canvas` | Read canvas content |
| `slack_update_canvas` | Edit canvas (append/prepend/replace) |
| `slack_send_message_draft` | Create draft message |
| `slack_schedule_message` | Schedule message for future delivery |

### What CLI does better

CLI gives you full control over pagination (`cursor`), raw API access (`slack api <any-method>`), and direct listing (`conversations.list`, `users.list`). MCP search returns at most 20 results per page with limited pagination support. Use CLI when you need to iterate through all channels, users, or messages with precise control.

## Reference

- **`references/cli-reference.md`** — Full slack api command reference with common methods, pagination patterns, and troubleshooting.
