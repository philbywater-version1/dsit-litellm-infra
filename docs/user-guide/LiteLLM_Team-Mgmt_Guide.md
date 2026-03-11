# LiteLLM Admin UI – Team Management User Guide

## Introduction

This guide explains how to create and manage **Teams** in the LiteLLM Admin UI. Teams are a way to group users together and apply shared budgets, rate limits, and model access. Virtual keys can be attached to a team so that usage is tracked and controlled at the team level.

> **Note:** This guide covers the **open-source (non-enterprise)** version of LiteLLM. Some features — such as organisation-level management, team admin roles, and team-scoped RBAC — are only available on the Enterprise tier.

---

## 1. Understanding the Hierarchy

Before creating a team, it helps to understand how LiteLLM structures its resources:

```
Organization  (Enterprise only)
    └── Team
          └── Users
                └── Virtual Keys
```

In the open-source version:

- **Teams** are the top-level grouping available to you.
- A **user** can be a member of multiple teams.
- **Virtual keys** can be attached to a team, meaning usage is tracked against the team's budget.
- Only a **proxy admin** can create teams and manage team membership via the UI.

---

## 2. Who Can Create and Manage Teams?

| Action | proxy_admin | internal_user | internal_user_viewer |
|---|---|---|---|
| Create a team | ✅ | ❌ | ❌ |
| Add/remove team members | ✅ | ❌ | ❌ |
| Edit team settings (budget, models, limits) | ✅ | ❌ | ❌ |
| View teams they belong to | ✅ | ✅ | ✅ |
| Create keys under a team | ✅ | ✅ (if member) | ❌ |

> **Team Admin role** (ability for a non-admin user to manage a specific team) is an **Enterprise-only** feature. In the open-source version, only a `proxy_admin` can manage teams.

---

## 3. Creating a New Team

1. Log in to the Admin UI at `http://<your-proxy-host>:<port>/ui`.
2. In the left-hand navigation, click **Teams**.
3. Click the **+ Create New Team** button.
4. Fill in the team details (see the table below).
5. Click **Create Team**.

#### Team Configuration Options

| Field | Description |
|---|---|
| **Team Name / Alias** | A human-readable name for the team (e.g. `data-science`, `platform-eng`, `product-chatbot`) |
| **Models** | The list of models this team's members and keys are permitted to use. Only models configured by the administrator will appear. If left empty, access defaults to all available models |
| **Max Budget ($)** | An optional total spending limit for the entire team. Once reached, all keys under the team will be rejected until the budget resets or is increased |
| **Budget Duration** | How often the team budget resets (e.g. `30d` for monthly, `7d` for weekly). Leave blank for a lifetime budget |
| **Rate Limits (TPM / RPM)** | Optionally cap the team's total **tokens per minute (TPM)** or **requests per minute (RPM)** across all keys belonging to the team |
| **Metadata** | Optional JSON tags for tracking and filtering (e.g. `{"department": "engineering", "cost-centre": "CC-1042"}`) |

---

## 4. How Models Are Attached to a Team

When you select models during team creation, you are defining which models **any key belonging to this team** is allowed to call. This creates a boundary that applies to all members:

- A user who is a member of the team **cannot create a key** that accesses models outside the team's allowed list.
- If a key has its own model list, it must be a **subset** of the team's model list — you cannot grant a key broader access than the team has.
- If **no models are specified** at the team level, the team inherits access to all models available on the proxy (subject to global administrator settings).

> **Example:** If your team is configured with access to `gpt-4` and `gpt-3.5-turbo`, a member of that team can only create keys scoped to those models (or a subset of them). They cannot create a key for `claude-3-opus` even if it exists on the proxy.

---

## 5. Adding Members to a Team

After creating a team, you can add users to it:

1. In the **Teams** section, find your team and click on it (or click the **Edit / Settings** icon).
2. Navigate to the **Members** tab.
3. Click **Add Member**.
4. Search for the user by their email or user ID.
5. Select the appropriate **role** for this member:

| Team Role | What they can do | Availability |
|---|---|---|
| `user` | View their own keys within the team, create team keys (if permitted by admin) | Open-source ✅ |
| `admin` | Full team management: add members, manage keys, set permissions | **Enterprise only** ✨ |

6. Click **Add** to confirm.

> **Note:** The user must already exist in the LiteLLM system (i.e. they must have logged in or been invited previously) before you can add them to a team.

---

## 6. Viewing and Editing a Team

1. In the **Teams** section, click on the team name.
2. From here you can:
   - View all **members** and their roles
   - View all **keys** associated with the team
   - Review **spend** broken down by key or user
   - Edit **budget**, **rate limits**, and **model access**
3. Click **Save** after making any changes.

---

## 7. Team Budgets and How They Work

Team budgets operate alongside per-key budgets. Both can be set independently:

- **Team budget**: A shared pool for all usage by all keys belonging to the team. When the team budget is exhausted, all team keys stop working regardless of their individual budgets.
- **Key budget**: A limit applied to a single key. A key stops working when either its own budget *or* its team's budget is exhausted — whichever is reached first.

**Example:**

| | Budget | Spend so far | Status |
|---|---|---|---|
| Team budget | $100 | $95 | ⚠️ Nearly exhausted |
| Key A budget | $50 | $10 | ✅ Within limit |
| Key B budget | $50 | $30 | ✅ Within limit |

In this scenario, even though both individual keys are within their own limits, all team keys will stop working once the team's $100 is reached.

---

## 8. Deleting a Team

1. In the **Teams** section, find the team you want to remove.
2. Click the **Delete** icon next to the team.
3. Confirm the deletion when prompted.

> ⚠️ Deleting a team does **not** automatically delete team members (users) or service account keys. However, any keys attached to that team will lose their team association. Review and clean up orphaned keys after deleting a team.

---

## 9. Enterprise-Only Features (Not Available in Open-Source)

The following team-related features require a LiteLLM Enterprise licence:

| Feature | Description |
|---|---|
| **Team Admin role** | Allows a non-admin user to manage their specific team without being a proxy admin |
| **Organisation-level grouping** | Group multiple teams under an organisation (e.g. `US Engineering` with teams `Frontend`, `Backend`) |
| **Org Admin role** | An admin scoped to a specific organisation, able to create and manage teams within it |
| **Team member permissions** | Fine-grained control over what team members (role=`user`) can do with keys (e.g. create, update, delete) |

---

## 10. Frequently Asked Questions

**Q: I can't see the Teams section in the UI.**  
A: Team management is only available to `proxy_admin` users. If you cannot see the Teams section, your role does not have the required access. Contact your administrator.

**Q: Can a user be in more than one team?**  
A: Yes. Users can be members of multiple teams and can create keys under any team they belong to.

**Q: What happens to keys when a team member leaves?**  
A: Personal user keys (user-only keys) are deleted when a user is removed. However, **team service account keys** (keys with a `team_id` but no `user_id`) persist when team members are removed. This is why service account keys are recommended for production applications.

**Q: Can I set different model access for different members within a team?**  
A: Not in the open-source version. Model access is set at the team level and applies to all members. Per-user model restrictions within a team are an Enterprise feature.

**Q: The team budget has been exhausted. How do I reset it?**  
A: If a budget duration was set (e.g. monthly), it will reset automatically. Otherwise, a `proxy_admin` can manually increase the budget by editing the team settings.

---

## 11. Getting Help

If you need a team created, membership changes, or budget adjustments, contact your LiteLLM administrator. Users with the `internal_user` role cannot create or manage teams directly in the open-source version.
