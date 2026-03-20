---
name: catchup
description: Quick Slack catchup for anytime use. Use when the user says "catch up", "catchup", "what's new on slack", "check slack", or "anything new". Pulls recent Slack activity and offers to draft replies.
---

# Slack Catchup

Quick scan of recent Slack activity and batch-draft replies.

**Before starting, load the `slack` skill** (`/skill:slack` or read its SKILL.md) for Slack API safety rules and message drafting guidelines.

## 0. Discover the user's identity

**Try to infer automatically. Only ask the user as a last resort if inference fails.**

- Get the GitHub username via `gh api user --jq '.login'`
- Use `conversations_search_messages` with `search_query: "from:me"` and `filter_date_after` set to 7 days ago in `YYYY-MM-DD` format — the results will contain the authenticated user's Slack ID and display name
- Store the user ID for the steps below (referred to as `USER_ID`)

## 1. Pull recent Slack activity

Run these in parallel:

- `conversations_search_messages` with `filter_users_with` set to `USER_ID` and `filter_date_during: "Today"` — threads involving the user
- `conversations_search_messages` with `search_query` set to the user's `@handle` and `filter_date_during: "Today"` — direct mentions

If the user mentions specific channels to watch, also run:
- `conversations_history` on those channels with `limit: "3h"` — recent channel activity

For interesting threads, use `conversations_replies` with the `thread_ts` to get full context.

## 2. Filter out noise

- Skip messages the user already replied to (check thread replies for `USER_ID`)
- Skip bot messages and automated notifications unless they look actionable
- Focus on: direct questions, requests, threads where the user's input is expected

## 3. Draft replies

- For each message needing a response, draft a reply matching the user's tone
- Group by channel so the user can review them together
- Present as a numbered list: show the original message snippet, then the drafted reply
- **Always get approval before sending** — the user can approve, edit, or skip each one

## 4. Send approved replies

- Use `conversations_add_message` with the appropriate channel ID and `thread_ts` for each approved reply
- Confirm what was sent
