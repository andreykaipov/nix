---
name: newday
description: Morning catchup workflow. Use when the user says "new day", "good morning", or "standup update". Gathers Slack unreads, GitHub issues/PRs, and drafts a standup into a prioritized summary.
---

# New Day Catchup

**Before starting, load the `slack` skill** (`/skill:slack` or read its SKILL.md) for Slack API safety rules and message drafting guidelines.

Run all of the following steps in parallel where possible, then present a single organized summary.

## 0. Discover context

**Try to infer everything automatically. Only ask the user as a last resort if inference fails.**

Run these in parallel to bootstrap context:
- **GitHub username**: `gh api user --jq '.login'`
- **Slack identity**: `conversations_search_messages` with `search_query: "from:me"` and `filter_date_after` set to 7 days ago in `YYYY-MM-DD` format — the results will contain the authenticated user's ID and display name
- **Standup channel**: `conversations_search_messages` with `search_query: "from:me standup"` and `filter_date_after` set to 30 days ago in `YYYY-MM-DD` format — look for channels where the user has posted in standup threads
- **Key channels**: infer from the `from:me` search results — whichever channels the user is most active in recently

Store `USER_ID`, `GH_USER`, `GH_ORGS`, standup channel, and key channels for the steps below. Only ask the user if an inference completely fails.

## 1. Slack unreads & mentions

- Run these in parallel:
  - `conversations_search_messages` with `filter_users_with` set to `USER_ID` and `filter_date_after` set to yesterday's date — catches threads involving the user
  - `conversations_search_messages` with `search_query` set to the user's `@handle` and `filter_date_after` set to yesterday — catches direct mentions
  - If key channels were provided, `conversations_history` on each with `limit: "1d"` — catches messages the user may not be tagged in
- For interesting threads, use `conversations_replies` with the `thread_ts` to get full context
- **DM channels**: `@username` format may not resolve — if it fails, skip and note it
- Flag anything urgent (incidents, deploy failures, direct asks)

## 2. GitHub — assigned issues

- Use `gh search issues --assignee GH_USER --state open --type issue` (add `--owner GH_ORG` if known)
- Highlight any with recent comments or activity

## 3. GitHub — open PRs

- Use `gh search prs --author GH_USER --state open` (add `--owner GH_ORG` if known) for authored PRs
- Use `gh search prs --review-requested GH_USER --state open` (add `--owner GH_ORG` if known) for review requests
- For key PRs (non-bot), check for recent feedback with `gh pr view --comments`

## 4. Standup draft (if inferred)

Inferred from the found messages:
- Search for today's standup thread using `conversations_search_messages`
- If the user has a [standup style guide](standup-style.md), read it and follow it exactly
- Otherwise, draft a concise standup based on the gathered context
- **Always show the draft for review before posting** — never auto-post
- Once approved, use `conversations_add_message` with the channel ID and `thread_ts` to post

## 5. Present & act

- Summarize everything in a prioritized list: **urgent → needs response → FYI**
- For items needing a response, offer to draft replies
- **Don't send anything without explicit approval**
