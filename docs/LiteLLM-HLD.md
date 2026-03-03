# LLMLite Gateway — High Level Design

**Document Version:** 1.0
**Date:** 27 February 2026
**Status:** Approved
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

LLMLite is a secure, enterprise-grade API gateway that provides controlled access to Anthropic Claude large language models (LLMs) hosted on Amazon Bedrock. It is deployed entirely within a single AWS account in the EU (London) region, ensuring data residency compliance.

The solution abstracts the complexity of AWS credential management from end users, replacing it with a simple virtual API key model. All access is governed by per-user rate limits, spend budgets, and model access controls — enforced automatically at the gateway layer.

The architecture is serverless where practical, highly available across two availability zones, and designed for minimal operational overhead.

---

## 2. Business Context

### 2.1 Problem Statement

Teams requiring access to Claude LLMs face two key friction points:

- **Complexity:** Direct AWS Bedrock access requires managing IAM credentials, roles, and region-specific configuration — a burden for most development teams.
- **Governance:** Without a centralised gateway, there is no consistent mechanism to enforce usage limits, track costs per user or team, or audit activity.

### 2.2 Solution Goals

| Goal | How It Is Met |
|---|---|
| Simple user access | Single virtual API key per user — no AWS credential management |
| Cost governance | Per-user and per-team spend budgets enforced at the gateway |
| Usage visibility | All requests logged and tracked; cost attributed to individual keys |
| Security | Multi-layer protection including WAF, network isolation, and encryption |
| Availability | Multi-AZ deployment with automatic failover |
| Compliance | All data remains within EU (London) — eu-west-2 |

### 2.3 Target Users

| User Type | How They Interact |
|---|---|
| **Developers** | Desktop IDEs (Cursor, Continue.dev), scripts, and direct API calls using a virtual key |
| **IT Administrators** | Admin portal and API to manage users, keys, and usage |
| **Business Stakeholders** | Usage dashboards and cost reporting |

---

## 3. Solution Overview

### 3.1 How It Works

LLMLite sits between users and Amazon Bedrock, acting as a controlled gateway. Users are issued a virtual API key by an administrator. They use this key — in the same way they would use an OpenAI API key — to make requests to Claude models. The gateway validates the key, checks limits, and routes the request to Bedrock on the user's behalf.

```
User (IDE / Script / Application)
        │
        │  Virtual API Key
        ▼
  ┌─────────────────────────────┐
  │       LLMLite Gateway       │
  │                             │
  │  • Validate key             │
  │  • Check rate limits        │
  │  • Check spend budget       │
  │  • Log & track usage        │
  └─────────────┬───────────────┘
                │
                ▼
      AWS Bedrock (Claude Models)
```

### 3.2 Supported Models

| Model | Best For |
|---|---|
| **Claude 3.5 Sonnet** | General purpose tasks, code generation, documentation |
| **Claude 3 Opus** | Complex reasoning, high-quality analytical outputs |

### 3.3 API Compatibility

The gateway exposes an **OpenAI-compatible API**. This means existing tools and integrations built for OpenAI (e.g. Cursor, Continue.dev, LangChain) work without code changes — users simply point their tool at the LLMLite endpoint and provide their virtual key.

---

## 4. Architecture Overview

### 4.1 Logical Architecture

The solution is structured in four logical tiers:

```
┌─────────────────────────────────────────────────────────────┐
│                        INTERNET                             │
└───────────────────────────┬─────────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────────┐
│  EDGE PROTECTION TIER                                       │
│  AWS WAF v2 — filters malicious traffic before it          │
│  reaches the application                                    │
└───────────────────────────┬─────────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────────┐
│  PRESENTATION TIER (Public Subnets)                        │
│  Application Load Balancer — HTTPS endpoint,               │
│  SSL termination, traffic distribution                      │
└───────────────────────────┬─────────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────────┐
│  APPLICATION TIER (Private Subnets)                        │
│  LiteLLM Proxy on AWS Fargate — key validation,            │
│  rate limiting, request routing, usage tracking            │
└───────────────────┬───────────────────┬─────────────────────┘
                    │                   │
     ┌──────────────▼──────┐     ┌──────▼──────────────────┐
     │  DATA TIER          │     │  AI MODEL TIER          │
     │  Aurora PostgreSQL  │     │  AWS Bedrock            │
     │  Keys, users,       │     │  Claude 3.5 Sonnet      │
     │  usage & spend      │     │  Claude 3 Opus          │
     └─────────────────────┘     └─────────────────────────┘
```

### 4.2 Deployment Architecture

The solution is deployed in a single AWS account in **eu-west-2 (London)**, across **two availability zones** for resilience.

| Tier | Technology | Deployment |
|---|---|---|
| Edge Protection | AWS WAF v2 | Regional — associated with ALB |
| Load Balancing | Application Load Balancer | Public subnets — AZ 2a & 2b |
| Application | LiteLLM on AWS Fargate (ECS) | Private subnets — AZ 2a & 2b |
| Database | Aurora PostgreSQL Serverless v2 | Database subnets — AZ 2a & 2b |
| AI Models | AWS Bedrock | eu-west-2 (managed service) |

### 4.3 Network Segmentation

The VPC is divided into three isolated tiers, following defence-in-depth principles:

| Tier | Internet Access | Purpose |
|---|---|---|
| **Public Subnets** | Yes (via Internet Gateway) | Load balancer only |
| **Private Subnets** | Outbound only (via NAT Gateway) | Application containers |
| **Database Subnets** | None | Database — fully isolated |

No component in the database tier can be reached from the internet, directly or indirectly.

### 4.4 Request Flow (Summary)

A typical user request follows this path:

1. **User** sends an HTTPS request with their virtual API key
2. **AWS WAF** inspects the request — blocks malicious traffic, SQL injection, known exploits, and IP-based rate abuse
3. **Load Balancer** terminates SSL and routes to an available application container
4. **LiteLLM Gateway** validates the key, checks rate limits and budget, then forwards the request to Bedrock
5. **Amazon Bedrock** processes the prompt and returns the Claude model response
6. **LiteLLM Gateway** records usage and cost, then returns the response to the user

End-to-end, this typically completes in 2–5 seconds, dominated by model inference time.

---

## 5. Key Components

### 5.1 AWS WAF v2 — Edge Protection

AWS WAF sits in front of the load balancer and inspects every inbound request before it reaches the application. It provides protection against:

- **OWASP Top 10 threats** — SQL injection, cross-site scripting, and other common web exploits
- **Known malicious actors** — using AWS-managed IP reputation lists
- **Exploit signatures** — known bad input patterns
- **Volume-based abuse** — rate limiting at the IP level (2,000 requests per 5 minutes)

Any request matching these rules is blocked at the edge, before consuming application or database resources.

### 5.2 LiteLLM Proxy — Application Gateway

The core of the solution. LiteLLM is an open-source proxy server that provides:

- **Authentication** — validates virtual API keys against the database on every request
- **Policy enforcement** — checks rate limits (tokens per minute, requests per minute) and spend budgets
- **Model routing** — translates OpenAI-format requests to AWS Bedrock format transparently
- **Usage tracking** — records every request, token count, and cost to the database
- **OpenAI compatibility** — existing tools work without modification

It runs as containerised workloads on **AWS Fargate** (serverless containers), scaling automatically between 2 and 5 instances based on CPU load. There are no servers to manage.

### 5.3 Aurora PostgreSQL — Data Store

All persistent state is stored in a fully managed Aurora PostgreSQL Serverless v2 database:

- **Virtual keys** — key metadata, limits, and status
- **Users** — profiles and team assignments
- **Usage records** — per-request spend and token consumption
- **Configuration** — gateway settings

Aurora Serverless v2 scales database capacity automatically with demand, and Multi-AZ deployment provides automatic failover with no data loss.

### 5.4 Amazon Bedrock — AI Models

AWS Bedrock provides fully managed access to Anthropic Claude models without requiring model infrastructure management. Models are invoked via the Fargate application using AWS IAM role-based credentials — end users never interact with Bedrock directly.

### 5.5 Supporting Services

| Service | Role |
|---|---|
| **Application Load Balancer** | HTTPS endpoint, SSL/TLS termination, health-based routing |
| **AWS Certificate Manager** | Manages and auto-renews the SSL certificate |
| **Amazon CloudWatch** | Logs, metrics, dashboards, and alerting |
| **AWS KMS** | Encryption key management for data at rest |
| **Amazon S3** | Long-term audit log and WAF log archive |
| **AWS Secrets Manager** | Secure storage of database credentials |

---

## 6. Security & Compliance

### 6.1 Security Layers

Security is applied in depth across six layers:

| Layer | Controls |
|---|---|
| **Edge** | AWS WAF — OWASP rules, IP reputation, rate limiting |
| **Transport** | TLS 1.3 end-to-end; HTTPS-only (HTTP redirects enforced) |
| **Network** | VPC isolation; private subnets; security groups on least-privilege principles; database with no internet path |
| **Authentication** | Virtual key validation on every request; keys are revocable and have configurable expiry |
| **Application** | Per-key rate limits and spend budgets; model access control; PII detection |
| **Data** | Encryption at rest (KMS) for database, S3, and logs; automated backups; audit trail |

### 6.2 Access Control Model

| Role | Access |
|---|---|
| **End User** | Virtual key — can only call permitted models within their rate and budget limits |
| **IT Administrator** | Master key — can create, revoke, and manage virtual keys; access to admin portal |
| **AWS Services** | IAM roles with least-privilege policies; no human access to underlying infrastructure |

### 6.3 Compliance Posture

| Requirement | Implementation |
|---|---|
| **Data Residency** | All data stored and processed in eu-west-2 (London). No cross-border transfers. |
| **Audit Logging** | All API requests logged to CloudWatch and archived to S3. WAF activity logged separately. |
| **Encryption** | All data encrypted at rest (KMS) and in transit (TLS 1.3). |
| **Key Management** | AWS KMS with annual automatic rotation. |
| **Access Audit** | AWS CloudTrail records all AWS API calls. Per-key usage tracked in PostgreSQL. |
| **Data Retention** | Audit logs retained for 90 days active, then archived to S3 Glacier for 7 years. |
| **GDPR** | Key deletion removes all associated user data from the database. PII detection available. |

---

## 7. Availability & Resilience

### 7.1 Availability Design

| Component | HA Mechanism | Recovery Time |
|---|---|---|
| **Application (Fargate)** | Minimum 2 tasks across 2 AZs; auto-scaling; ALB health checks replace failed tasks | < 60 seconds |
| **Database (Aurora)** | Multi-AZ with synchronous replication; automatic failover | 30–60 seconds (DNS failover) |
| **Load Balancer** | Deployed across 2 AZs natively | Transparent |
| **WAF** | Regional service — AWS managed availability | Transparent |

### 7.2 Backup & Recovery

| Asset | Backup Method | Retention | RTO |
|---|---|---|---|
| **Aurora Database** | Automated daily backups + point-in-time recovery | 7 days | 15–30 minutes |
| **Infrastructure** | Terraform state in versioned S3 bucket | Indefinite | 2–4 hours (full rebuild) |
| **Audit Logs** | S3 with versioning | 7 years | Immediate |

### 7.3 Disaster Recovery Scenario

In the event of an availability zone failure:

- The **load balancer** automatically routes traffic to the healthy AZ
- **Fargate** auto-scaling replaces any lost tasks in the remaining AZ
- **Aurora** automatically promotes the standby instance (30–60 seconds)
- No manual intervention is required for AZ-level failures

---

## 8. Operational Model

### 8.1 Ongoing Operations Summary

| Activity | Frequency | Effort |
|---|---|---|
| Health & error log review | Daily | Low — dashboard review |
| Cost and usage reporting | Weekly | Low — automated queries |
| Key management (add/revoke users) | As needed | Low — API or portal |
| LiteLLM container patching | Monthly | Low — rolling deployment |
| WAF rule review | Monthly | Low — metrics review |
| Database performance review | Monthly | Low — Performance Insights |
| Security & IAM audit | Quarterly | Medium |
| DR test | Quarterly | Medium |

### 8.2 Monitoring & Alerting

Key automated alerts are configured for:

- **Critical:** Unhealthy application targets; high 5xx error rate; RDS backup failure
- **High:** High response latency (>3s p95); RDS high CPU or low storage; high WAF block rate
- **Medium:** High authentication failure rate; database connection saturation; replication lag

All alerts feed into **CloudWatch Dashboards** for real-time visibility across application, database, and WAF layers.

### 8.3 User Onboarding

Onboarding a new user is a two-step API process (or via the admin portal):

1. Create user account — assigns them to a team and inherits team-level model access and budget
2. Generate invitation link — user sets their password and receives their virtual key

Bulk onboarding is supported via CSV upload or scripted API calls.

---

## 9. Key Risks & Considerations

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| **Aurora deletion protection disabled** | Low | High | ⚠️ Enable deletion protection in production immediately |
| **VPC CIDR range** | Low | Medium | ⚠️ Database subnets (`10.1.21.x`, `10.1.22.x`) fall outside the declared `/20` range — confirm addressing or expand VPC to `/16` before deployment |
| **Single AWS account** | Low | High | All resources share one account — consider account-level separation for production vs non-production environments |
| **WAF false positives** | Low | Medium | New WAF rules should be deployed in Count mode before Block mode; review regularly |
| **LiteLLM open source dependency** | Medium | Medium | Monitor releases; container patching is a monthly operational task; pin to tested versions |
| **Bedrock model availability** | Low | High | Claude models must be explicitly enabled in eu-west-2 via AWS Console before deployment |
| **Cost overrun** | Medium | Medium | Per-key budgets enforced at gateway; CloudWatch alarms on spend; weekly reporting recommended |

---

*Document Version: 1.0*
*Last Updated: 27 February 2026*
*Next Review: 27 March 2026*
*Classification: Internal — AI Engineering Lab (AIEL) / DSIT*
