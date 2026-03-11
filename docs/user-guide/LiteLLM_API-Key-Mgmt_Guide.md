# LiteLLM Admin UI – API Key Management Guide

## Introduction

This guide explains how to access the LiteLLM Admin UI, manage your user account, and create and manage virtual keys. Virtual keys are how you authenticate to the LiteLLM proxy to make LLM API calls. They can be scoped to specific models, teams, budgets, and rate limits.

> **Note:** This guide covers the **open-source (non-enterprise)** version of LiteLLM. Some features — such as automatic key rotation, organisation/team-scoped admin roles, and vector store access — are only available on the Enterprise tier.

---

## 1. Accessing the Admin UI

The Admin UI is available at:

```
https://licenseportal.aiengineeringlab.co.uk/ui
```

You will be prompted to enter your username and password. These are provided by your LiteLLM administrator. Once logged in, you will land on the main dashboard.

---

## 2. Understanding Your Role

Your experience in the UI depends on the role your administrator has assigned to you. The roles available in the open-source version are:

| Role | What you can do |
|---|---|
| `proxy_admin` | Full access: manage all keys, users, models, teams, and spend |
| `proxy_admin_viewer` | View all keys and spend. Cannot create, edit, or delete keys |
| `internal_user` | Create, view, and delete **your own** keys. View your own spend |
| `internal_user_viewer` | View your own keys and spend only. Cannot create or delete keys |

If you are unsure of your role, contact your administrator.

---

## 3. Managing Your Account

### Viewing Your Profile

After logging in, your user profile information is accessible via the UI. This shows:

- Your **User ID** and email
- Your assigned **role**
- Any **teams** you are a member of
- Your **spend** and remaining **budget** (if configured)

### Spend & Budget Tracking

The UI includes a **Usage / Spend** section where you can monitor:

- Total spend to date
- Spend broken down by model or key
- Whether you are approaching a budget limit

If you reach your budget limit, your keys will stop working until the budget resets or is increased by an administrator. Contact your administrator if you need a budget increase.

---

## 4. Virtual Keys

A **virtual key** is an API key (in the format `sk-...`) that you use in place of the underlying model provider's API key when making requests through the LiteLLM proxy. The proxy handles routing your request to the correct model.

### 4.1 Key Types

| Key Type | Has `user_id` | Has `team_id` | Best used for |
|---|---|---|---|
| **Personal key** | ✅ | ❌ | Individual developer use and experimentation |
| **Team key (Service Account)** | ❌ | ✅ | Shared production applications — not tied to a specific person |
| **User + Team key** | ✅ | ✅ | Individual accountability within a team budget |

> **Tip:** For production applications, prefer a team (service account) key so the application does not break if a team member leaves.

---

### 4.2 Creating a New Virtual Key

> **Prerequisite:** You must have the `internal_user` or `proxy_admin` role to create keys.

1. In the left-hand navigation, click **Virtual Keys**.
2. Click the **+ Create New Key** button.
3. Fill in the key details (see the table below).
4. Click **Create Key**.
5. **Copy the key immediately** — it will not be shown again after you leave the page.

#### Key Configuration Options

| Field | Description |
|---|---|
| **Key Name / Alias** | A human-readable label to help you identify the key (e.g. `demail`, `name`) |
| **Models** | The list of models this key is allowed to call. If left empty, the key may have access to all models available to your team. Only models configured by your administrator will appear in the list |
| **Team** | Attach the key to a team. The key will then count against the team's budget and will be governed by the team's model access permissions |
| **Rate Limits** | Optionally set a maximum number of **requests per minute (RPM)** or **tokens per minute (TPM)** for this key |
| **Key Expiry** | An optional expiry date/duration after which the key will automatically stop working (e.g. `30d`) |


#### How Models Are Attached to a Key

When you select models during key creation, you are telling the proxy which models **this key is authorised to use**. If you make a request to a model not on the key's allowed list, the request will be rejected with an authorisation error.

- If your key is attached to a **team**, the available models are further limited to those the team has access to — you cannot grant a key access to a model the team cannot use.
- If **no models are specified**, the key inherits the access of its team (or all available models if no team is set), subject to administrator configuration.

#### How Teams Are Attached to a Key

Attaching a key to a team means:

- The key's usage counts against the **team's budget**, in addition to any per-key budget you set.
- The key is visible to **team admins** within that team.
- The key will be governed by any **team-level model restrictions** your administrator has set.

You can only attach a key to a team you are a **member** of.

---

### 4.3 Viewing Your Keys

In the **Virtual Keys** section you can see all keys belonging to your account. For each key you can see:

- The key alias/name
- Which models it has access to
- The team it belongs to (if any)
- Spend so far and remaining budget
- Expiry date (if set)
- Rate limits (if set)

---

### 4.4 Editing a Key

1. In the **Virtual Keys** list, find the key you want to modify.
2. Click the **Edit / Settings** icon next to the key.
3. You can update the key's alias, budget, rate limits, expiry, and metadata.
4. Click **Save** to apply changes.

> **Note:** You cannot change which models a key has access to beyond what your team or role permits.

---

### 4.5 Deleting a Key

1. In the **Virtual Keys** list, find the key you want to remove.
2. Click the **Delete** icon next to the key.
3. Confirm the deletion when prompted.

> ⚠️ Deletion is permanent. Any application or integration using that key will immediately stop working.

---

### 4.6 Key Regeneration (Enterprise Only)

Automatic key rotation/regeneration is an **Enterprise-only feature** and is not available in the open-source version of LiteLLM.

If you need to replace a compromised or expired key, the recommended approach is to:

1. **Create a new key** (following the steps in section 4.2).
2. Update your application or integration to use the new key.
3. **Delete the old key** once you have confirmed the new key is working.

---

## 5. Using Your Virtual Key

Once you have a virtual key, use it in place of any OpenAI API key when pointing your application at the LiteLLM proxy:

```python
import openai

client = openai.OpenAI(
    api_key="sk-your-litellm-virtual-key",
    base_url="https://licenseportal.aiengineeringlab.co.uk"
)

response = client.chat.completions.create(
    model="gpt-4",   # use the model name as configured in LiteLLM
    messages=[{"role": "user", "content": "Hello!"}]
)
```

The `model` value should match one of the model names your key has been granted access to.

---

## 6. Frequently Asked Questions

**Q: I can see keys in the UI but cannot create new ones.**  
A: Your role is likely `internal_user_viewer` or `proxy_admin_viewer`. Ask your administrator to upgrade your role to `internal_user` if you need to create keys.

**Q: My key stopped working suddenly.**  
A: This is usually caused by one of the following: the key has expired, a budget limit has been reached, or the key was deleted. Check the key's details in the UI or contact your administrator.

**Q: Can I share my virtual key with a colleague?**  
A: Technically possible, but not recommended. Sharing keys makes it impossible to attribute usage to a specific individual. Ask your administrator to create a separate key for your colleague, or use a team (service account) key for shared services.

**Q: I generated a key but forgot to copy it. Can I retrieve it?**  
A: No. For security reasons, the full key value is only shown once at creation. You will need to delete the old key and create a new one.

**Q: Can I have keys in multiple teams?**  
A: Yes. You can be a member of multiple teams and create keys attached to different teams.

---

## 7. Getting Help

If you encounter any issues or need changes to your account (role changes, budget increases, team membership), please contact your LiteLLM administrator.
