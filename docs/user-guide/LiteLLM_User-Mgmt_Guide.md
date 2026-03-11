# LiteLLM Admin UI – User Creation & Team Assignment Guide

## Introduction

This guide explains how to create a new user in the LiteLLM Admin UI, assign them an appropriate role, and add them to a team. Virtual key creation is a separate task covered in the Virtual Keys guide — no key is created as part of this process.

> **Note:** This guide covers the **open-source (non-enterprise)** version of LiteLLM. Only a `proxy_admin` can create users and manage team membership.

---

## 1. Before You Begin

Make sure the following are in place before creating a new user:

- You are logged in as a `proxy_admin`.
- The team you want to assign the user to **already exists**. If it does not, create it first — refer to the Team Management guide.
- You have the new user's **email address** to hand.

---

## 2. Understanding User Roles

When creating a user you must assign them a role. This determines what they can see and do in the Admin UI.

| Role | Can log in | View own keys & spend | Create / delete own keys | View all keys & spend | Add new users |
|---|---|---|---|---|---|
| `proxy_admin` | ✅ | ✅ | ✅ | ✅ | ✅ |
| `proxy_admin_viewer` | ✅ | ✅ | ❌ | ✅ | ❌ |
| `internal_user` | ✅ | ✅ | ✅ | ❌ | ❌ |
| `internal_user_viewer` | ✅ | ✅ | ❌ | ❌ | ❌ |

For most developers and end users, **`internal_user`** is the appropriate role. Use `internal_user_viewer` for stakeholders or auditors who only need visibility of their own usage without the ability to generate keys.

---

## 3. Creating a New User

1. Log in to the Admin UI at `http://<your-proxy-host>:<port>/ui`.
2. In the left-hand navigation, click **Internal Users**.
3. Click **+ New User**.
4. Fill in the user details:

| Field | Description |
|---|---|
| **Email** | The user's email address. This is used as their login identity and for the invitation link |
| **Role** | Select the appropriate role (see section 2 above). For most users, choose `internal_user` |
| **Max Budget ($)** | Optional. A personal spending limit that applies to keys the user creates outside of any team (i.e. under the "Default Team"). Leave blank for no personal budget limit |
| **Budget Duration** | How often the personal budget resets (e.g. `30d`). Only relevant if a Max Budget is set |
| **Metadata** | Optional JSON tags for internal tracking (e.g. `{"department": "engineering"}`) |

5. Click **Create User**.

> ⚠️ **Do not create a virtual key at this stage.** The user creation form may offer the option to generate a key — skip this step. Key creation should be carried out as a separate task once the user has been set up and assigned to a team.

6. After the user is created, you will be shown an **invitation link**. Copy this link — you will need it in step 5.

---

## 4. Assigning the User to a Team

Once the user has been created, add them to the relevant team:

1. In the left-hand navigation, click **Teams**.
2. Find the team you want to add the user to and click on it.
3. Navigate to the **Members** tab.
4. Click **Add Member**.
5. Search for the user by their email address or user ID.
6. Set their **team role**:

| Team Role | What they can do within this team | Availability |
|---|---|---|
| `user` | View their own keys within the team; create team keys if team permissions allow | Open-source ✅ |
| `admin` | Full team management: add/remove members, manage keys, set team permissions | **Enterprise only** ✨ |

7. Click **Add** to confirm membership.

The user will now appear in the team's member list and their usage will be tracked against the team's budget when they create keys under this team.

---

## 5. Sharing the Invitation Link

The invitation link generated in step 3 is how the user activates their account and sets a password for the first time.

- The link is in the format: `http://<your-proxy-host>:<port>/ui/onboarding?id=<invitation-id>`
- **The link is valid for 7 days.** If it expires before the user logs in, you will need to generate a new one (see section 7).
- Send the link to the user directly (e.g. by email or message).

When the user opens the link, they will be taken through a short onboarding flow where they set their password and are then logged in to the UI.

> **Note:** SSO login (Google, Okta, Microsoft Entra ID) is available but requires additional configuration by your administrator. In the open-source version, SSO is free for up to 5 users. For username/password login, the invitation link is the standard onboarding method.

---

## 6. Verifying the User Setup

After the user has been created and added to a team, verify everything looks correct before sending the invitation:

1. Go to **Internal Users** and find the new user. Confirm their role is set correctly.
2. Go to **Teams**, open the relevant team, and check the **Members** tab to confirm the user appears there with the correct team role.
3. Confirm the user has **no virtual keys** assigned yet — key creation is a separate step.

---

## 7. Regenerating an Invitation Link

If the invitation link expires before the user activates their account, you can generate a new one:

1. Go to **Internal Users** and find the user.
2. Click on their record to open it.
3. Look for the option to **Resend Invitation** or **Generate Invitation Link**.
4. Copy the new link and share it with the user.

---

## 8. Editing a User

To change a user's role or personal budget after they have been created:

1. Go to **Internal Users** and find the user.
2. Click the **Edit** icon next to their record.
3. Update the relevant fields (role, budget, metadata).
4. Click **Save**.

> **Note:** Changing a user's role takes effect immediately on their next login or page refresh.

---

## 9. Removing a User from a Team

To remove a user from a team without deleting their account:

1. Go to **Teams** and open the relevant team.
2. Navigate to the **Members** tab.
3. Find the user and click the **Remove** icon next to their name.
4. Confirm the removal.

The user's account remains active and they can still log in, but they will no longer be associated with that team and cannot create keys under it.

---

## 10. Deleting a User

To permanently remove a user from the system:

1. Go to **Internal Users** and find the user.
2. Click the **Delete** icon next to their record.
3. Confirm the deletion.

> ⚠️ Deleting a user will also delete any **personal keys** (user-only keys) belonging to them. **Team service account keys** (keys with only a `team_id`) are not affected. Review the user's keys before deleting to avoid disrupting any active integrations.

---

## 11. Frequently Asked Questions

**Q: The user says they never received the invitation link.**  
A: The Admin UI does not send emails automatically in the open-source version — the invitation link must be shared manually by the administrator. Check you have shared the correct link with the user. If the link has expired (after 7 days), generate a new one following the steps in section 7.

**Q: The user logged in but cannot see the team they were added to.**  
A: Ask the user to log out and log back in. Team membership changes may not reflect until the session is refreshed.

**Q: Can I add a user to a team at the same time as creating them?**  
A: Not directly in a single step via the UI. Create the user first, then add them to the team via the Teams section as described in section 4.

**Q: Can a user be in more than one team?**  
A: Yes. Repeat the steps in section 4 for each additional team you want to add the user to.

**Q: What role should I give most users?**  
A: `internal_user` is the right choice for developers and anyone who will need to create and manage their own virtual keys. Use `internal_user_viewer` for read-only access (e.g. managers reviewing spend).

---

## 12. Next Steps

Once the user has been created and assigned to a team, the next task is to create a virtual key for them. Refer to the **Virtual Keys guide** for step-by-step instructions on creating a key and attaching it to the user's team.

---

## 13. Getting Help

If you need a user created, role changes, or team membership updates, contact your LiteLLM administrator. Only users with the `proxy_admin` role can perform these actions.
