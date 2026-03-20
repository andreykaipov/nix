---
name: slack
description: Use when searching or interacting with Slack messages, channels, or users.
---

# Slack

## Search

- `from:me` goes in `search_query`, NOT in `filter_users_from`
- `filter_users_from` expects a username like `@john` or user ID, not `from:me`
- Date filters use `YYYY-MM-DD` format, not natural language like "this week"
- Use `filter_in_channel` with `#channel-name` or channel ID

## Limitations

- `users_search` and `conversations_unreads` are not available (browser token)
- Never bulk query the Slack API (e.g. listing all users or all channels) — this will flag and revoke the user token. Paginating is fine but be mindful of volume and add sleeps between requests.
