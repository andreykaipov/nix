---
name: slack
description: Use when searching or interacting with Slack messages, channels, or users. Also covers drafting messages in Andrey's voice.
---

# Slack

## Safety Rules

When using the Slack MCP server, follow these rules to avoid triggering Slack's anti-scraping detection (which revokes tokens and force-signs out):

- **NEVER** call `channels_list` or any bulk channel/user enumeration tool.
- Use `#channel-name` to reference channels — the server resolves them lazily via single API calls.
- Explore and cross-reference Slack data freely, but do it through targeted queries (search, history, replies), not bulk listings.
- Space out Slack API calls when making several in a row.

## Search

- `from:me` goes in `search_query`, NOT in `filter_users_from`
- `filter_users_from` expects a username like `@john` or user ID, not `from:me`
- Date filters use `YYYY-MM-DD` format, not natural language like "this week"
- Use `filter_in_channel` with `#channel-name` or channel ID

## Limitations

- `users_search` and `conversations_unreads` are not available (browser token)
- Never bulk query the Slack API (e.g. listing all users or all channels) — this will flag and revoke the user token. Paginating is fine but be mindful of volume and add sleeps between requests.
- The channel parameter in all Slack tools is called `channel_id`, not `channel`. Using `channel` will error.

## Andrey's Slack Voice

When drafting Slack messages on Andrey's behalf, match this voice. GitHub issue comments stay detailed/formal — these notes only apply to Slack.

### General style
- Casual and conversational, like texting a coworker
- Normal apostrophes in contractions: don't, can't, I'm, I'll, it's, haven't, doesn't, won't, didn't
- Usually capitalizes "I" but not always
- No markdown formatting (no backticks, bold, headers)
- Uses "y'all", "gonna", "lemme know", "atm"

### Tone by context
- **DMs/team chat**: Very casual, stream-of-consciousness, sometimes witty/self-deprecating humor
- **Cross-team requests**: Friendly, provides context/links first, then the ask. Not overly formal but polite.
- **Quick replies**: "Thanks", "Thank you", "Sure thanks for the heads up", "interesting"
- **Updates/standups**: Doesn't use emoji bullet points, typically brief

### Humor & personality
- Self-deprecating, witty asides
- Uses "haha", "hahaha" (not "lol")
- Emojis: :sweat_smile:, :grimacing:, :shrug:, :thinking_face:, :grin:, :hugs:

### Technical messages
- Leads with context/investigation before the ask
- "I think maybe what happened was..."
- "seems like", "looks like", "I'm honestly not too sure why"
- Inline links, not formatted lists
- Provides evidence (curl output, jq commands, etc.)

### When asking for help from other teams
- Explains the situation naturally, not bullet-pointed
- References PRs/issues inline
- Friendly but direct, doesn't over-apologize
