# LiteLLM User Onboarding Guide

## Overview

This guide walks through the process of onboarding a new user to the LiteLLM AI Gateway and configuring their developer tools to use it.

---

## Contents

1. [Prerequisites](#prerequisites)
2. [Step 1: Create the User](#step-1-create-the-user)
3. [Step 2: Generate an Invitation Link](#step-2-generate-an-invitation-link)
4. [Step 3: Send the Onboarding Link](#step-3-send-the-onboarding-link-to-the-user)
5. [What the User Gets Access To](#what-the-user-gets-access-to)
6. [Automating User Onboarding with Python](#automating-user-onboarding-with-python)
7. [Configuring the Continue.dev VS Code Extension](#configuring-the-continuedev-vs-code-extension)
8. [Configuring GitHub Copilot in VS Code](#configuring-github-copilot-in-vs-code)
9. [Configuring Claude Code](#configuring-claude-code)
10. [Troubleshooting](#troubleshooting)

---

The onboarding process consists of three steps:

1. Create the user account via the API
2. Generate an invitation link via the API
3. Send the onboarding link to the user

---

## Prerequisites

Before you begin you will need:

- Your **LiteLLM Proxy URL**: `https://licenseportal.aiengineeringlab.co.uk`
- Your **Master API Key** (held by the Proxy Admin)
- The **Team ID** of the team you are adding the user to
- The **email address** of the user being onboarded

---

## Step 1: Create the User

Call the `/user/new` endpoint to create the user account and assign them to a team.

**Template:**
```bash
curl -X POST '<PROXY_URL>/user/new' \
  -H 'Authorization: Bearer <MASTER_KEY>' \
  -H 'Content-Type: application/json' \
  -d '{
    "user_email": "<USER_EMAIL>",
    "user_role": "internal_user",
    "teams": ["<TEAM_ID>"]
  }'
```

| Parameter | Description |
|---|---|
| `PROXY_URL` | Base URL of your LiteLLM proxy |
| `MASTER_KEY` | Your LiteLLM master API key |
| `USER_EMAIL` | The email address of the user being onboarded |
| `TEAM_ID` | The ID of the team to assign the user to (e.g. Dev-Test) |

> **Note:** The user will inherit all models, budget, and rate limits configured on the team. There is no need to specify these at the user level.

**Example:**
```bash
curl -X POST 'https://licenseportal.aiengineeringlab.co.uk/user/new' \
  -H 'Authorization: Bearer sk-xxxxxxxxxxxxxxxxxxxx' \
  -H 'Content-Type: application/json' \
  -d '{
    "user_email": "alice@company.com",
    "user_role": "internal_user",
    "teams": ["f6dbea80-21b4-4f7b-a669-3d6adcc6e8d1"]
  }'
```

**Response:** The API will return a JSON object. Make a note of the `user_id` value — you will need it in Step 2.

```json
{
  "user_id": "e050dc40-9f3c-4982-b736-a0d019fbd82f",
  "user_email": "alice@company.com",
  "user_role": "internal_user",
  ...
}
```

---

## Step 2: Generate an Invitation Link

Call the `/invitation/new` endpoint using the `user_id` returned in Step 1.

**Template:**
```bash
curl -X POST '<PROXY_URL>/invitation/new' \
  -H 'Authorization: Bearer <MASTER_KEY>' \
  -H 'Content-Type: application/json' \
  -d '{ "user_id": "<USER_ID>" }'
```

| Parameter | Description |
|---|---|
| `PROXY_URL` | Base URL of your LiteLLM proxy |
| `MASTER_KEY` | Your LiteLLM master API key |
| `USER_ID` | The `user_id` value from the Step 1 response |

**Example:**
```bash
curl -X POST 'https://licenseportal.aiengineeringlab.co.uk/invitation/new' \
  -H 'Authorization: Bearer sk-xxxxxxxxxxxxxxxxxxxx' \
  -H 'Content-Type: application/json' \
  -d '{ "user_id": "e050dc40-9f3c-4982-b736-a0d019fbd82f" }'
```

**Response:** The API will return a JSON object containing the invitation details. Make a note of the `id` and `expires_at` values.

```json
{
  "id": "60b2afd6-4511-408e-a854-d5f9c136682a",
  "user_id": "e050dc40-9f3c-4982-b736-a0d019fbd82f",
  "is_accepted": false,
  "accepted_at": null,
  "expires_at": "2026-03-06T08:40:15.539000Z",
  "created_at": "2026-02-27T08:40:15.539000Z"
}
```

> **Important:** The invitation link is valid for **7 days** from the `created_at` date, as indicated by the `expires_at` field. Send the onboarding link to the user before this date.

---

## Step 3: Send the Onboarding Link to the User

Construct the onboarding URL using the `id` from the Step 2 response and send it to the user.

**Template:**
```
<PROXY_URL>/ui/onboarding?id=<INVITATION_ID>
```

| Parameter | Description |
|---|---|
| `PROXY_URL` | Base URL of your LiteLLM proxy |
| `INVITATION_ID` | The `id` value from the Step 2 response |

**Example:**
```
https://licenseportal.aiengineeringlab.co.uk/ui/onboarding?id=60b2afd6-4511-408e-a854-d5f9c136682a
```

Send this URL to the user via email or your preferred communication channel. When they open the link they will be prompted to set their password and will land in the LiteLLM UI where they can create their virtual API keys.

---

## What the User Gets Access To

Once onboarded, the user will have access to everything configured on their assigned team:

- **Models** — all models assigned to the team
- **Budget** — the team's max budget and reset duration
- **Rate Limits** — any TPM/RPM limits set on the team
- **Virtual Key Creation** — subject to the team's member permission settings

---

## Automating User Onboarding with Python

The following script automates the three-step onboarding process for one or more users. It reads from a CSV file, creates each user, generates an invitation link, and outputs the onboarding URLs ready to send.

### CSV Input File (`users.csv`)

Prepare a CSV file with the following format:

```csv
user_email,team_id
alice@company.com,f6dbea80-21b4-4f7b-a669-3d6adcc6e8d1
bob@company.com,f6dbea80-21b4-4f7b-a669-3d6adcc6e8d1
carol@company.com,f6dbea80-21b4-4f7b-a669-3d6adcc6e8d1
```

> **Tip:** If all users are going to the same team you can hardcode the `TEAM_ID` in the script and simplify the CSV to just a list of email addresses.

### Python Script (`onboard_users.py`)

```python
import csv
import json
import requests

# -----------------------------------------------
# Configuration — update these values before running
# -----------------------------------------------
PROXY_URL   = "https://licenseportal.aiengineeringlab.co.uk"
MASTER_KEY  = "sk-xxxxxxxxxxxxxxxxxxxx"
CSV_FILE    = "users.csv"
USER_ROLE   = "internal_user"
# -----------------------------------------------

HEADERS = {
    "Authorization": f"Bearer {MASTER_KEY}",
    "Content-Type": "application/json"
}

def create_user(email, team_id):
    """Step 1: Create the user account and assign to a team."""
    url = f"{PROXY_URL}/user/new"
    payload = {
        "user_email": email,
        "user_role": USER_ROLE,
        "teams": [team_id]
    }
    resp = requests.post(url, headers=HEADERS, json=payload)
    resp.raise_for_status()
    data = resp.json()
    user_id = data.get("user_id")
    if not user_id:
        raise ValueError(f"No user_id returned for {email}. Response: {data}")
    return user_id

def create_invitation(user_id):
    """Step 2: Generate an invitation link for the user."""
    url = f"{PROXY_URL}/invitation/new"
    payload = {"user_id": user_id}
    resp = requests.post(url, headers=HEADERS, json=payload)
    resp.raise_for_status()
    data = resp.json()
    invitation_id = data.get("id")
    expires_at = data.get("expires_at")
    if not invitation_id:
        raise ValueError(f"No invitation id returned for user_id {user_id}. Response: {data}")
    return invitation_id, expires_at

def build_onboarding_link(invitation_id):
    """Step 3: Build the onboarding URL to send to the user."""
    return f"{PROXY_URL}/ui/onboarding?id={invitation_id}"

def onboard_users(csv_file):
    results = []
    with open(csv_file, newline="") as f:
        reader = csv.DictReader(f)
        for row in reader:
            email   = row["user_email"].strip()
            team_id = row["team_id"].strip()
            print(f"Onboarding {email}...")
            try:
                user_id       = create_user(email, team_id)
                inv_id, exp   = create_invitation(user_id)
                link          = build_onboarding_link(inv_id)
                print(f"  ✓ Onboarding link (expires {exp}):\n    {link}\n")
                results.append({
                    "email":           email,
                    "user_id":         user_id,
                    "invitation_id":   inv_id,
                    "expires_at":      exp,
                    "onboarding_link": link,
                    "status":          "success"
                })
            except Exception as e:
                print(f"  ✗ Failed to onboard {email}: {e}\n")
                results.append({
                    "email":  email,
                    "status": "failed",
                    "error":  str(e)
                })

    # Save results to a JSON file for reference
    with open("onboarding_results.json", "w") as out:
        json.dump(results, out, indent=2)
    print("Results saved to onboarding_results.json")

if __name__ == "__main__":
    onboard_users(CSV_FILE)
```

### Example Output

```
Onboarding alice@company.com...
  ✓ Onboarding link (expires 2026-03-06T08:40:15.539000Z):
    https://licenseportal.aiengineeringlab.co.uk/ui/onboarding?id=60b2afd6-4511-408e-a854-d5f9c136682a

Onboarding bob@company.com...
  ✓ Onboarding link (expires 2026-03-06T08:40:15.539000Z):
    https://licenseportal.aiengineeringlab.co.uk/ui/onboarding?id=a1c3e5f7-...

Results saved to onboarding_results.json
```

### Results File (`onboarding_results.json`)

The script saves a record of every onboarding attempt to `onboarding_results.json` for audit purposes:

```json
[
  {
    "email": "alice@company.com",
    "user_id": "e050dc40-9f3c-4982-b736-a0d019fbd82f",
    "invitation_id": "60b2afd6-4511-408e-a854-d5f9c136682a",
    "expires_at": "2026-03-06T08:40:15.539000Z",
    "onboarding_link": "https://licenseportal.aiengineeringlab.co.uk/ui/onboarding?id=60b2afd6-4511-408e-a854-d5f9c136682a",
    "status": "success"
  },
  {
    "email": "bob@company.com",
    "status": "failed",
    "error": "No user_id returned for bob@company.com"
  }
]
```

### Requirements

Install the `requests` library before running if not already present:

```bash
pip install requests
```

Run the script:

```bash
python onboard_users.py
```

---

## Configuring the Continue.dev VS Code Extension

[Continue](https://www.continue.dev/) is a VS Code extension that provides AI-assisted coding (chat, autocomplete, and code editing) directly within your IDE. Once you have your LLMLite virtual API key, you can configure Continue to use the LLMLite gateway as its model provider.

### Step 1: Install the Continue Extension

1. Open VS Code
2. Open the **Extensions Marketplace** (`Ctrl+Shift+X` / `Cmd+Shift+X`)
3. Search for **Continue** and install the extension published by `Continue`
4. Once installed, the Continue panel will appear in the left sidebar

### Step 2: Locate the Config File

The Continue configuration file is stored in your home directory. The filename is always `config.yaml`.

| Operating System | File Location |
|---|---|
| **Windows** | `%USERPROFILE%\.continue\config.yaml` (e.g. `C:\Users\alice\.continue\config.yaml`) |
| **macOS / Linux** | `~/.continue/config.yaml` (e.g. `/Users/alice/.continue/config.yaml`) |

> **Tip:** You can open the file directly from within VS Code. In the Continue chat panel, click the **config selector dropdown** in the top-right corner, then click the **cog icon** next to "Local Config". Continue will open `config.yaml` in the editor automatically.

> **Note:** If the file does not exist, Continue will create it with default values the first time it runs. You can then replace the contents with the configuration below.

### Step 3: Edit the Config File

Replace the contents of your `config.yaml` with the following configuration, substituting the placeholder values with your own.

**Template:**

```yaml
name: <CONFIG_NAME>
version: 1.0.0
schema: v1

models:
  - name: <MODEL_DISPLAY_NAME_1>
    provider: anthropic
    model: <MODEL_ID_1>
    apiBase: <PROXY_URL>/v1
    apiKey: <YOUR_VIRTUAL_KEY>

  - name: <MODEL_DISPLAY_NAME_2>
    provider: anthropic
    model: <MODEL_ID_2>
    apiBase: <PROXY_URL>/v1
    apiKey: <YOUR_VIRTUAL_KEY>
```

| Placeholder | Description |
|---|---|
| `CONFIG_NAME` | A friendly name for this configuration (e.g. `LLMLite Local Config`) |
| `MODEL_DISPLAY_NAME` | The name shown in the Continue model selector (e.g. `LiteLLM - Claude Sonnet 4.5`) |
| `MODEL_ID` | The model identifier as configured in LLMLite (see available models below) |
| `PROXY_URL` | The LLMLite gateway base URL |
| `YOUR_VIRTUAL_KEY` | Your personal LLMLite virtual API key (begins with `sk-`) |

**Example (using LLMLite AI Engineering Lab gateway):**

```yaml
name: Continue Chat Local Config
version: 1.0.0
schema: v1

models:
  - name: LiteLLM - Claude Sonnet 4.5
    provider: anthropic
    model: eu.anthropic.claude-sonnet-4-5-20250929-v1:0
    apiBase: https://licenseportal.aiengineeringlab.co.uk/v1
    apiKey: sk-xxxxxxxxxxxxxxxxxxxx

  - name: LiteLLM - Claude Haiku 4.5
    provider: anthropic
    model: eu.anthropic.claude-haiku-4-5-20251001-v1:0
    apiBase: https://licenseportal.aiengineeringlab.co.uk/v1
    apiKey: sk-xxxxxxxxxxxxxxxxxxxx
```

### Available Models

| Display Name | Model ID | Best For |
|---|---|---|
| LiteLLM - Claude Sonnet 4.5 | `eu.anthropic.claude-sonnet-4-5-20250929-v1:0` | General chat, code review, complex tasks |
| LiteLLM - Claude Haiku 4.5 | `eu.anthropic.claude-haiku-4-5-20251001-v1:0` | Fast responses, simple tasks, autocomplete |

### Step 4: Save and Verify

1. **Save** the `config.yaml` file — Continue reloads the configuration automatically, no restart required
2. Open the **Continue chat panel** in VS Code (`Ctrl+L` / `Cmd+L`)
3. Click the **model selector** at the top of the chat input — you should see your configured models listed
4. Send a test message to confirm the connection is working

### Optional: Enable Tab Autocomplete

Tab autocomplete allows Continue to suggest code completions as you type. To enable it, uncomment and update the `tabAutocompleteModel` section in your `config.yaml`:

**Template:**
```yaml
tabAutocompleteModel:
  name: <MODEL_DISPLAY_NAME>
  provider: anthropic
  model: <MODEL_ID>
  apiBase: <PROXY_URL>/v1
  apiKey: <YOUR_VIRTUAL_KEY>
```

**Example:**
```yaml
tabAutocompleteModel:
  name: LiteLLM - Claude Haiku 4.5
  provider: anthropic
  model: eu.anthropic.claude-haiku-4-5-20251001-v1:0
  apiBase: https://licenseportal.aiengineeringlab.co.uk/v1
  apiKey: sk-xxxxxxxxxxxxxxxxxxxx
```

> **Note:** Claude Haiku 4.5 is recommended for autocomplete due to its faster response time.

---

## Configuring GitHub Copilot in VS Code

GitHub Copilot is Microsoft's AI coding assistant built into VS Code. It can be configured to use the LLMLite gateway as its model provider via the **Bring Your Own Key (BYOK)** feature, available from VS Code **v1.99** onwards.

> **⚠️ Important — Provider Selection:** GitHub Copilot's native **Anthropic BYOK** provider does not currently support a custom base URL, which means it cannot be pointed at the LLMLite gateway directly. Instead, you must add LLMLite as an **OpenAI Compatible** provider, which does support a custom endpoint. The models will function identically — only the provider type differs.

> **Note:** BYOK in GitHub Copilot is available to users on **individual Copilot plans (Free, Pro, Pro+)** only. It is not currently available to **Copilot Business or Enterprise** users — those users should use the Continue.dev extension instead.

---

### Prerequisites

- VS Code **v1.99** or later
- GitHub Copilot extension installed and signed in
- Your LLMLite **virtual API key** (begins with `sk-`)

---

### Step 1: Open the Language Models Manager

1. Open the **Copilot Chat** panel (`Ctrl+Alt+I` / `Ctrl+Cmd+I` on Mac)
2. Click the **model picker** dropdown at the top of the chat input
3. Select **Manage Models...**

Alternatively, open the Command Palette (`Ctrl+Shift+P` / `Cmd+Shift+P`) and run:

```
Chat: Manage Language Models
```

---

### Step 2: Add an OpenAI Compatible Provider

1. In the Language Models editor, click **Add Models**
2. From the provider list, select **OpenAI Compatible**
3. Enter the following details:

**Template:**

| Field | Value |
|---|---|
| **Endpoint URL** | `<PROXY_URL>/v1` |
| **API Key** | `<YOUR_VIRTUAL_KEY>` |
| **Model ID** | `<MODEL_ID>` |
| **Model Display Name** | `<MODEL_DISPLAY_NAME>` |

**Example (LLMLite AI Engineering Lab gateway):**

| Field | Value |
|---|---|
| **Endpoint URL** | `https://licenseportal.aiengineeringlab.co.uk/v1` |
| **API Key** | `sk-xxxxxxxxxxxxxxxxxxxx` |
| **Model ID** | `eu.anthropic.claude-sonnet-4-5-20250929-v1:0` |
| **Model Display Name** | `LiteLLM - Claude Sonnet 4.5` |

4. Click **Add** to save the model
5. Repeat for any additional models (e.g. Claude Haiku 4.5)

---

### Step 3: Select the Model in Chat

1. Open the **Copilot Chat** panel
2. Click the **model picker** dropdown
3. Your new model(s) will appear in the list — select **LiteLLM - Claude Sonnet 4.5** (or whichever you added)
4. Send a test message to confirm the connection is working

---

### Available Models

| Display Name | Model ID | Best For |
|---|---|---|
| LiteLLM - Claude Sonnet 4.5 | `eu.anthropic.claude-sonnet-4-5-20250929-v1:0` | General chat, code review, complex tasks |
| LiteLLM - Claude Haiku 4.5 | `eu.anthropic.claude-haiku-4-5-20251001-v1:0` | Fast responses, simple tasks |

---

### Alternative: Configure via VS Code settings.json

If you prefer to configure via settings rather than the UI, you can add the following to your VS Code `settings.json` (`Ctrl+Shift+P` → **Preferences: Open User Settings (JSON)**):

**Template:**
```json
{
  "github.copilot.chat.customOAIModels": [
    {
      "name": "<MODEL_DISPLAY_NAME>",
      "url": "<PROXY_URL>/v1",
      "apiKey": "<YOUR_VIRTUAL_KEY>",
      "modelId": "<MODEL_ID>"
    }
  ]
}
```

**Example:**
```json
{
  "github.copilot.chat.customOAIModels": [
    {
      "name": "LiteLLM - Claude Sonnet 4.5",
      "url": "https://licenseportal.aiengineeringlab.co.uk/v1",
      "apiKey": "sk-xxxxxxxxxxxxxxxxxxxx",
      "modelId": "eu.anthropic.claude-sonnet-4-5-20250929-v1:0"
    },
    {
      "name": "LiteLLM - Claude Haiku 4.5",
      "url": "https://licenseportal.aiengineeringlab.co.uk/v1",
      "apiKey": "sk-xxxxxxxxxxxxxxxxxxxx",
      "modelId": "eu.anthropic.claude-haiku-4-5-20251001-v1:0"
    }
  ]
}
```

Save the file — VS Code will reload the configuration automatically.

---

### Troubleshooting

| Issue | Resolution |
|---|---|
| **OpenAI Compatible** option not visible | Ensure VS Code is updated to v1.99 or later. Run **Help: Check for Updates**. |
| Model not appearing in picker after adding | Close and reopen the chat panel, or reload VS Code (`Ctrl+Shift+P` → **Developer: Reload Window**) |
| `401 Unauthorized` error | Verify your virtual key is correct and has not expired. Generate a new key via the LLMLite Admin Portal if needed. |
| `404 Not Found` error | Check the endpoint URL ends with `/v1` and does not have a trailing slash after it |
| Feature unavailable (Copilot Business/Enterprise) | BYOK is not supported on Business/Enterprise plans. Use the **Continue.dev** extension instead — see the section above. |

---

## Configuring Claude Code

Claude Code is Anthropic's official agentic coding assistant. It is available as both a **VS Code extension** and a **CLI tool**, and can be configured to route all requests through the LLMLite gateway using two environment variables.

> **Note:** The VS Code extension and the CLI share the same settings file (`~/.claude/settings.json`), so configuring one configures both.

---

### Prerequisites

- Claude Code VS Code extension installed, **or** Claude Code CLI installed (`npm install -g @anthropic-ai/claude-code`)
- Your LLMLite **virtual API key** (begins with `sk-`)

---

### Option A: Configure via `~/.claude/settings.json` (Recommended)

This method persists across all terminal sessions and is shared between the CLI and the VS Code extension.

**File location:**

| Operating System | File Path |
|---|---|
| **Windows** | `%USERPROFILE%\.claude\settings.json` |
| **macOS / Linux** | `~/.claude/settings.json` |

Create or edit the file and add the following `env` block:

**Template:**
```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "<PROXY_URL>",
    "ANTHROPIC_AUTH_TOKEN": "<YOUR_VIRTUAL_KEY>",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "<SONNET_MODEL_ID>",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "<HAIKU_MODEL_ID>"
  }
}
```

| Parameter | Description |
|---|---|
| `PROXY_URL` | The LLMLite gateway base URL (without `/v1`) |
| `YOUR_VIRTUAL_KEY` | Your personal LLMLite virtual API key (begins with `sk-`) |
| `SONNET_MODEL_ID` | The model ID to use for Sonnet-class requests |
| `HAIKU_MODEL_ID` | The model ID to use for Haiku-class (fast/background) requests |

**Example:**
```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://licenseportal.aiengineeringlab.co.uk",
    "ANTHROPIC_AUTH_TOKEN": "sk-xxxxxxxxxxxxxxxxxxxx",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "eu.anthropic.claude-sonnet-4-5-20250929-v1:0",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "eu.anthropic.claude-haiku-4-5-20251001-v1:0"
  }
}
```

> **Note:** `ANTHROPIC_BASE_URL` should be the base gateway URL **without** a `/v1` suffix. Claude Code appends the correct path automatically.

---

### Option B: Configure via Environment Variables (CLI / Terminal Session)

For a quick per-session configuration, export the variables directly in your terminal before launching Claude Code.

**macOS / Linux:**

**Template:**
```bash
export ANTHROPIC_BASE_URL="<PROXY_URL>"
export ANTHROPIC_AUTH_TOKEN="<YOUR_VIRTUAL_KEY>"
export ANTHROPIC_DEFAULT_SONNET_MODEL="<SONNET_MODEL_ID>"
export ANTHROPIC_DEFAULT_HAIKU_MODEL="<HAIKU_MODEL_ID>"
claude
```

**Example:**
```bash
export ANTHROPIC_BASE_URL="https://licenseportal.aiengineeringlab.co.uk"
export ANTHROPIC_AUTH_TOKEN="sk-xxxxxxxxxxxxxxxxxxxx"
export ANTHROPIC_DEFAULT_SONNET_MODEL="eu.anthropic.claude-sonnet-4-5-20250929-v1:0"
export ANTHROPIC_DEFAULT_HAIKU_MODEL="eu.anthropic.claude-haiku-4-5-20251001-v1:0"
claude
```

**Windows (PowerShell):**

```powershell
$env:ANTHROPIC_BASE_URL = "https://licenseportal.aiengineeringlab.co.uk"
$env:ANTHROPIC_AUTH_TOKEN = "sk-xxxxxxxxxxxxxxxxxxxx"
$env:ANTHROPIC_DEFAULT_SONNET_MODEL = "eu.anthropic.claude-sonnet-4-5-20250929-v1:0"
$env:ANTHROPIC_DEFAULT_HAIKU_MODEL = "eu.anthropic.claude-haiku-4-5-20251001-v1:0"
claude
```

> **Tip:** To make these permanent on macOS/Linux, add the `export` lines to your `~/.bashrc` or `~/.zshrc` file. On Windows, use `setx` or add to your PowerShell `$PROFILE`.

---

### Option C: Configure the VS Code Extension

If you prefer to configure the Claude Code VS Code extension directly via VS Code settings:

1. Open VS Code Settings (`Ctrl+,` / `Cmd+,`)
2. Search for **Claude Code: Environment Variables**
3. Click **Edit in settings.json**
4. Add the following to your VS Code `settings.json`:

**Template:**
```json
{
  "claudeCode.environmentVariables": [
    { "name": "ANTHROPIC_BASE_URL",              "value": "<PROXY_URL>" },
    { "name": "ANTHROPIC_AUTH_TOKEN",             "value": "<YOUR_VIRTUAL_KEY>" },
    { "name": "ANTHROPIC_DEFAULT_SONNET_MODEL",   "value": "<SONNET_MODEL_ID>" },
    { "name": "ANTHROPIC_DEFAULT_HAIKU_MODEL",    "value": "<HAIKU_MODEL_ID>" }
  ]
}
```

**Example:**
```json
{
  "claudeCode.environmentVariables": [
    { "name": "ANTHROPIC_BASE_URL",              "value": "https://licenseportal.aiengineeringlab.co.uk" },
    { "name": "ANTHROPIC_AUTH_TOKEN",             "value": "sk-xxxxxxxxxxxxxxxxxxxx" },
    { "name": "ANTHROPIC_DEFAULT_SONNET_MODEL",   "value": "eu.anthropic.claude-sonnet-4-5-20250929-v1:0" },
    { "name": "ANTHROPIC_DEFAULT_HAIKU_MODEL",    "value": "eu.anthropic.claude-haiku-4-5-20251001-v1:0" }
  ]
}
```

Restart VS Code after saving to ensure the settings take effect.

---

### Available Models

| Display Name | Model ID | Used For |
|---|---|---|
| Claude Sonnet 4.5 | `eu.anthropic.claude-sonnet-4-5-20250929-v1:0` | Main chat and complex tasks |
| Claude Haiku 4.5 | `eu.anthropic.claude-haiku-4-5-20251001-v1:0` | Fast background tasks |

---

### Verify the Configuration

Once configured, launch Claude Code and run a quick test:

```bash
claude "Hello — which model are you?"
```

Claude Code should respond without prompting for a login and the response should confirm it is routing through the LLMLite gateway.

---

### Troubleshooting

| Issue | Resolution |
|---|---|
| Login/sign-in prompt appears on first run | On a fresh install, Claude Code may ignore `settings.json` on the very first launch. Workaround: temporarily set `ANTHROPIC_BASE_URL` and `ANTHROPIC_AUTH_TOKEN` as shell environment variables, run `claude` once to complete initialisation, then remove them — `settings.json` will be picked up on subsequent runs. |
| `401 Unauthorized` | Verify your virtual key is correct and has not expired. Generate a new key via the LLMLite Admin Portal if needed. |
| `Connection refused` or `Unable to connect` | Check that `ANTHROPIC_BASE_URL` does **not** include `/v1` at the end. |
| Extension not picking up `settings.json` changes | Fully restart VS Code (`Ctrl+Shift+P` → **Developer: Reload Window**) after editing the settings file. |
| VS Code extension shows Anthropic login screen | Ensure `ANTHROPIC_BASE_URL` and `ANTHROPIC_AUTH_TOKEN` are set in the VS Code extension settings (Option C above), not just in `settings.json`, as the extension and CLI may load configuration differently. |

---

## Troubleshooting

| Issue | Resolution |
|---|---|
| User cannot create a virtual key | Check that `/key/generate` is included in the team's `team_member_permissions`. See the Team Permissions guide. |
| Invitation link has expired | Repeat Step 2 to generate a new invitation. Links are valid for 7 days. |
| User not receiving invitation email | Verify that SMTP/email settings are configured on the proxy. Settings are found under **Admin Portal → Settings → Email Settings**. |
| Budget not being enforced | Set `max_budget` and `budget_duration` at the team level rather than the user level. |
