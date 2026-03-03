# Kiro Enterprise IDE — Low-Level Design Document

**Document Version:** 1.0
**Date:** 2026-02-23
**Status:** Draft for Review
**Target Audience:** Infrastructure Team, Security Team, IT Administrators

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [System Overview](#2-system-overview)
3. [Authentication Flow](#3-authentication-flow)
4. [Kiro Profile & Region Design](#4-kiro-profile--region-design)
5. [AWS IAM Identity Center Configuration](#5-aws-iam-identity-center-configuration)
6. [Security Design](#6-security-design)
7. [Networking](#7-networking)
8. [Model Access & Data Protection](#8-model-access--data-protection)
9. [Onboarding Steps](#9-onboarding-steps)
10. [Operations & Monitoring](#10-operations--monitoring)

---

## 1. Executive Summary

### 1.1 Project Overview

**Kiro** is an agentic AI IDE developed by AWS that provides enterprise development teams with AI-assisted coding capabilities, including spec-driven development, inline code suggestions, autonomous agents, and chat-based interactions. This document describes the low-level design for deploying Kiro in an enterprise context, using AWS IAM Identity Center for authentication and a Kiro profile hosted in the **Europe (Frankfurt) — eu-central-1** region to ensure data residency within Europe.

Kiro is built on top of the VS Code OSS editor and is powered by Amazon Bedrock. Developers interact with it via the Kiro IDE (desktop application) or the Kiro CLI, both of which authenticate through the organisation's IAM Identity Center instance.

### 1.2 Key Design Decisions

| Decision | Choice | Rationale |
|---|---|---|
| **Kiro Profile Region** | Europe (Frankfurt) — `eu-central-1` | Data stored and inference performed in Europe; satisfies GDPR / data residency requirements |
| **IAM Identity Center Region** | Europe (Frankfurt) — `eu-central-1` | Collocated with Kiro profile for simplicity; supported region |
| **Identity Source** | IAM Identity Center Built-in Directory or external IdP (e.g. Entra ID / Okta) | Centralised identity management; SSO for developers |
| **Encryption** | Customer Managed KMS Key | Enterprise-grade control over data encryption |
| **Prompt Logging** | Enabled, logs to S3 in `eu-central-1` | Audit, compliance, and traceability |
| **Content for Service Improvement** | Disabled (Enterprise default) | Enterprise users are automatically opted out |

### 1.3 Technology Stack

| Component | Technology | Purpose |
|---|---|---|
| **IDE Client** | Kiro IDE (VS Code–based) | Developer-facing AI IDE |
| **CLI Client** | Kiro CLI | Terminal-based AI coding assistant |
| **Authentication** | AWS IAM Identity Center (SSO) | Enterprise SSO; supports external IdPs |
| **Identity Source** | Built-in Directory / Microsoft Entra ID / Okta | User and group management |
| **AI Backend** | Amazon Bedrock (via Kiro Service) | LLM inference (Claude models) |
| **Profile Region** | `eu-central-1` (Frankfurt) | Data storage and inference region |
| **Encryption** | AWS KMS — Customer Managed Key | Data encryption at rest |
| **Prompt Logging** | Amazon S3 (`eu-central-1`) | Audit logs for prompts and responses |
| **Monitoring** | AWS CloudTrail, Amazon CloudWatch | API-level audit and metrics |
| **Subscription Management** | Kiro Console (AWS Management Console) | User/group subscription management |

---

## 2. System Overview

### 2.1 Business Context

**Problem:** Development teams require a governed, enterprise-grade AI IDE that integrates with existing identity infrastructure, keeps data within European boundaries, and provides security controls appropriate for corporate environments.

**Solution:** Deploy Kiro Enterprise using AWS IAM Identity Center for SSO authentication, with the Kiro profile hosted in Frankfurt (`eu-central-1`) to ensure all data storage and inference remains within Europe. Developers authenticate using their corporate identity (via Entra ID / Okta connected to IAM Identity Center), and admins manage subscriptions and security policies through the Kiro Console.

### 2.2 Authentication Flow Diagram

The following diagram reflects the numbered flow shown in the architecture image provided:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         KIRO ENTERPRISE AUTH FLOW                           │
└─────────────────────────────────────────────────────────────────────────────┘

┌──────────────┐   1. Opens IDE &        ┌──────────────────┐
│              │   initiates login       │                  │
│  Developer   │ ──────────────────────► │    Kiro IDE       │
│  (End User)  │                         │                  │
└──────────────┘                         └────────┬─────────┘
       │                                          │
       │ 2. Kiro IDE opens                        │ 5. Auth token returned
       │    Web Browser for                       │    from Identity Center
       │    SSO login                             │    to IDE
       ▼                                          │
┌──────────────┐                                  │
│              │   3. Browser authenticates ──────┼──────────────────────────►
│  Web Browser │   to Identity Center             │            ▼
│              │   (OIDC / SAML)                  │  ┌────────────────────────┐
└──────────────┘                                  │  │   IAM Identity Center  │
                                                  │  │   (eu-central-1)       │
                                                  │  │   • SSO Portal         │
                                                  │  │   • Token issuance     │
                                                  │  └──────────┬─────────────┘
                                                  │             │
                                                  │             │ 4. Identity Center
                                                  │             │    validates user
                                                  │             ▼    against directory
                                                  │  ┌────────────────────────┐
                                                  │  │  Identity Center       │
                                                  │  │  Directory             │
                                                  │  │  (Built-in Users)      │
                                                  │  │  — or —                │
                                                  │  │  External IdP          │
                                                  │  │  (Entra ID / Okta)     │
                                                  │  └────────────────────────┘
                                                  │
                                          Once authenticated:
                                                  │
                                                  ▼
                                    ┌─────────────────────────┐
                                    │  Kiro Service           │
                                    │  (eu-central-1)         │
                                    │  • Validates subscription│
                                    │  • Routes to Bedrock    │
                                    │  • Logs to S3           │
                                    └─────────────────────────┘
```

### 2.3 Component Interaction Summary

```
Developer Workstation
├── Kiro IDE  ──── (1) Sign in with IAM Identity Center ──────► IAM Identity Center (eu-central-1)
│                  (5) Receive OIDC token ◄─────────────────────        │
│                                                                        │ (3/4) Validate
│                                                                        ▼
│                                                               Identity Directory
│                                                               (Built-in / Entra / Okta)
│
├── Kiro IDE  ──── (authenticated) ──────────────────────────► Kiro Service (eu-central-1)
│                                                                        │
│                                                                        ├──► Amazon Bedrock
│                                                                        │    (Claude models)
│                                                                        │
│                                                                        ├──► S3 Prompt Logs
│                                                                        │    (eu-central-1)
│                                                                        │
│                                                                        └──► CloudWatch Metrics
│
└── Kiro CLI  ──── (device code auth via browser) ──────────► IAM Identity Center (eu-central-1)
```

---

## 3. Authentication Flow

### 3.1 Authentication Method: AWS IAM Identity Center

Kiro Enterprise uses **AWS IAM Identity Center** as its exclusive enterprise authentication mechanism. Social logins (GitHub, Google) and AWS Builder ID are not used in the enterprise context.

**Authentication sequence (numbered, matching diagram):**

| Step | Actor | Action | Detail |
|---|---|---|---|
| **1** | Developer | Opens Kiro IDE and initiates sign-in | Selects "Sign in with AWS IAM Identity Center" |
| **2** | Kiro IDE | Launches web browser for SSO | Redirects to the IAM Identity Center Start URL |
| **3** | Web Browser | Developer authenticates via SSO portal | Enters credentials; may be redirected to external IdP (Entra / Okta) |
| **4** | IAM Identity Center | Validates user identity against directory | Checks user exists, is active, and has a Kiro subscription |
| **5** | IAM Identity Center | Issues OIDC token back to Kiro IDE | Short-lived access token returned; session established |

**IDE configuration required (per developer):**
- **Start URL:** `https://d-xxxxxxxxxx.awsapps.com/start` (provided by admin)
- **Region:** `eu-central-1` (Frankfurt)

### 3.2 Session Management

- **Default session duration:** 8 hours (configurable by administrator)
- **Re-authentication:** Required after session expiry; developer repeats browser-based SSO flow
- **Session extension:** Administrators can configure longer timeouts via IAM Identity Center session settings
- **CLI authentication:** Uses device code flow — Kiro CLI outputs a URL and code that the developer enters in their browser; no additional port forwarding required for local machines

### 3.3 External Identity Provider Integration

If the organisation uses an external IdP (Microsoft Entra ID or Okta), IAM Identity Center acts as a broker:

```
Developer → IAM Identity Center SSO Portal → External IdP (SAML 2.0 / OIDC)
                                                     │
                                          Corporate credentials validated
                                                     │
                    SAML assertion / token returned to IAM Identity Center
                                                     │
                                         Kiro session token issued
```

**Supported external IdPs:**
- Microsoft Entra ID (formerly Azure AD)
- Okta
- Any SAML 2.0 or OIDC-compatible provider

**Recommendation:** Use AWS Organizations with an organisation-level IAM Identity Center instance. This provides centralised identity management across multiple AWS accounts and cannot be upgraded from an individual account instance without deletion and recreation.

---

## 4. Kiro Profile & Region Design

### 4.1 Region Selection — Europe (Frankfurt)

The Kiro profile must be created in one of two supported regions:

| Supported Profile Regions | Notes |
|---|---|
| `us-east-1` — US East (N. Virginia) | Data stored in the US |
| **`eu-central-1` — Europe (Frankfurt)** | ✅ **Recommended for European deployments** |

**Recommendation: Create the Kiro profile in `eu-central-1` (Frankfurt).**

This ensures:
- All developer data (prompts, responses, code context) is **stored in Europe**
- LLM inference is performed within the European geography
- GDPR and organisational data residency requirements are met
- Cross-region inference (for throughput/resilience) remains within European AWS regions

> **Important:** The region where the Kiro profile is created is where all data is stored. This is separate from — and independent of — the IAM Identity Center region. Both can be set to `eu-central-1` for simplicity.

### 4.2 Profile Configuration

The Kiro profile is the central management object that ties together user identities, subscriptions, and security settings.

**Profile settings:**

| Setting | Value | Notes |
|---|---|---|
| **Profile Name** | `kiro-enterprise-profile` | Descriptive name for the organisation |
| **Region** | `eu-central-1` | Frankfurt; data residency in Europe |
| **Identity Provider** | IAM Identity Center | Connected to Built-in Directory or external IdP |
| **Encryption** | Customer Managed KMS Key | See Section 6.2 |
| **Prompt Logging** | Enabled | Logs written to S3 bucket in `eu-central-1` |
| **User Activity Reports** | Enabled (admin discretion) | Per-user telemetry written to S3 |
| **Code References** | Configured per policy | Controls suggestions from open-source code |
| **Web Tools** | Disabled (recommended) | Disable `web_search` and `web_fetch` for data control |
| **Content for Service Improvement** | **Disabled (automatic)** | Enterprise users are automatically opted out |

### 4.3 Service-Linked Roles

When the Kiro profile is created, AWS automatically creates two service-linked roles in the account. These do not require manual creation.

**AWSServiceRoleForUserSubscriptions**
- Allows Kiro to access IAM Identity Center resources
- Manages subscription state automatically
- Trusted service: `kiro.amazonaws.com`

**AWSServiceRoleForAmazonQDeveloper**
- Allows Kiro to calculate billing and emit metrics
- Provides access to CodeGuru security reports
- Emits data to CloudWatch (`AWS/Q` namespace)
- Trusted service: `q.amazonaws.com`

---

## 5. AWS IAM Identity Center Configuration

### 5.1 IAM Identity Center Setup

**Prerequisites:**
- AWS account with administrator-level access
- IAM Identity Center enabled in `eu-central-1`
- Users and groups added to the directory (built-in or via external IdP sync)

**IAM Identity Center Instance Configuration:**

| Property | Value |
|---|---|
| **Instance Type** | Organisation instance (recommended) or account instance |
| **Region** | `eu-central-1` |
| **Identity Source** | Built-in Directory / Microsoft Entra ID / Okta |
| **MFA** | Enabled (recommended: TOTP or hardware keys) |
| **Session Duration** | Configurable (default 8 hours) |
| **Start URL** | `https://d-xxxxxxxxxx.awsapps.com/start` |

> **Note:** If using an organisation-level IAM Identity Center instance, it must be created as such from the outset. An individual account instance cannot be upgraded to an organisation instance.

### 5.2 User and Group Management

Users can be managed in one of two ways:

**Option A — Built-in Directory:**
- Create users and groups directly within IAM Identity Center
- User provisioning is manual or via SCIM API
- Suitable for smaller teams or where a corporate IdP is not available

**Option B — External Identity Provider (Recommended for Enterprise):**
- Connect IAM Identity Center to Microsoft Entra ID or Okta via SCIM + SAML
- Users and groups are synchronised automatically from the corporate directory
- Developers use their existing corporate credentials — no separate password
- Group membership in the IdP controls Kiro access and subscription

**Group structure recommendation:**

| Group Name | Members | Kiro Access |
|---|---|---|
| `kiro-developers` | All developers requiring Kiro access | Subscribed to Kiro |
| `kiro-admins` | IT/platform admins managing Kiro | Admin access to Kiro console |
| `kiro-powerusers` | Senior engineers / architects | Power tier subscription (if applicable) |

### 5.3 IAM Policy for Kiro Administrators

The IAM identity (user or role) used to configure Kiro subscriptions requires the following permissions. Attach this policy to the admin role:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "KiroConsoleAccess",
      "Effect": "Allow",
      "Action": [
        "q:CreateSubscriptionToken",
        "q:ListProfiles",
        "q:GetProfile",
        "q:CreateProfile",
        "q:UpdateProfile",
        "q:DeleteProfile",
        "q:Subscribe",
        "q:Unsubscribe",
        "q:ListSubscriptions",
        "sso:ListInstances",
        "sso:DescribeRegisteredRegions",
        "sso:ListDirectoryAssociations",
        "sso-directory:ListGroups",
        "sso-directory:ListUsers",
        "sso-directory:DescribeUser",
        "sso-directory:DescribeGroup"
      ],
      "Resource": "*"
    },
    {
      "Sid": "KMSForKiro",
      "Effect": "Allow",
      "Action": [
        "kms:CreateKey",
        "kms:DescribeKey",
        "kms:CreateAlias",
        "kms:ListAliases",
        "kms:PutKeyPolicy",
        "kms:EnableKeyRotation"
      ],
      "Resource": "*"
    }
  ]
}
```

---

## 6. Security Design

### 6.1 Security Layers

```
┌──────────────────────────────────────────────────────────────────────────┐
│                     KIRO ENTERPRISE SECURITY LAYERS                      │
│                                                                          │
│  Layer 1: IDENTITY & ACCESS                                             │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │  • AWS IAM Identity Center — SSO for all developer access         │ │
│  │  • External IdP integration (Entra ID / Okta) — corporate creds   │ │
│  │  • Group-based subscription control                                │ │
│  │  • MFA enforced at Identity Center level                           │ │
│  │  • Session timeout (default 8 hours, configurable)                 │ │
│  │  • Service-linked roles — least-privilege for Kiro service         │ │
│  └────────────────────────────────────────────────────────────────────┘ │
│                                                                          │
│  Layer 2: DATA PROTECTION                                               │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │  • All data stored in eu-central-1 (Frankfurt)                    │ │
│  │  • Encryption at rest: Customer Managed KMS Key                   │ │
│  │  • Encryption in transit: TLS 1.2+                                │ │
│  │  • Enterprise users automatically opted out of service improvement │ │
│  │  • No customer content used for AWS model training                 │ │
│  └────────────────────────────────────────────────────────────────────┘ │
│                                                                          │
│  Layer 3: AUDIT & MONITORING                                            │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │  • Prompt Logging → S3 bucket (eu-central-1, KMS encrypted)       │ │
│  │  • User Activity Reports → S3 bucket (per-user telemetry)         │ │
│  │  • AWS CloudTrail → API-level audit of all Kiro/IAM actions       │ │
│  │  • CloudWatch → Kiro metrics (AWS/Q namespace)                     │ │
│  └────────────────────────────────────────────────────────────────────┘ │
│                                                                          │
│  Layer 4: NETWORK                                                       │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │  • Kiro is a managed SaaS service — no VPC deployment required    │ │
│  │  • Developer workstations connect outbound over HTTPS (TLS 1.2+)  │ │
│  │  • Corporate proxy / firewall allow-list required (see Section 7) │ │
│  │  • IAM Identity Center SSO portal accessible over HTTPS           │ │
│  └────────────────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────────────────┘
```

### 6.2 Encryption

#### Encryption in Transit

All communication between the Kiro IDE/CLI and Kiro service endpoints is protected using **TLS 1.2 or higher**. This applies to:
- IDE → IAM Identity Center (authentication)
- IDE → Kiro Service (prompts, responses, inline suggestions)
- Kiro Service → Amazon Bedrock (model inference)
- Kiro Service → S3 (prompt log writes)

#### Encryption at Rest

By default, Kiro encrypts data using AWS-owned KMS keys. For enterprise deployments, a **Customer Managed Key (CMK)** should be created to provide full control over data access.

**CMK Configuration:**

| Property | Value |
|---|---|
| **Key Type** | Symmetric (AES-256) — only symmetric keys are supported |
| **Region** | `eu-central-1` (must match Kiro profile region) |
| **Key Alias** | `alias/kiro-enterprise-key` |
| **Key Rotation** | Enabled (annual automatic rotation) |
| **Key Policy** | Restricts usage to Kiro service and authorised admin roles |

**KMS Key Policy (minimum viable):**

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "RootAccountAccess",
      "Effect": "Allow",
      "Principal": { "AWS": "arn:aws:iam::ACCOUNT_ID:root" },
      "Action": "kms:*",
      "Resource": "*"
    },
    {
      "Sid": "KiroServiceAccess",
      "Effect": "Allow",
      "Principal": { "Service": "q.amazonaws.com" },
      "Action": ["kms:Decrypt", "kms:GenerateDataKey"],
      "Resource": "*"
    },
    {
      "Sid": "KiroAdminAccess",
      "Effect": "Allow",
      "Principal": { "AWS": "arn:aws:iam::ACCOUNT_ID:role/KiroAdminRole" },
      "Action": [
        "kms:Describe*", "kms:List*", "kms:Get*",
        "kms:EnableKeyRotation", "kms:PutKeyPolicy"
      ],
      "Resource": "*"
    }
  ]
}
```

**Steps to configure CMK in Kiro:**
1. Create the KMS key in `eu-central-1` with the policy above
2. Navigate to the Kiro Console → Profile Settings → Encryption
3. Provide the KMS Key ARN in the Encryption field
4. Save the profile — Kiro will begin using the CMK for all new data

### 6.3 Prompt Logging

Prompt logging captures all developer interactions with Kiro (chat prompts, inline suggestion requests, and Kiro's responses) into an S3 bucket for audit and compliance purposes.

**S3 Bucket Configuration:**

| Property | Value |
|---|---|
| **Bucket Name** | `kiro-prompt-logs-{account-id}` |
| **Region** | `eu-central-1` (must match Kiro profile region) |
| **Versioning** | Enabled |
| **Encryption** | SSE-KMS using `alias/kiro-enterprise-key` |
| **Block Public Access** | All public access blocked |
| **Lifecycle Policy** | Retain 7 years (or as per compliance requirements) |
| **Access** | Restricted to Kiro service role and designated audit role |

**Log file structure:**

```
s3://kiro-prompt-logs-{account-id}/
  └── AmazonQ/
      └── {year}/{month}/{day}/
          └── {conversationId}-{timestamp}.json
```

**Log entry fields:**

| Field | Description |
|---|---|
| `userId` | IAM Identity Center user ID |
| `timeStamp` | ISO 8601 timestamp of the interaction |
| `prompt` | Developer's input message |
| `assistantResponse` | Kiro's generated response |
| `conversationId` | Unique ID for the conversation session |
| `chatTriggerType` | `MANUAL` (chat) or `INLINE_COMPLETION` |
| `codeReferenceEvents` | Any open-source code references included |

**Required S3 bucket policy** (to allow Kiro to write logs):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "KiroPromptLogging",
      "Effect": "Allow",
      "Principal": { "Service": "q.amazonaws.com" },
      "Action": ["s3:PutObject"],
      "Resource": "arn:aws:s3:::kiro-prompt-logs-{account-id}/AmazonQ/*",
      "Condition": {
        "StringEquals": { "aws:SourceAccount": "ACCOUNT_ID" }
      }
    }
  ]
}
```

### 6.4 CloudTrail Audit Logging

AWS CloudTrail records all AWS API-level calls made in the account, including:
- Kiro console operations (profile create/update, subscription changes)
- IAM Identity Center user/group management
- KMS key usage (encrypt/decrypt events)
- S3 access to prompt log bucket

**CloudTrail configuration:**

| Property | Value |
|---|---|
| **Trail Name** | `kiro-enterprise-trail` |
| **Multi-Region** | Enabled |
| **S3 Bucket** | `kiro-cloudtrail-logs-{account-id}` |
| **Log File Validation** | Enabled |
| **KMS Encryption** | Enabled (`alias/kiro-enterprise-key`) |

> **Note:** CloudTrail does not capture MCP (Model Context Protocol) tool calls that occur locally or outside AWS. MCP calls that invoke AWS services will appear in CloudTrail via the relevant service's API logs.

---

## 7. Networking

### 7.1 Architecture Overview

Kiro is a **fully managed SaaS service** delivered by AWS. There is no Kiro infrastructure deployed into the customer's VPC. Developer workstations connect outbound over the internet to Kiro's AWS-hosted endpoints.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         NETWORK TOPOLOGY                                │
│                                                                         │
│  Corporate Network / Developer Workstations                             │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │                                                                  │  │
│  │  ┌──────────────┐    ┌──────────────┐    ┌──────────────────┐  │  │
│  │  │  Developer   │    │  Developer   │    │    Developer     │  │  │
│  │  │  Workstation │    │  Workstation │    │    Workstation   │  │  │
│  │  │  (Kiro IDE)  │    │  (Kiro IDE)  │    │    (Kiro CLI)    │  │  │
│  │  └──────┬───────┘    └──────┬───────┘    └───────┬──────────┘  │  │
│  │         │                   │                     │             │  │
│  │         └───────────────────┴─────────────────────┘             │  │
│  │                             │                                    │  │
│  │                    ┌────────▼────────┐                          │  │
│  │                    │  Corporate      │                          │  │
│  │                    │  Proxy /        │                          │  │
│  │                    │  Firewall       │                          │  │
│  │                    └────────┬────────┘                          │  │
│  └─────────────────────────────┼──────────────────────────────────┘  │
│                                │  HTTPS (TLS 1.2+)                    │
└────────────────────────────────┼────────────────────────────────────── ┘
                                 │
                  ┌──────────────▼─────────────────────────────────┐
                  │              INTERNET                           │
                  └──────────────┬─────────────────────────────────┘
                                 │
          ┌──────────────────────┼───────────────────────────────┐
          │                      │                               │
          ▼                      ▼                               ▼
┌──────────────────┐  ┌─────────────────────┐      ┌────────────────────────┐
│  IAM Identity    │  │  Kiro Service        │      │  Amazon Bedrock        │
│  Center          │  │  Endpoints           │      │  (LLM Inference)       │
│  (eu-central-1)  │  │  (eu-central-1)      │      │  (eu-central-1 +       │
│  SSO Portal      │  │  API + Data Storage  │      │   cross-region EU)     │
└──────────────────┘  └─────────────────────┘      └────────────────────────┘
```

### 7.2 Required Firewall / Proxy Allow-List

Kiro requires outbound HTTPS (port 443) access from developer workstations to the following endpoint categories. Configure your corporate proxy or firewall to permit these:

| Endpoint Category | Hostname Pattern | Protocol | Port | Purpose |
|---|---|---|---|---|
| **IAM Identity Center SSO** | `*.awsapps.com` | HTTPS | 443 | Authentication / SSO portal |
| **Kiro Service** | `*.q.us-east-1.amazonaws.com` | HTTPS | 443 | Core Kiro API (routed to profile region) |
| **Kiro IDE Updates** | `kiro.dev` | HTTPS | 443 | IDE downloads, documentation |
| **Amazon Bedrock** | `bedrock-runtime.eu-central-1.amazonaws.com` | HTTPS | 443 | LLM inference |
| **S3 (Prompt Logs)** | `s3.eu-central-1.amazonaws.com` | HTTPS | 443 | Prompt log writes |
| **CloudWatch** | `monitoring.eu-central-1.amazonaws.com` | HTTPS | 443 | Metrics |
| **KMS** | `kms.eu-central-1.amazonaws.com` | HTTPS | 443 | Encryption key operations |
| **AWS STS** | `sts.amazonaws.com` | HTTPS | 443 | Token exchange |

> **Note:** Some authentication steps (OIDC redirect flows) may also require connectivity to the corporate IdP endpoint (e.g. `login.microsoftonline.com` for Entra ID or `your-org.okta.com` for Okta).

### 7.3 Developer Workstation Requirements

| Requirement | Details |
|---|---|
| **Operating System** | macOS, Windows, or Linux |
| **Kiro IDE Version** | Latest stable release (minimum 0.9.2 for IAM Identity Center support) |
| **Kiro CLI Version** | Latest stable (minimum 1.25.0 for IAM Identity Center support) |
| **Internet Access** | Outbound HTTPS on port 443 to endpoints listed in Section 7.2 |
| **Browser** | Required for initial SSO authentication (any modern browser) |
| **Proxy Configuration** | Set `HTTPS_PROXY` environment variable if behind a corporate proxy |

### 7.4 No VPC / Private Endpoint Required

Kiro does not currently support deployment within a customer VPC or over AWS PrivateLink. All connectivity is over the public internet (protected by TLS). If your organisation requires all traffic to remain on-network, consider routing outbound Kiro traffic through a corporate proxy that inspects and forwards HTTPS traffic.

---

## 8. Model Access & Data Protection

### 8.1 Underlying AI Models

Kiro is powered by **Amazon Bedrock** and uses **Claude** (Anthropic) models for code generation, chat responses, and agentic tasks. Developers do not directly interact with Bedrock — model selection and routing is managed by the Kiro service.

| Model Capability | Default Behaviour | Notes |
|---|---|---|
| **Inline Suggestions** | Auto model selection | Kiro selects the most appropriate model |
| **Chat / Vibe Mode** | Auto model selection | Can be manually set by user to a specific model (e.g. Claude Sonnet 4) |
| **Spec Tasks** | Auto model selection | Complex agentic tasks; higher credit consumption |
| **Experimental Features** | May use global cross-region inference | Data storage region unaffected |

### 8.2 Cross-Region Inference

Kiro uses Amazon Bedrock cross-region inference to improve throughput and resilience. Key points:

- **Cross-region inference does not change where data is stored.** Data always remains in the Kiro profile region (`eu-central-1`).
- For non-experimental features, inference traffic stays **within the same geography** (European AWS regions).
- For experimental model features, traffic may be routed globally. If this is unacceptable, experimental features should be disabled via the Kiro profile settings.
- CloudWatch and CloudTrail logs are always recorded in the **source region** (`eu-central-1`) regardless of which region processes the inference.

### 8.3 Data Residency Summary

| Data Type | Storage Location | Controlled By |
|---|---|---|
| Prompts & responses | `eu-central-1` (S3 + Kiro data store) | Kiro profile region setting |
| Code context (for suggestions) | In-memory; not persisted beyond session | Kiro service |
| Prompt logs | `eu-central-1` (customer S3 bucket) | Admin — prompt logging config |
| User activity telemetry | `eu-central-1` (customer S3 bucket) | Admin — activity report config |
| Subscription metadata | `eu-central-1` | Kiro profile region |
| IAM Identity Center user data | `eu-central-1` | IAM Identity Center region |
| CloudTrail logs | Customer-defined S3 bucket | CloudTrail trail config |

### 8.4 Content and Service Improvement

**Enterprise users are automatically opted out of content collection for service improvement.** AWS does not use prompts, responses, or generated code from enterprise Kiro users to train or improve models.

This is enforced at the profile level and cannot be overridden by individual users. Telemetry settings (user activity reports, prompt logging) remain under administrator control.

---

## 9. Onboarding Steps

### 9.1 Administrator Onboarding (One-Time Setup)

The following five steps describe the complete enterprise onboarding process:

---

**Step 1 — Create or confirm an AWS account**

If your organisation does not already have an AWS account, create one at [aws.amazon.com](https://aws.amazon.com). An existing account may be used. For multi-account organisations, the account chosen will host the IAM Identity Center instance and the Kiro profile.

**Recommended:** Use an AWS Organizations management or delegated administrator account to allow an organisation-level IAM Identity Center instance, which provides centralised identity management across multiple accounts.

---

**Step 2 — Sign in with appropriate permissions**

Sign in to the AWS Management Console. The user configuring Kiro requires either:
- AWS root user access (not recommended for production), or
- An IAM role with the permissions described in Section 5.3 (minimum permissions for Kiro administration)

**Important:** Follow the principle of least privilege. Create a dedicated IAM role for Kiro administration rather than using root or full administrator access.

---

**Step 3 — Enable AWS IAM Identity Center and configure users**

Navigate to **IAM Identity Center** in the AWS Console and enable it in the `eu-central-1` (Frankfurt) region.

Choose your identity source:

| Option | When to use |
|---|---|
| **Built-in Directory** | No existing corporate IdP, or small team |
| **Microsoft Entra ID** | Corporate Microsoft 365 environment |
| **Okta** | Corporate Okta environment |
| **Other SAML 2.0 / OIDC IdP** | Any other supported provider |

If connecting an external IdP, configure SCIM provisioning to synchronise users and groups automatically.

Create or import the following groups (at minimum):
- `kiro-developers` — all Kiro subscribers
- `kiro-admins` — Kiro administrators

Enable MFA for all users in IAM Identity Center.

---

**Step 4 — Create the Kiro profile and subscribe users**

> **⚠️ Important:** Before creating the profile, ensure you are in the **Europe (Frankfurt) — `eu-central-1`** region in the AWS console. The profile region cannot be changed after creation.

Navigate to: **AWS Console → Kiro Console → Sign up for Kiro**

Complete the following profile setup steps:

| Step | Action |
|---|---|
| 4a | Select region: **eu-central-1 (Frankfurt)** |
| 4b | Connect IAM Identity Center instance |
| 4c | Create a Customer Managed KMS Key (see Section 6.2) and provide the ARN |
| 4d | Import users/groups from Identity Center (e.g. `kiro-developers` group) |
| 4e | Subscribe the imported users/groups to Kiro |
| 4f | Configure prompt logging: provide S3 bucket ARN (bucket must be in `eu-central-1`) |
| 4g | Review and save the profile |

AWS automatically creates the two service-linked roles (`AWSServiceRoleForUserSubscriptions` and `AWSServiceRoleForAmazonQDeveloper`) during this step.

---

**Step 5 — Users check email and install Kiro**

Within **24 hours** of being subscribed, each developer receives an email containing:
- Download instructions for the **Kiro IDE** and **Kiro CLI**
- Sign-in instructions, including the IAM Identity Center Start URL and region

**Developer first-time setup:**
1. Download and install the Kiro IDE from the link in the email
2. Open Kiro IDE → select **"Sign in with AWS IAM Identity Center"**
3. Enter the Start URL: `https://d-xxxxxxxxxx.awsapps.com/start`
4. Enter Region: `eu-central-1`
5. Complete the browser-based SSO flow (corporate credentials via Entra / Okta if configured)
6. Kiro is ready to use

---

### 9.2 Onboarding Checklist

**Administrator checklist:**

- [ ] AWS account confirmed / created
- [ ] IAM Identity Center enabled in `eu-central-1`
- [ ] Identity source configured (built-in or external IdP)
- [ ] MFA enforced in IAM Identity Center
- [ ] User groups created: `kiro-developers`, `kiro-admins`
- [ ] KMS Customer Managed Key created in `eu-central-1`
- [ ] S3 bucket for prompt logs created in `eu-central-1` with correct bucket policy
- [ ] Kiro profile created in `eu-central-1` (Frankfurt) — **verify region before creating**
- [ ] CMK ARN entered in Kiro profile encryption settings
- [ ] Prompt logging enabled and S3 bucket ARN provided
- [ ] `kiro-developers` group subscribed to Kiro
- [ ] IAM admin policy attached to `kiro-admins` group
- [ ] CloudTrail trail enabled and logging to S3
- [ ] Firewall / proxy allow-list updated (see Section 7.2)
- [ ] Subscription confirmation email sent (users notified to check within 24 hours)

**Developer checklist (per user):**

- [ ] Invitation email received
- [ ] Kiro IDE downloaded and installed
- [ ] Signed in with IAM Identity Center (Start URL + `eu-central-1`)
- [ ] IAM Identity Center SSO session established
- [ ] Kiro IDE functional — can submit a prompt and receive a response
- [ ] Kiro CLI installed (optional, for terminal usage)

---

## 10. Operations & Monitoring

### 10.1 Subscription Management

Subscription management is performed by Kiro administrators via the **Kiro Console** in the AWS Management Console.

**Common operations:**

| Operation | How |
|---|---|
| Add a new user | Add to `kiro-developers` group in IAM Identity Center; group sync propagates subscription automatically |
| Remove a user | Remove from `kiro-developers` group; subscription updated automatically via `AWSServiceRoleForUserSubscriptions` |
| Change subscription tier | Update in Kiro Console → Subscriptions |
| View all subscribers | Kiro Console → Subscriptions list |
| Revoke access immediately | Remove user from Identity Center or disable account |

### 10.2 Monitoring

**CloudWatch Metrics (AWS/Q namespace):**

| Metric | Description | Action |
|---|---|---|
| Active users | Number of active Kiro users | Capacity and cost planning |
| Requests | Total AI requests per period | Usage trending |
| Errors | Failed requests | Investigate errors |

**CloudTrail Events to Monitor:**

| Event | Significance |
|---|---|
| `q:Subscribe` / `q:Unsubscribe` | User subscription changes |
| `q:CreateProfile` / `q:UpdateProfile` | Profile configuration changes |
| `kms:Decrypt` | KMS key usage (expected; spike may indicate issue) |
| `s3:PutObject` on prompt log bucket | Prompt log writes (confirm logging is active) |
| `sso:*` events | Identity Center changes |

**Recommended CloudWatch Alarms:**

| Alarm | Metric / Condition | Action |
|---|---|---|
| High error rate | Kiro errors > 5% of requests over 15 min | Investigate Kiro service health |
| KMS key disabled | KMS key state change event | Immediate investigation — Kiro will fail |
| S3 prompt log writes stop | No `s3:PutObject` events in 24 hours | Check prompt logging configuration |
| Unexpected subscription changes | CloudTrail `q:Subscribe` from non-admin principal | Security investigation |

### 10.3 User Activity Reports

If enabled in the Kiro profile, Kiro generates daily per-user activity reports exported to an S3 bucket. These reports include:
- Individual user prompt counts
- Feature usage (chat, inline, agents)
- Session durations

**S3 bucket for activity reports:**

| Property | Value |
|---|---|
| **Bucket Name** | `kiro-activity-reports-{account-id}` |
| **Region** | `eu-central-1` |
| **Encryption** | SSE-KMS (`alias/kiro-enterprise-key`) |
| **Versioning** | Enabled |
| **Access** | Restricted to designated analytics / compliance roles |

### 10.4 KMS Key Management

| Task | Frequency | Action |
|---|---|---|
| Key rotation | Annual (automatic if rotation enabled) | Monitor rotation events in CloudTrail |
| Key policy review | Quarterly | Ensure access is still appropriate and least-privilege |
| Key state monitoring | Continuous | CloudWatch alarm on key disable/delete events |
| Key deletion | Only if decommissioning Kiro | Ensure all data is accessible before scheduling deletion |

### 10.5 Ongoing Maintenance

| Task | Frequency | Owner |
|---|---|---|
| Review active subscriptions vs actual users | Monthly | IT Admin |
| Review prompt logs for compliance anomalies | Per compliance schedule | Security / Compliance |
| Update Kiro IDE version guidance to developers | On each new release | IT Admin |
| Review IAM Identity Center user sync | Weekly | IT Admin |
| Review CloudTrail for unexpected Kiro admin actions | Monthly | Security |
| Check S3 prompt log storage costs and lifecycle | Monthly | Cloud Finance |
| Review KMS key policy | Quarterly | Security |

---

## Appendix A — Key References

| Resource | URL |
|---|---|
| Kiro Enterprise Getting Started | https://kiro.dev/docs/enterprise/getting-started/ |
| Kiro Supported Regions | https://kiro.dev/docs/enterprise/supported-regions/ |
| Kiro Data Protection | https://kiro.dev/docs/privacy-and-security/data-protection/ |
| Kiro IAM Configuration | https://kiro.dev/docs/enterprise/iam/ |
| Kiro Authentication Methods | https://kiro.dev/docs/getting-started/authentication/ |
| Kiro Prompt Logging | https://kiro.dev/docs/enterprise/monitor-and-track/prompt-logging/ |
| Kiro Enterprise Settings | https://kiro.dev/docs/enterprise/settings/ |
| Connect IAM Identity Center | https://kiro.dev/docs/enterprise/identity-provider/iam-identity-center/ |
| Subscribe Users to Kiro | https://kiro.dev/docs/enterprise/subscribe/ |
| IAM Identity Center Getting Started | https://docs.aws.amazon.com/singlesignon/latest/userguide/getting-started.html |

## Appendix B — Glossary

| Term | Definition |
|---|---|
| **Kiro Profile** | The AWS management object that ties together identity, subscriptions, region, and security settings for Kiro |
| **IAM Identity Center** | AWS service providing SSO and centralised identity management |
| **CMK** | Customer Managed Key — a KMS key created and managed by the customer |
| **Cross-region inference** | Routing LLM inference requests to different AWS regions for throughput; does not affect data storage location |
| **Prompt Logging** | Admin-controlled feature that writes all developer prompts and Kiro responses to a customer S3 bucket |
| **Service-linked Role** | An IAM role automatically created by AWS and linked directly to a service (e.g. Kiro), not to a user |
| **SCIM** | System for Cross-domain Identity Management — protocol used to sync users/groups from external IdPs |
| **OIDC** | OpenID Connect — authentication protocol used by IAM Identity Center |
| **MCP** | Model Context Protocol — Kiro feature allowing integration with external tools and data sources |
