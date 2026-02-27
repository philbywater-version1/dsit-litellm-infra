# LiteLLM User Onboarding Guide

## Overview

This guide walks through the process of onboarding a new user to the LiteLLM AI Gateway. The process consists of three steps:

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
  -H 'Authorization: Bearer sk-1234' \
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
  -H 'Authorization: Bearer sk-1234' \
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
MASTER_KEY  = "sk-1234"
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

## Troubleshooting

| Issue | Resolution |
|---|---|
| User cannot create a virtual key | Check that `/key/generate` is included in the team's `team_member_permissions`. See the Team Permissions guide. |
| Invitation link has expired | Repeat Step 2 to generate a new invitation. Links are valid for 7 days. |
| User not receiving invitation email | Verify that SMTP/email settings are configured on the proxy. Settings are found under **Admin Portal → Settings → Email Settings**. |
| Budget not being enforced | Set `max_budget` and `budget_duration` at the team level rather than the user level. |
