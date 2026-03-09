# Kiro Enterprise IDE — High-Level Design

**Document Version:** 1.0
**Date:** 2026-03-09
**Status:** Draft for Review
**Target Audience:** Technology & Business Architects

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Business Context](#2-business-context)
3. [Solution Overview](#3-solution-overview)
4. [Architecture Overview](#4-architecture-overview)
5. [Key Components](#5-key-components)
6. [Security & Compliance](#6-security--compliance)
7. [Availability & Resilience](#7-availability--resilience)
8. [Operational Model](#8-operational-model)
9. [Key Risks & Considerations](#9-key-risks--considerations)

---

## 1. Executive Summary

Kiro Enterprise is a secure, governed AI-powered IDE developed by AWS that provides development teams with AI-assisted coding capabilities, including spec-driven development, inline code suggestions, autonomous agents, and chat-based interactions. It is built on VS Code OSS and powered by Amazon Bedrock (Claude models).

The solution integrates with existing corporate identity infrastructure via AWS IAM Identity Center, supporting external identity providers such as Microsoft Entra ID and Okta. The Kiro profile is hosted in the **Europe (Frankfurt) — eu-central-1** region, ensuring all data storage and LLM inference remains within Europe to satisfy GDPR and organisational data residency requirements.

Administrators manage subscriptions, security policies, and audit configuration through the Kiro Console. Developers access Kiro through the Kiro IDE (desktop) or Kiro CLI, authenticating with their existing corporate credentials via SSO.

---

## 2. Business Context

### 2.1 Problem Statement

Development teams requiring AI coding assistance face two key challenges:

- **Governance:** Without an enterprise-managed deployment, there is no consistent mechanism to control data residency, enforce security policies, audit developer interactions, or integrate with corporate identity systems.
- **Compliance:** Unmanaged AI tools used by developers may process and store code and prompts outside of approved geographies, creating GDPR and data residency risk.

### 2.2 Solution Goals

| Goal | How It Is Met |
|---|---|
| Simple developer access | Corporate SSO via IAM Identity Center — no separate credentials |
| Data residency | Kiro profile and all data storage hosted in eu-central-1 (Frankfurt) |
| Security & auditability | Prompt logging to S3, CloudTrail audit, Customer Managed KMS encryption |
| Identity integration | Connects to existing Microsoft Entra ID or Okta via SAML/SCIM |
| Centralised management | Admin-controlled subscriptions, policies, and security settings via Kiro Console |
| Compliance | Enterprise users automatically opted out of content used for model training |

### 2.3 Target Users

| User Type | How They Interact |
|---|---|
| **Developers** | Kiro IDE (desktop) or Kiro CLI — AI coding assistance, chat, and agentic tasks |
| **IT Administrators** | Kiro Console (AWS Management Console) — user subscriptions, security policy, monitoring |
| **Security & Compliance Teams** | S3 prompt logs, CloudTrail, CloudWatch — audit and compliance reporting |

---

## 3. Solution Overview

### 3.1 How It Works

Kiro Enterprise sits between the developer and Amazon Bedrock, providing a governed and audited AI coding experience. Developers authenticate using their corporate identity via SSO. The Kiro service validates their subscription, routes requests to Claude models on Bedrock, and logs all interactions for audit purposes.

```
Developer (Kiro IDE / Kiro CLI)
        │
        │  Corporate SSO (IAM Identity Center)
        ▼
  ┌─────────────────────────────┐
  │      Kiro Enterprise        │
  │                             │
  │  • Validate identity        │
  │  • Check subscription       │
  │  • Route to Bedrock         │
  │  • Log interactions to S3   │
  └─────────────┬───────────────┘
                │
                ▼
      AWS Bedrock (Claude Models)
      eu-central-1 (Frankfurt)
```

### 3.2 Supported Capabilities

| Capability | Description |
|---|---|
| **Inline Suggestions** | Real-time AI code completions as developers type |
| **Chat / Vibe Mode** | Conversational AI coding assistant within the IDE |
| **Spec-Driven Development** | AI generates implementation plans and code from written specifications |
| **Autonomous Agents** | Agentic tasks that can read, write, and modify code across a project |
| **Kiro CLI** | Terminal-based access to Kiro capabilities outside the IDE |

### 3.3 Underlying AI Models

Kiro is powered by **Amazon Bedrock** using **Claude** (Anthropic) models. Model selection and routing is managed automatically by the Kiro service — developers do not interact with Bedrock directly.

---

## 4. Architecture Overview

### 4.1 Logical Architecture

The solution is structured in four logical tiers:

```
┌──────────────────────────────────────────────────────────────┐
│                     DEVELOPER TIER                           │
│  Kiro IDE (VS Code–based desktop app) / Kiro CLI            │
│  Developer workstations — macOS, Windows, or Linux          │
└───────────────────────────┬──────────────────────────────────┘
                            │  HTTPS (TLS 1.2+)
┌───────────────────────────▼──────────────────────────────────┐
│                    IDENTITY TIER                             │
│  AWS IAM Identity Center (eu-central-1)                     │
│  SSO authentication — integrates with Entra ID / Okta       │
└───────────────────────────┬──────────────────────────────────┘
                            │  OIDC token
┌───────────────────────────▼──────────────────────────────────┐
│                   APPLICATION TIER                           │
│  Kiro Service (eu-central-1)                                │
│  Subscription validation, request routing, prompt logging   │
└──────────────┬────────────────────────┬──────────────────────┘
               │                        │
┌──────────────▼──────────┐  ┌──────────▼───────────────────────┐
│      AI MODEL TIER      │  │         AUDIT TIER               │
│  AWS Bedrock            │  │  Amazon S3 — prompt logs         │
│  Claude models          │  │  CloudWatch — metrics            │
│  (eu-central-1 +        │  │  CloudTrail — API audit          │
│   cross-region EU)      │  │  AWS KMS — encryption            │
└─────────────────────────┘  └──────────────────────────────────┘
```

### 4.2 Deployment Architecture

The solution is deployed as a **fully managed SaaS service** by AWS. There is no Kiro infrastructure deployed into the customer's VPC. The Kiro profile is hosted in **eu-central-1 (Frankfurt)**.

| Tier | Technology | Deployment |
|---|---|---|
| Developer Client | Kiro IDE / Kiro CLI | Customer workstations (no server-side deployment) |
| Authentication | AWS IAM Identity Center | eu-central-1 — managed service |
| Identity Source | Built-in Directory / Entra ID / Okta | Customer-managed or cloud IdP |
| Kiro Service | AWS-managed SaaS | eu-central-1 |
| AI Models | AWS Bedrock (Claude) | eu-central-1 + cross-region EU inference |
| Encryption | AWS KMS — Customer Managed Key | eu-central-1 |
| Prompt Logs | Amazon S3 | eu-central-1 — customer-owned bucket |
| Audit | AWS CloudTrail, CloudWatch | Customer AWS account |

### 4.3 Authentication Flow (Summary)

A typical developer sign-in follows this path:

1. **Developer** opens Kiro IDE and selects "Sign in with AWS IAM Identity Center"
2. **Kiro IDE** launches a browser and redirects to the IAM Identity Center SSO portal
3. **Developer** authenticates — credentials may be validated against an external IdP (Entra ID / Okta) via SAML
4. **IAM Identity Center** confirms the user is active and has a Kiro subscription, then issues an OIDC token
5. **Kiro IDE** receives the token and establishes an authenticated session with the Kiro service
6. **Kiro service** routes requests to Amazon Bedrock and logs interactions to S3

---

## 5. Key Components

### 5.1 Kiro IDE & CLI — Developer Clients

The Kiro IDE is a desktop application built on VS Code OSS, providing a familiar development environment with AI capabilities embedded throughout. The Kiro CLI provides the same AI capabilities in a terminal context, suitable for scripted workflows and developers who prefer command-line tooling.

Both clients authenticate via IAM Identity Center using a browser-based SSO flow, with no separate password or credential management required.

### 5.2 AWS IAM Identity Center — Identity & Access

IAM Identity Center is the exclusive authentication mechanism for Kiro Enterprise. It provides SSO for all developer access and integrates with existing corporate identity providers via SAML 2.0 and SCIM, enabling automatic user and group synchronisation from Entra ID or Okta.

Group membership in the corporate IdP controls Kiro access and subscription tier — no separate provisioning step is required when onboarding or offboarding users.

### 5.3 Kiro Service — Application Gateway

The Kiro service is the AWS-managed backend that orchestrates all developer interactions. It validates developer identity and subscription status, routes AI requests to the appropriate Claude model on Bedrock, enforces administrator-defined policies (such as code reference controls and web tool access), and writes prompt logs to the customer's S3 bucket for audit purposes.

### 5.4 Amazon Bedrock — AI Models

AWS Bedrock provides fully managed access to Anthropic Claude models. Model selection and routing is handled automatically by the Kiro service based on the task type — inline suggestions, chat, or agentic tasks. Developers do not interact with Bedrock directly, and no Bedrock credentials are required by end users.

### 5.5 Kiro Console — Administration

The Kiro Console, accessible via the AWS Management Console, is the central administration interface. Administrators use it to manage user and group subscriptions, configure the Customer Managed KMS key, enable and configure prompt logging, control access to features such as web tools and code references, and view usage reporting.

### 5.6 Supporting Services

| Service | Role |
|---|---|
| **AWS KMS** | Customer Managed Key for encryption at rest of all Kiro-held data |
| **Amazon S3** | Customer-owned bucket for prompt logs and user activity reports |
| **AWS CloudTrail** | API-level audit of all Kiro console, IAM, KMS, and S3 operations |
| **Amazon CloudWatch** | Kiro usage metrics (AWS/Q namespace), alarms, and dashboards |

---

## 6. Security & Compliance

### 6.1 Security Layers

Security is applied in depth across four layers:

| Layer | Controls |
|---|---|
| **Identity & Access** | IAM Identity Center SSO; external IdP integration (Entra ID / Okta); group-based subscription control; MFA enforced; configurable session timeout (default 8 hours) |
| **Data Protection** | All data stored in eu-central-1; Customer Managed KMS key (AES-256); TLS 1.2+ in transit; enterprise users automatically opted out of service improvement |
| **Audit & Monitoring** | Prompt logging to KMS-encrypted S3 bucket; user activity reports; CloudTrail API audit; CloudWatch metrics |
| **Network** | Fully managed SaaS — no VPC deployment; outbound HTTPS only; corporate proxy / firewall allow-list required |

### 6.2 Access Control Model

| Role | Access |
|---|---|
| **Developer** | Authenticated via corporate SSO; can use Kiro capabilities within their subscription tier |
| **Kiro Administrator** | Manages subscriptions, policies, encryption, and logging via Kiro Console; requires dedicated IAM role with least-privilege permissions |
| **Kiro Service** | Accesses Bedrock and S3 via AWS service-linked roles — no human access to underlying infrastructure |

### 6.3 Compliance Posture

| Requirement | Implementation |
|---|---|
| **Data Residency** | Kiro profile region set to eu-central-1 — all data storage and inference within Europe |
| **GDPR** | Enterprise users automatically opted out of content collection for model training; data remains within EU |
| **Encryption at Rest** | Customer Managed KMS Key (AES-256) applied to all Kiro-held data |
| **Encryption in Transit** | TLS 1.2+ for all client-to-service and service-to-service communication |
| **Audit Logging** | All developer interactions logged to customer S3 bucket; AWS API calls captured in CloudTrail |
| **Data Retention** | S3 prompt log lifecycle policy — recommended 7-year retention for compliance |
| **No Model Training** | AWS does not use prompts, responses, or generated code from enterprise users to train or improve models |

---

## 7. Availability & Resilience

### 7.1 Availability Design

Kiro is a fully managed AWS SaaS service. AWS is responsible for the availability of the Kiro service and Amazon Bedrock. Customer responsibility is limited to the availability of their IAM Identity Center instance, S3 prompt log bucket, and KMS key.

| Component | Availability Responsibility | Notes |
|---|---|---|
| **Kiro Service** | AWS | Managed SaaS — AWS SLA applies |
| **Amazon Bedrock** | AWS | Managed service — cross-region EU inference for resilience |
| **IAM Identity Center** | AWS | Managed service in eu-central-1 |
| **S3 Prompt Log Bucket** | Customer | Standard S3 durability (11 nines) |
| **KMS Customer Managed Key** | Customer | Key must remain enabled — disabling will prevent Kiro from functioning |

### 7.2 Cross-Region Inference

Kiro uses Amazon Bedrock cross-region inference to improve throughput and resilience for model requests. Importantly, cross-region inference does not change where data is stored — all data remains in the Kiro profile region (eu-central-1). For non-experimental model features, inference traffic remains within European AWS regions.

### 7.3 Key Dependency — KMS Key

The Customer Managed KMS key is a critical dependency. If the key is disabled or deleted, the Kiro service will be unable to encrypt or decrypt data, and the service will stop functioning. CloudWatch alarms on KMS key state changes are strongly recommended.

---

## 8. Operational Model

### 8.1 Ongoing Operations Summary

| Activity | Frequency | Effort |
|---|---|---|
| Review active subscriptions vs actual users | Monthly | Low |
| Review prompt logs for compliance anomalies | Per compliance schedule | Medium |
| Review CloudTrail for unexpected admin actions | Monthly | Low |
| IAM Identity Center user sync review | Weekly | Low |
| Kiro IDE version guidance to developers | On each new release | Low |
| KMS key policy review | Quarterly | Low |
| S3 prompt log storage costs and lifecycle review | Monthly | Low |
| CloudWatch metrics and alarm review | Weekly | Low |

### 8.2 Monitoring & Alerting

Key automated alerts should be configured for:

- **Critical:** KMS key disabled or deleted; IAM Identity Center instance unavailable
- **High:** High Kiro error rate (>5% of requests over 15 minutes); unexpected subscription changes from non-admin principals
- **Medium:** S3 prompt log writes stop (logging configuration failure); spike in KMS decrypt calls

All alerts should feed into CloudWatch Dashboards for real-time visibility across identity, usage, and audit layers.

### 8.3 User Onboarding

Onboarding a new developer is handled through group membership in the corporate IdP:

1. Administrator adds the developer to the `kiro-developers` group in Entra ID / Okta
2. SCIM synchronisation propagates the group membership to IAM Identity Center automatically
3. Kiro subscription is assigned to the user within 24 hours; the developer receives an email with download and sign-in instructions
4. Developer installs Kiro IDE, enters the IAM Identity Center Start URL and region, and completes the browser-based SSO flow

Offboarding follows the same process in reverse — removing the developer from the group revokes their Kiro access automatically.

---

## 9. Key Risks & Considerations

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| **KMS key disabled or deleted** | Low | High | ⚠️ Enable CloudWatch alarm on KMS key state changes; establish key management runbook before go-live |
| **IAM Identity Center instance type** | Low | High | ⚠️ Organisation-level instance must be created as such from the outset — cannot be upgraded from an account-level instance without deletion and recreation |
| **Kiro profile region immutable** | Low | High | ⚠️ Profile region cannot be changed after creation — confirm eu-central-1 before creating the profile |
| **Experimental model features** | Low | Medium | Experimental features may route inference globally — disable via profile settings if cross-region inference outside Europe is unacceptable |
| **Corporate proxy / firewall** | Medium | Medium | Allow-list for Kiro, Bedrock, IAM Identity Center, KMS, and S3 endpoints must be configured before developer rollout |
| **External IdP SCIM sync latency** | Low | Low | Group membership changes may take minutes to propagate; plan for this in offboarding procedures where immediate access revocation is required |
| **Bedrock model availability** | Low | High | Claude models must be explicitly enabled in eu-central-1 via the AWS Console before deployment |
| **S3 prompt log storage costs** | Medium | Low | Apply lifecycle policy to transition logs to S3 Glacier after active retention period; review monthly |

---

*Document Version: 1.0*
*Last Updated: 2026-03-09*
*Next Review: 2026-04-09*
*Classification: Internal*
