# LLMLite Gateway Service Low-Level Design Document
## LLM Gateway using LiteLLM Virtual Keys Authentication with Amazon Bedrock Integration

**Document Version:** 1.2
**Date:** 2026-02-23
**Status:** Approved for Implementation
**Target Audience:** Infrastructure Team, DevOps Engineers, Cloud Architects

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [System Overview](#2-system-overview)
3. [Architecture Design](#3-architecture-design)
4. [Component Specifications](#4-component-specifications)
5. [Network Design](#5-network-design)
6. [Security Design](#6-security-design)
7. [Operations and Maintenance](#7-operations-and-maintenance)
8. [Monitoring and Alerting](#8-monitoring-and-alerting)

---

## 1. Executive Summary

### 1.1 Project Overview

**LLMLite** is a secure API gateway that provides users with controlled access to Large Language Models (LLMs) available in Amazon Bedrock. The system leverages LiteLLM virtual keys for simple, secure authentication, with key storage in Amazon RDS PostgreSQL for reliability and ACID compliance.

**Access Methods:**
- **Desktop IDEs** (Cursor, Continue.dev, Claude Desktop) - Virtual key authentication
- **Programmatic Access** (Python, Node.js, scripts) - Virtual key authentication
- **Direct API calls** - Virtual key in Authorization header

### 1.2 Key Features

- ✅ **Simple Authentication** - LiteLLM user generated virtual keys (no AWS credential management)
- ✅ **Claude Model Access** - Claude 3.5 Sonnet and Claude 3 Opus via Amazon Bedrock
- ✅ **Enterprise Security** - API key rotation, rate limiting, audit logging
- ✅ **Web Application Firewall** - AWS WAF v2 protecting the ALB against common web exploits
- ✅ **Relational Database** - PostgreSQL on RDS for ACID compliance and data integrity
- ✅ **Rate Limiting** - Per-key rate limits (100 req/hr standard, 1000 req/hr admin)
- ✅ **Content Filtering** - PII detection and blocking
- ✅ **Cost Tracking** - Per-user cost monitoring and reporting
- ✅ **High Availability** - Multi-AZ RDS and Fargate deployment
- ✅ **Single Account** - All infrastructure contained in one AWS account


### 1.3 Technology Stack

| Layer | Technology | Purpose |
|-------|------------|---------|
| **Authentication** | LiteLLM Virtual Keys | Simple API key-based authentication |
| **WAF** | AWS WAF v2 | Web application firewall, DDoS and exploit protection |
| **Compute** | AWS Fargate (ECS) | Serverless container hosting |
| **Proxy** | LiteLLM Proxy | OpenAI-compatible API gateway |
| **Load Balancing** | Application Load Balancer | HTTPS endpoint, SSL termination |
| **AI Models** | Amazon Bedrock | Claude 3.5 Sonnet, Claude 3 Opus |
| **Database** | Amazon RDS PostgreSQL | Virtual key and user metadata storage |
| **Storage** | Amazon S3 | Audit logs, cost tracking data |
| **Logging** | CloudWatch Logs | Application and system logs |
| **Monitoring** | CloudWatch Metrics | Performance and health metrics |
| **Encryption** | AWS KMS | Data encryption at rest |
| **Networking** | Amazon VPC | Network isolation and security |

---

## 2. System Overview

### 2.1 Business Context

**Problem:** Users need secure, controlled access to Claude LLMs for business applications without complex AWS credential management.

**Solution:** LiteLLM proxy gateway that validates virtual API keys, enforces rate limits, filters content, and routes to Bedrock Claude models. AWS WAF provides an additional layer of protection at the edge. PostgreSQL provides reliable, transactional storage for key management.

**Benefits:**
- Simple authentication: Single API key for all access
- No AWS credential management required
- WAF protection against OWASP Top 10 and common API threats
- ACID-compliant database for data integrity
- Fast deployment: 1-2 days to production
- Minimal operational overhead
- OpenAI-compatible API for easy integration
- Relational database for complex queries and reporting

### 2.2 System Context Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        EXTERNAL ACTORS                          │
│                                                                 │
│  ┌──────────────┐        ┌──────────────┐                     │
│  │   End User   │        │    Admin     │                     │
│  │ (Developer)  │        │  (IT Staff)  │                     │
│  └──────┬───────┘        └──────┬───────┘                     │
│         │                       │                              │
└─────────┼───────────────────────┼──────────────────────────────┘
          │                       │
          │ Virtual Key           │ Admin Key / AWS Console
          │                       │
┌─────────▼───────────────────────▼──────────────────────────────┐
│                      LLMLITE SYSTEM                             │
│              (Single AWS Account - eu-west-2)                   │
│  ┌────────────────────────────────────────────────────────┐   │
│  │         AWS WAF v2                                     │   │
│  │  • OWASP Top 10 Managed Rules                          │   │
│  │  • Rate-based Rules  • IP Reputation Lists            │   │
│  │  • Geo Blocking (optional)                            │   │
│  └────────────────────┬───────────────────────────────────┘   │
│                       │                                         │
│  ┌────────────────────▼───────────────────────────────────┐   │
│  │         Application Load Balancer                      │   │
│  │  • HTTPS Endpoint  • SSL/TLS Termination              │   │
│  └────────────────────┬───────────────────────────────────┘   │
│                       │                                         │
│  ┌────────────────────▼───────────────────────────────────┐   │
│  │         LiteLLM Proxy (Fargate Containers)             │   │
│  │  • Virtual Key Validation  • Rate Limiting             │   │
│  │  • PII Filtering  • Request Routing                    │   │
│  │  • Logging  • Cost Tracking  • Monitoring              │   │
│  └───────────┬────────────────────┬───────────────────────┘   │
│              │                    │                             │
│              │                    ▼                             │
│              │          ┌─────────────────────┐                │
│              │          │   RDS PostgreSQL    │                │
│              │          │  • Virtual Keys     │                │
│              │          │  • User Metadata    │                │
│              │          │  • Rate Limit Data  │                │
│              │          │  • Usage Metrics    │                │
│              │          │  • Multi-AZ HA      │                │
│              │          └─────────────────────┘                │
│              │                                                  │
│              ▼                                                  │
│  ┌────────────────────────────────────────────────────────┐   │
│  │         AWS Bedrock - Claude Models                    │   │
│  │  • Claude 3.5 Sonnet  • Claude 3 Opus                 │   │
│  └────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌────────────────────────────────────────────────────────┐   │
│  │    Supporting Services                                 │   │
│  │  • S3 (logs)  • CloudWatch  • KMS  • VPC              │   │
│  └────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

### 2.3 Dataflow Diagram

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                          LLMLITE DATAFLOW DIAGRAM                            │
│                     (Request Processing & Data Movement)                     │
└──────────────────────────────────────────────────────────────────────────────┘

FLOW 1: USER REQUEST (Chat Completion)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

┌──────────────┐
│  User Client │  (IDE, Script, Application)
└──────┬───────┘
       │ [1] HTTPS POST /v1/chat/completions
       │     Headers: Authorization: Bearer sk-xxx
       │     Body: { model, messages, max_tokens, ... }
       │     TLS 1.3 Encrypted
       ▼
┌────────────────────────────────────────────────────────┐
│  AWS WAF v2 (Associated with ALB)                      │
│  • Inspect incoming request against rule groups        │
│  • AWS Managed Rules: OWASP Top 10, Known Bad Inputs  │
│  • Rate-based rules: Block IPs exceeding threshold    │
│  • IP Reputation List: Block known malicious IPs      │
│  • Allow / Block / Count decision                     │
└────────────────────┬───────────────────────────────────┘
                     │ [1b] Request allowed by WAF
                     ▼
┌────────────────────────────────────────────────────────┐
│  Application Load Balancer (10.1.1.10, 10.1.2.10)     │
│  • Terminates SSL/TLS                                  │
│  • Validates certificate                               │
│  • Performs health checks                              │
└────────────────────┬───────────────────────────────────┘
                     │ [2] HTTP Forwarding (internal)
                     │     Destination: Fargate Task IP:4000
                     │     Load balances across tasks
                     ▼
┌──────────────────────────────────────────────────────────────┐
│  LiteLLM Proxy (Fargate Task - 10.1.11.10, 10.1.12.10)      │
│  ┌────────────────────────────────────────────────────────┐  │
│  │ [3] Extract Virtual Key                               │  │
│  │     • Parse Authorization header                      │  │
│  │     • Extract token: sk-xxx                           │  │
│  └────────────────────────────────────────────────────────┘  │
└────────────────────┬─────────────────────────────────────────┘
                     │ [4] Database Query
                     │     SELECT * FROM litellm_verificationtoken
                     │     WHERE token = 'sk-xxx' AND is_active = true
                     ▼
┌──────────────────────────────────────────────────────────────┐
│  RDS PostgreSQL (10.1.21.10 primary / 10.1.22.10 standby)   │
│  ┌────────────────────────────────────────────────────────┐  │
│  │ [5] Key Validation Data Returned                      │  │
│  │     {                                                  │  │
│  │       user_id: "john.doe@company.com",                │  │
│  │       tpm_limit: 10000,                               │  │
│  │       rpm_limit: 100,                                 │  │
│  │       max_budget: 50.00,                              │  │
│  │       allowed_models: ["claude-3-5-sonnet"],          │  │
│  │       current_usage: {...}                            │  │
│  │     }                                                  │  │
│  └────────────────────────────────────────────────────────┘  │
└────────────────────┬─────────────────────────────────────────┘
                     │ [6] Validation Response
                     ▼
┌──────────────────────────────────────────────────────────────┐
│  LiteLLM Proxy - Policy Enforcement                         │
│  ┌────────────────────────────────────────────────────────┐  │
│  │ [7] Check Rate Limits                                  │  │
│  │     • TPM: 5,000 / 10,000 (OK)                        │  │
│  │     • RPM: 45 / 100 (OK)                              │  │
│  │     • Budget: $23.50 / $50.00 (OK)                    │  │
│  │                                                        │  │
│  │ [8] Content Filtering                                 │  │
│  │     • Scan for PII patterns                           │  │
│  │     • No PII detected → PASS                          │  │
│  │                                                        │  │
│  │ [9] Model Authorization                               │  │
│  │     • Requested: claude-3-5-sonnet                    │  │
│  │     • Allowed models check → AUTHORIZED               │  │
│  └────────────────────────────────────────────────────────┘  │
└────────────────────┬─────────────────────────────────────────┘
                     │ [10] Request Approved - Forward to Bedrock
                     │      Translate OpenAI format → Bedrock format
                     │      Add AWS IAM credentials
                     ▼
┌──────────────────────────────────────────────────────────────┐
│  NAT Gateway (10.1.1.20 or 10.1.2.20)                       │
│  • Translates private IP to public IP                        │
│  • Routes to internet gateway                                │
└────────────────────┬─────────────────────────────────────────┘
                     │ [11] HTTPS to Bedrock API
                     │      POST bedrock-runtime.eu-west-2.amazonaws.com
                     ▼
┌──────────────────────────────────────────────────────────────┐
│  AWS Bedrock (eu-west-2)                                     │
│  ┌────────────────────────────────────────────────────────┐  │
│  │ [12] Claude Model Inference                            │  │
│  │     • Model: claude-3-5-sonnet-20241022-v2:0          │  │
│  │     • Process prompt tokens: 150                       │  │
│  │     • Generate completion tokens: 300                  │  │
│  │     • Inference time: ~2-5 seconds                     │  │
│  └────────────────────────────────────────────────────────┘  │
└────────────────────┬─────────────────────────────────────────┘
                     │ [13] Model Response
                     │      { content, usage: { input_tokens, output_tokens } }
                     ▼
┌──────────────────────────────────────────────────────────────┐
│  LiteLLM Proxy - Response Processing                        │
│  ┌────────────────────────────────────────────────────────┐  │
│  │ [14] Calculate Cost                                    │  │
│  │     • Input: 150 tokens × $3/1M = $0.00045            │  │
│  │     • Output: 300 tokens × $15/1M = $0.00450          │  │
│  │     • Total: $0.00495                                 │  │
│  │                                                        │  │
│  │ [15] Translate Response                               │  │
│  │     • Bedrock format → OpenAI format                  │  │
│  │     • Add usage metadata                              │  │
│  └────────────────────────────────────────────────────────┘  │
└────────────────────┬─────────────────────────────────────────┘
                     │ [16] Update Database
                     │      INSERT INTO litellm_spend (...)
                     │      UPDATE usage counters
                     ▼
┌──────────────────────────────────────────────────────────────┐
│  RDS PostgreSQL - Usage Tracking                            │
│  ┌────────────────────────────────────────────────────────┐  │
│  │ [17] Record Usage (Transaction)                       │  │
│  │     BEGIN;                                             │  │
│  │     INSERT INTO litellm_spend VALUES (                │  │
│  │       token: 'sk-xxx',                                │  │
│  │       user_id: 'john.doe@company.com',                │  │
│  │       model: 'claude-3-5-sonnet',                     │  │
│  │       prompt_tokens: 150,                             │  │
│  │       completion_tokens: 300,                         │  │
│  │       spend: 0.00495,                                 │  │
│  │       created_at: NOW()                               │  │
│  │     );                                                 │  │
│  │     COMMIT;                                            │  │
│  └────────────────────────────────────────────────────────┘  │
└────────────────────┬─────────────────────────────────────────┘
                     │ [18] Acknowledgment
                     ▼
┌──────────────────────────────────────────────────────────────┐
│  LiteLLM Proxy - Return Response                            │
└────────────────────┬─────────────────────────────────────────┘
                     │ [19] HTTP 200 OK
                     │      OpenAI-compatible response
                     ▼
┌──────────────────────────────────────────────────────────────┐
│  Application Load Balancer                                   │
└────────────────────┬─────────────────────────────────────────┘
                     │ [20] HTTPS Response (TLS encrypted)
                     ▼
┌──────────────┐
│  User Client │  Receives response
└──────────────┘


FLOW 2: AUDIT LOGGING (Parallel Process)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

┌──────────────────────────────────────────────────────────────┐
│  LiteLLM Proxy                                               │
│  [A1] Generate Audit Log Entry                               │
│       {                                                       │
│         timestamp, user_id, token_id, model,                 │
│         request_size, response_size, latency,                │
│         cost, status_code, error (if any)                    │
│       }                                                       │
└────────────────────┬─────────────────────────────────────────┘
                     │ [A2] Asynchronous logging
                     ├────────────────────┬────────────────────┐
                     ▼                    ▼                    ▼
        ┌─────────────────────┐ ┌─────────────────┐ ┌────────────────┐
        │  CloudWatch Logs    │ │  S3 Bucket      │ │  CloudWatch    │
        │  /ecs/llmlite-proxy │ │  Audit Logs     │ │  Metrics       │
        │  [A3] Real-time     │ │  [A4] Long-term │ │  [A5] Metrics  │
        │      monitoring     │ │      archive    │ │      tracking  │
        └─────────────────────┘ └─────────────────┘ └────────────────┘


FLOW 2b: WAF LOGGING (Parallel Process)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

┌──────────────────────────────────────────────────────────────┐
│  AWS WAF v2                                                  │
│  [W1] Generate WAF Log Entry per request                     │
│       {                                                       │
│         timestamp, action (ALLOW/BLOCK/COUNT),               │
│         terminatingRuleId, httpRequest (URI, method,         │
│         clientIP, headers), ruleGroupList                    │
│       }                                                       │
└────────────────────┬─────────────────────────────────────────┘
                     │ [W2] WAF logging (near real-time)
                     ├────────────────────┐
                     ▼                    ▼
        ┌─────────────────────┐ ┌─────────────────────┐
        │  CloudWatch Logs    │ │  S3 Bucket          │
        │  aws-waf-logs-      │ │  WAF Logs           │
        │  llmlite            │ │  (long-term)        │
        │  [W3] Real-time     │ │  [W4] Archive       │
        │      monitoring     │ │                     │
        └─────────────────────┘ └─────────────────────┘


FLOW 3: KEY MANAGEMENT (Admin Operation)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

┌──────────────┐
│  Admin User  │
└──────┬───────┘
       │ [K1] POST /key/generate
       │      Authorization: Bearer MASTER_KEY
       │      Body: { user_id, team_id, limits, budget, models }
       ▼
┌──────────────────────────────────────────────────────────────┐
│  LiteLLM Proxy - Key Management                             │
│  [K2] Validate Master Key                                    │
│  [K3] Generate new virtual key (sk-xxx)                      │
└────────────────────┬─────────────────────────────────────────┘
                     │ [K4] INSERT INTO litellm_verificationtoken
                     ▼
┌──────────────────────────────────────────────────────────────┐
│  RDS PostgreSQL                                              │
│  [K5] Store Key Metadata (Transaction)                       │
│       BEGIN;                                                  │
│       INSERT INTO litellm_verificationtoken VALUES (         │
│         token: 'sk-xxx',                                     │
│         user_id, team_id, tpm_limit, rpm_limit,             │
│         max_budget, allowed_models, created_at               │
│       );                                                      │
│       INSERT INTO litellm_usertable VALUES (...);            │
│       COMMIT;                                                 │
└────────────────────┬─────────────────────────────────────────┘
                     │ [K6] Return success
                     ▼
┌──────────────────────────────────────────────────────────────┐
│  LiteLLM Proxy                                               │
│  [K7] Return new key to admin                                │
└────────────────────┬─────────────────────────────────────────┘
                     │ [K8] HTTP 200 OK
                     │      { key: "sk-xxx", metadata: {...} }
                     ▼
┌──────────────┐
│  Admin User  │  Distributes key to end user
└──────────────┘


FLOW 4: MONITORING & ALERTING
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

┌──────────────────────────────────────────────────────────────┐
│  All Components (WAF, ALB, Fargate, RDS)                    │
│  [M1] Emit metrics continuously                              │
└──────┬──────────────────────┬───────────────────┬────────────┘
       │                      │                   │
       │ [M2] Metrics         │ [M3] Logs         │ [M4] Events
       ▼                      ▼                   ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│  CloudWatch     │  │  CloudWatch     │  │  CloudWatch     │
│  Metrics        │  │  Logs           │  │  Alarms         │
│  • Request rate │  │  • Application  │  │  • High error   │
│  • Latency      │  │  • WAF logs     │  │  • High latency │
│  • Error rate   │  │  • Database     │  │  • WAF blocks   │
│  • WAF metrics  │  │  • RDS slow     │  │  • DB issues    │
│  • DB metrics   │  │    queries      │  │                 │
└─────────┬───────┘  └─────────┬───────┘  └─────────┬───────┘
          │                    │                     │
          │ [M5] Aggregation   │                     │
          └────────────────────┴─────────────────────┘
                               │
                               │ [M6] Alarm triggers
                               ▼
                    ┌────────────────────────┐
                    │  CloudWatch Dashboard  │
                    │  • Real-time metrics   │
                    │  • Visual monitoring   │
                    └────────────────────────┘


FLOW 5: DATABASE REPLICATION (Multi-AZ HA)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

┌──────────────────────────────────────────────────────────────┐
│  RDS Primary (10.1.21.10 - eu-west-2a)                       │
│  [R1] Write operations (INSERT, UPDATE)                      │
└────────────────────┬─────────────────────────────────────────┘
                     │ [R2] Synchronous replication
                     │      PostgreSQL streaming replication
                     │      WAL (Write-Ahead Log) shipping
                     ▼
┌──────────────────────────────────────────────────────────────┐
│  RDS Standby (10.1.22.10 - eu-west-2b)                      │
│  [R3] Replicate writes                                       │
│  [R4] Maintain hot standby                                   │
│       • Automatic failover ready                             │
│       • Sync lag < 1 second                                  │
└──────────────────────────────────────────────────────────────┘

        (If Primary Fails)
                │ [R5] Automatic failover (30-60 seconds)
                ▼
┌──────────────────────────────────────────────────────────────┐
│  Former Standby Promoted to Primary                         │
│  [R6] DNS endpoint updated automatically                     │
│       llmlite-postgres.xxx.rds.amazonaws.com → 10.1.22.10   │
│  [R7] LiteLLM tasks reconnect automatically                  │
└──────────────────────────────────────────────────────────────┘


DATA STORES & PERSISTENCE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

┌────────────────────────────────────────────────────────────────┐
│  RDS PostgreSQL (Primary Data Store)                          │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │ Tables:                                                   │ │
│  │ • litellm_verificationtoken (virtual keys)               │ │
│  │ • litellm_usertable (user profiles)                      │ │
│  │ • litellm_spend (usage tracking)                         │ │
│  │ • litellm_proxy_config (configuration)                   │ │
│  │                                                           │ │
│  │ Data Flow:                                                │ │
│  │ [D1] Key lookups: Read-heavy (per request)               │ │
│  │ [D2] Usage tracking: Write-heavy (per response)          │ │
│  │ [D3] Automated backups: Daily to S3                      │ │
│  │ [D4] Retention: 7 days (configurable)                    │ │
│  └──────────────────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────┐
│  S3 Bucket (Audit Logs - Long-term Storage)                   │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │ Structure:                                                │ │
│  │ s3://llmlite-audit-logs-{account}/                       │ │
│  │   └── audit/                                             │ │
│  │       └── 2026/02/23/                                    │ │
│  │           ├── request-{timestamp}-{request-id}.json      │ │
│  │           └── ...                                        │ │
│  │                                                           │ │
│  │ Lifecycle:                                                │ │
│  │ [D5] Standard storage: 90 days                           │ │
│  │ [D6] Glacier transition: After 90 days                   │ │
│  │ [D7] Retention: 7 years (compliance)                     │ │
│  └──────────────────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────────────────┘


ENCRYPTION & SECURITY DATA FLOW
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

┌──────────────────────────────────────────────────────────────┐
│  KMS (Customer Managed Key)                                  │
│  [E1] llmlite-key (eu-west-2)                                │
└─────┬────────────────────────────┬───────────────────────────┘
      │                            │
      │ [E2] Encrypt/Decrypt       │ [E3] Generate Data Keys
      ▼                            ▼
┌────────────────┐        ┌────────────────────────────────┐
│  RDS Storage   │        │  S3 Objects & CloudWatch Logs  │
│  • Data at rest│        │  • Audit logs encrypted        │
│  • Backups     │        │  • WAF logs encrypted          │
│  • Snapshots   │        │  • Log streams encrypted       │
└────────────────┘        └────────────────────────────────┘

      [E4] TLS 1.3 Encryption (In Transit)
      • User → WAF → ALB: HTTPS (TLS 1.3)
      • ALB → Fargate: HTTP (internal VPC)
      • Fargate → RDS: SSL/TLS (PostgreSQL SSL mode)
      • Fargate → Bedrock: HTTPS (via NAT → IGW)


PERFORMANCE OPTIMIZATION DATA PATHS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

┌──────────────────────────────────────────────────────────────┐
│  LiteLLM Proxy - Connection Pooling                         │
│  [P1] Database connection pool (10-50 connections)           │
│       • Reuse connections across requests                    │
│       • Reduce connection overhead                           │
└────────────────────┬─────────────────────────────────────────┘
                     │ [P2] Persistent connections
                     ▼
┌──────────────────────────────────────────────────────────────┐
│  RDS PostgreSQL                                              │
│  [P3] Query optimization                                     │
│       • Indexed lookups on token field                       │
│       • Prepared statements (prevent SQL injection)          │
│       • Query result caching                                 │
└──────────────────────────────────────────────────────────────┘

[P4] Fargate Auto-scaling
     • Scale out: CPU > 70% → Add tasks
     • Scale in: CPU < 30% for 5 min → Remove tasks
     • Max 5 tasks, Min 2 tasks

[P5] Database read optimization
     • Multi-AZ standby can serve read replicas (if enabled)
     • Connection pooling reduces latency
     • Indexes on frequently queried columns
```

### 2.4 User Journey

#### **One-Time Setup (New User Onboarding)**

```mermaid
sequenceDiagram
    participant Admin
    participant LiteLLM as LiteLLM Proxy
    participant RDS as RDS PostgreSQL
    participant User
    
    Admin->>LiteLLM: Create virtual key (POST /key/generate)
    LiteLLM->>RDS: Store key metadata (user, rate limit)
    RDS->>LiteLLM: Confirm storage (ACID transaction)
    LiteLLM->>Admin: Return virtual key (sk-...)
    Admin->>User: Send virtual key via secure channel
    User->>User: Configure IDE/application with key
    User->>User: Ready to make API calls
```

#### **Daily Usage (API Access)**

```mermaid
sequenceDiagram
    participant User as User Application
    participant WAF as AWS WAF v2
    participant ALB as Load Balancer
    participant LiteLLM as LiteLLM Proxy
    participant RDS as RDS PostgreSQL
    participant Bedrock as AWS Bedrock
    
    User->>WAF: POST /v1/chat/completions (Authorization: Bearer sk-...)
    WAF->>WAF: Inspect request against rule groups
    WAF->>ALB: Forward allowed request
    ALB->>LiteLLM: Forward HTTPS request
    LiteLLM->>RDS: Validate virtual key (SELECT query)
    RDS->>LiteLLM: Key valid + user metadata
    LiteLLM->>LiteLLM: Check rate limit
    LiteLLM->>LiteLLM: Filter PII
    LiteLLM->>LiteLLM: Log request
    LiteLLM->>Bedrock: Invoke Claude model
    Bedrock->>LiteLLM: Return response
    LiteLLM->>RDS: Update usage metrics (UPDATE transaction)
    LiteLLM->>LiteLLM: Log response & cost
    LiteLLM->>ALB: Return response
    ALB->>User: HTTPS 200 OK
```

---

## 3. Architecture Design

### 3.1 Logical Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│              SINGLE AWS ACCOUNT ARCHITECTURE (eu-west-2)            │
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │                    AWS WAF v2 (Regional)                     │  │
│  │  • Associated with ALB                                       │  │
│  │  • AWSManagedRulesCommonRuleSet (OWASP Top 10)              │  │
│  │  • AWSManagedRulesKnownBadInputsRuleSet                     │  │
│  │  • AWSManagedRulesAmazonIpReputationList                    │  │
│  │  • Rate-based rule: 2,000 req/5min per IP                   │  │
│  │  • Geo blocking rule (configurable)                         │  │
│  │  • WAF logs → CloudWatch / S3                               │  │
│  └────────────────────┬─────────────────────────────────────────┘  │
│                       │                                             │
│  ┌─────────────────────▼────────  PUBLIC SUBNET  ───────────────┐  │
│  │                                                               │  │
│  │  ┌──────────────────────────────────────────────────────┐   │  │
│  │  │   Application Load Balancer (ALB)                    │   │  │
│  │  │   • Public HTTPS Endpoint (port 443)                 │   │  │
│  │  │   • HTTP → HTTPS Redirect (port 80)                  │   │  │
│  │  │   • ACM SSL/TLS Certificate                          │   │  │
│  │  │   • Connection Draining: 30s                         │   │  │
│  │  │   • Idle Timeout: 60s                                │   │  │
│  │  │   • Health Check: /health (200 OK)                   │   │  │
│  │  │   • Target: Fargate Tasks (port 4000)                │   │  │
│  │  └──────────────────────────────────────────────────────┘   │  │
│  │           │                                                   │  │
│  └───────────┼───────────────────────────────────────────────────┘  │
│              │                                                     │
│  ┌───────────▼──────────  PRIVATE SUBNET  ──────────────────────┐  │
│  │                                                               │  │
│  │  ┌─────────────────────────────────────────────────────┐    │  │
│  │  │   ECS Service (LiteLLM Proxy)                       │    │  │
│  │  │   ┌─────────────────┐  ┌─────────────────┐          │    │  │
│  │  │   │  Fargate Task 1 │  │  Fargate Task 2 │  ...     │    │  │
│  │  │   │  • 1.0 vCPU     │  │  • 1.0 vCPU     │          │    │  │
│  │  │   │  • 2 GB RAM     │  │  • 2 GB RAM     │          │    │  │
│  │  │   │  • Port 4000    │  │  • Port 4000    │          │    │  │
│  │  │   │  • LiteLLM      │  │  • LiteLLM      │          │    │  │
│  │  │   └─────────────────┘  └─────────────────┘          │    │  │
│  │  │   Auto-scaling: 2-5 tasks (CPU > 70% scales up)     │    │  │
│  │  └─────────────────────────────────────────────────────┘    │  │
│  │              │              │                                 │  │
│  │              │              └─────────────┐                   │  │
│  │              │                            │                   │  │
│  │  ┌───────────▼──────────┐    ┌───────────▼──────────┐       │  │
│  │  │   RDS PostgreSQL     │    │   NAT Gateway        │       │  │
│  │  │   • Multi-AZ         │    │   • Bedrock API      │       │  │
│  │  │   • db.t4g.small     │    │   • S3 Access        │       │  │
│  │  │   • 20 GB storage    │    │   • CloudWatch       │       │  │
│  │  │   • Auto backup      │    └──────────────────────┘       │  │
│  │  │   • Port 5432        │                                    │  │
│  │  └──────────────────────┘                                    │  │
│  └───────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │              AWS MANAGED SERVICES (SAME ACCOUNT)             │  │
│  │                                                               │  │
│  │  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐  │  │
│  │  │  AWS Bedrock   │  │  Amazon S3     │  │  CloudWatch    │  │  │
│  │  │  • Claude 3.5  │  │  • Audit Logs  │  │  • Logs        │  │  │
│  │  │    Sonnet      │  │  • WAF Logs    │  │  • Metrics     │  │  │
│  │  │  • Claude 3    │  │  • KMS Encrypt │  │  • Dashboards  │  │  │
│  │  │    Opus        │  └────────────────┘  │  • Alarms      │  │  │
│  │  └────────────────┘                      └────────────────┘  │  │
│  └───────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
```

### 3.2 Physical Architecture (AWS Deployment)

**AWS Account:** Single account (all resources in one account)  
**Region:** eu-west-2 (Europe - London)  
**Availability Zones:** 2 AZs for high availability (eu-west-2a, eu-west-2b)

```
Region: eu-west-2 (Single AWS Account)
│
├── AWS WAF v2 (Regional WebACL: llmlite-waf-acl)
│   ├── Association: llmlite-alb (ARN)
│   ├── Default Action: Allow
│   ├── Rule Groups (in priority order):
│   │   ├── Priority 1: AWSManagedRulesAmazonIpReputationList
│   │   │   └── Action: Block
│   │   ├── Priority 2: AWSManagedRulesCommonRuleSet
│   │   │   └── Action: Block
│   │   ├── Priority 3: AWSManagedRulesKnownBadInputsRuleSet
│   │   │   └── Action: Block
│   │   └── Priority 4: RateBasedRule-LLMLite
│   │       ├── Limit: 2,000 requests per 5 minutes (per IP)
│   │       └── Action: Block
│   ├── Logging:
│   │   ├── CloudWatch Log Group: aws-waf-logs-llmlite
│   │   └── S3 Bucket: llmlite-waf-logs-{account-id}
│   └── Metrics: Enabled (CloudWatch namespace: AWS/WAFV2)
│
├── VPC: llmlite-vpc (10.1.0.0/20)
│   │
│   ├── Public Subnets (for ALB)
│   │   ├── public-subnet-2a (10.1.1.0/24) - AZ eu-west-2a
│   │   └── public-subnet-2b (10.1.2.0/24) - AZ eu-west-2b
│   │
│   ├── Private Subnets (for Fargate + RDS)
│   │   ├── private-subnet-2a (10.1.11.0/24) - AZ eu-west-2a
│   │   └── private-subnet-2b (10.1.12.0/24) - AZ eu-west-2b
│   │
│   ├── Database Subnets (for RDS - isolated)
│   │   ├── database-subnet-2a (10.1.21.0/24) - AZ eu-west-2a
│   │   └── database-subnet-2b (10.1.22.0/24) - AZ eu-west-2b
│   │
│   ├── Internet Gateway (IGW)
│   │   └── Attached to VPC
│   │
│   ├── NAT Gateways (for private subnet internet access)
│   │   ├── nat-gateway-2a (in public-subnet-2a)
│   │   └── nat-gateway-2b (in public-subnet-2b)
│   │
│   ├── Route Tables
│   │   ├── Public RT: 0.0.0.0/0 → IGW
│   │   ├── Private RT: 0.0.0.0/0 → NAT Gateway
│   │   └── Database RT: No internet access (local only)
│   │
│   └── Security Groups
│       ├── alb-sg: Allow 80, 443 from 0.0.0.0/0
│       ├── fargate-sg: Allow 4000 from alb-sg
│       └── rds-sg: Allow 5432 from fargate-sg
│
├── RDS PostgreSQL
│   ├── DB Identifier: llmlite-postgres
│   ├── Engine: PostgreSQL 15.x
│   ├── Instance Class: db.t4g.small (2 vCPU, 2 GB RAM)
│   ├── Storage: 20 GB GP3 (auto-scaling up to 100 GB)
│   ├── Multi-AZ: Enabled (automatic failover)
│   ├── Subnets: database-subnet-2a, database-subnet-2b
│   ├── Security Group: rds-sg
│   ├── Port: 5432
│   ├── Backup Retention: 7 days
│   ├── Encryption: KMS (llmlite-key)
│   ├── Monitoring: Enhanced monitoring enabled
│   └── Database: litellm_db
│       ├── Schema: public
│       └── Tables:
│           ├── litellm_verificationtoken (virtual keys)
│           ├── litellm_usertable (user metadata)
│           ├── litellm_spend (usage tracking)
│           └── litellm_proxy_config (configuration)
│
├── ECS Cluster: llmlite-cluster
│   └── Service: llmlite-service
│       ├── Task Definition: llmlite-task
│       │   ├── Container: litellm-proxy
│       │   ├── CPU: 1024 (1.0 vCPU)
│       │   ├── Memory: 2048 MB
│       │   └── IAM Task Role: llmlite-task-role
│       └── Desired Count: 2 (auto-scales 2-5)
│
├── Application Load Balancer: llmlite-alb
│   ├── Scheme: internet-facing
│   ├── Subnets: public-subnet-2a, public-subnet-2b
│   ├── Security Group: alb-sg
│   ├── WAF WebACL: llmlite-waf-acl (associated)
│   ├── Listeners:
│   │   ├── HTTPS:443 → Target Group (llmlite-tg)
│   │   └── HTTP:80 → Redirect to HTTPS
│   └── Target Group: llmlite-tg
│       ├── Protocol: HTTP
│       ├── Port: 4000
│       ├── Health Check: /health
│       └── Deregistration Delay: 30s
│
├── S3 Buckets
│   ├── llmlite-audit-logs-{account-id}
│   │   ├── Versioning: Enabled
│   │   ├── Encryption: KMS (llmlite-key)
│   │   └── Lifecycle: Archive to Glacier after 90 days
│   ├── llmlite-waf-logs-{account-id}
│   │   ├── Versioning: Enabled
│   │   ├── Encryption: KMS (llmlite-key)
│   │   └── Lifecycle: Archive to Glacier after 90 days
│   └── llmlite-cost-tracking-{account-id}
│       ├── Encryption: KMS (llmlite-key)
│       └── Access: Admin keys only
│
├── CloudWatch
│   ├── Log Groups:
│   │   ├── /ecs/llmlite-proxy (application logs)
│   │   ├── /aws/ecs/llmlite-cluster (container insights)
│   │   ├── /aws/rds/instance/llmlite-postgres/postgresql (DB logs)
│   │   └── aws-waf-logs-llmlite (WAF logs)
│   ├── Metrics:
│   │   ├── RequestCount
│   │   ├── TargetResponseTime
│   │   ├── HTTPCode_Target_4XX_Count
│   │   ├── HTTPCode_Target_5XX_Count
│   │   ├── DatabaseConnections
│   │   ├── CPUUtilization (RDS)
│   │   ├── BlockedRequests (WAF)
│   │   └── AllowedRequests (WAF)
│   ├── Dashboards:
│   │   └── LLMLite-Dashboard
│   └── Alarms:
│       ├── HighErrorRate (5xx > 5%)
│       ├── HighLatency (p95 > 3s)
│       ├── UnhealthyTargets (< 1 healthy)
│       ├── RDSHighCPU (> 80%)
│       ├── RDSLowStorage (< 20%)
│       └── WAFHighBlockRate (> 100 blocks/5min)
│
├── KMS
│   └── Key: llmlite-key
│       ├── Usage: S3, RDS, CloudWatch, WAF logs encryption
│       ├── Key Rotation: Enabled (annual)
│       └── Key Policy: Restrict to LLMLite services
│
└── AWS Bedrock
    ├── Region: eu-west-2
    ├── Models:
    │   ├── anthropic.claude-3-5-sonnet-20241022-v2:0
    │   └── anthropic.claude-3-opus-20240229-v1:0
    └── Model Access: Requested and approved
```

### 3.3 Network Diagram with IP Addressing

```
┌────────────────────────────────────────────────────────────────────┐
│                    VPC: llmlite-vpc (10.1.0.0/20)                  │
│                        Region: eu-west-2                           │
├────────────────────────────────────────────────────────────────────┤
│                                                                    │
│  ┌──────────────────────────────────────────────────────────────┐ │
│  │                    AVAILABILITY ZONE 2a                      │ │
│  │                                                              │ │
│  │  ┌────────────────────────────────────────────────────┐    │ │
│  │  │  Public Subnet: public-subnet-2a                   │    │ │
│  │  │  CIDR: 10.1.1.0/24                                 │    │ │
│  │  │  Usable IPs: 10.1.1.1 - 10.1.1.254                │    │ │
│  │  │                                                    │    │ │
│  │  │  Resources:                                        │    │ │
│  │  │  • ALB Node: 10.1.1.10                            │    │ │
│  │  │  • NAT Gateway: 10.1.1.20                         │    │ │
│  │  │                                                    │    │ │
│  │  │  Route Table: public-rt                           │    │ │
│  │  │  • 10.1.0.0/20 → local                            │    │ │
│  │  │  • 0.0.0.0/0 → Internet Gateway                   │    │ │
│  │  └────────────────────────────────────────────────────┘    │ │
│  │                                                              │ │
│  │  ┌────────────────────────────────────────────────────┐    │ │
│  │  │  Private Subnet: private-subnet-2a                 │    │ │
│  │  │  CIDR: 10.1.11.0/24                                │    │ │
│  │  │  Usable IPs: 10.1.11.1 - 10.1.11.254              │    │ │
│  │  │                                                    │    │ │
│  │  │  Resources:                                        │    │ │
│  │  │  • Fargate Task 1: 10.1.11.10                     │    │ │
│  │  │  • Fargate Task 3: 10.1.11.30                     │    │ │
│  │  │                                                    │    │ │
│  │  │  Route Table: private-rt-2a                       │    │ │
│  │  │  • 10.1.0.0/20 → local                            │    │ │
│  │  │  • 0.0.0.0/0 → NAT Gateway (10.1.1.20)            │    │ │
│  │  └────────────────────────────────────────────────────┘    │ │
│  │                                                              │ │
│  │  ┌────────────────────────────────────────────────────┐    │ │
│  │  │  Database Subnet: database-subnet-2a               │    │ │
│  │  │  CIDR: 10.1.21.0/24                                │    │ │
│  │  │  Usable IPs: 10.1.21.1 - 10.1.21.254              │    │ │
│  │  │                                                    │    │ │
│  │  │  Resources:                                        │    │ │
│  │  │  • RDS Primary: 10.1.21.10                        │    │ │
│  │  │                                                    │    │ │
│  │  │  Route Table: database-rt                         │    │ │
│  │  │  • 10.1.0.0/20 → local                            │    │ │
│  │  │  • No internet route (isolated)                   │    │ │
│  │  └────────────────────────────────────────────────────┘    │ │
│  └──────────────────────────────────────────────────────────────┘ │
│                                                                    │
│  ┌──────────────────────────────────────────────────────────────┐ │
│  │                    AVAILABILITY ZONE 2b                      │ │
│  │                                                              │ │
│  │  ┌────────────────────────────────────────────────────┐    │ │
│  │  │  Public Subnet: public-subnet-2b                   │    │ │
│  │  │  CIDR: 10.1.2.0/24                                 │    │ │
│  │  │  Usable IPs: 10.1.2.1 - 10.1.2.254                │    │ │
│  │  │                                                    │    │ │
│  │  │  Resources:                                        │    │ │
│  │  │  • ALB Node: 10.1.2.10                            │    │ │
│  │  │  • NAT Gateway: 10.1.2.20                         │    │ │
│  │  │                                                    │    │ │
│  │  │  Route Table: public-rt                           │    │ │
│  │  │  • 10.1.0.0/20 → local                            │    │ │
│  │  │  • 0.0.0.0/0 → Internet Gateway                   │    │ │
│  │  └────────────────────────────────────────────────────┘    │ │
│  │                                                              │ │
│  │  ┌────────────────────────────────────────────────────┐    │ │
│  │  │  Private Subnet: private-subnet-2b                 │    │ │
│  │  │  CIDR: 10.1.12.0/24                                │    │ │
│  │  │  Usable IPs: 10.1.12.1 - 10.1.12.254              │    │ │
│  │  │                                                    │    │ │
│  │  │  Resources:                                        │    │ │
│  │  │  • Fargate Task 2: 10.1.12.10                     │    │ │
│  │  │  • Fargate Task 4: 10.1.12.30                     │    │ │
│  │  │                                                    │    │ │
│  │  │  Route Table: private-rt-2b                       │    │ │
│  │  │  • 10.1.0.0/20 → local                            │    │ │
│  │  │  • 0.0.0.0/0 → NAT Gateway (10.1.2.20)            │    │ │
│  │  └────────────────────────────────────────────────────┘    │ │
│  │                                                              │ │
│  │  ┌────────────────────────────────────────────────────┐    │ │
│  │  │  Database Subnet: database-subnet-2b               │    │ │
│  │  │  CIDR: 10.1.22.0/24                                │    │ │
│  │  │  Usable IPs: 10.1.22.1 - 10.1.22.254              │    │ │
│  │  │                                                    │    │ │
│  │  │  Resources:                                        │    │ │
│  │  │  • RDS Standby: 10.1.22.10                        │    │ │
│  │  │                                                    │    │ │
│  │  │  Route Table: database-rt                         │    │ │
│  │  │  • 10.1.0.0/20 → local                            │    │ │
│  │  │  • No internet route (isolated)                   │    │ │
│  │  └────────────────────────────────────────────────────┘    │ │
│  └──────────────────────────────────────────────────────────────┘ │
│                                                                    │
│  ┌──────────────────────────────────────────────────────────────┐ │
│  │                      EXTERNAL CONNECTIVITY                   │ │
│  │                                                              │ │
│  │  Internet Gateway (IGW)                                     │ │
│  │  • Attached to VPC                                          │ │
│  │  • Routes traffic to/from public subnets                    │ │
│  │                                                              │ │
│  │  RDS Endpoint (DNS):                                        │ │
│  │  llmlite-postgres.xxxxxx.eu-west-2.rds.amazonaws.com        │ │
│  │  • Resolves to: 10.1.21.10 (primary) or 10.1.22.10 (standby)│ │
│  │                                                              │ │
│  │  ALB DNS:                                                   │ │
│  │  llmlite-alb-xxxxxxxx.eu-west-2.elb.amazonaws.com           │ │
│  │  • Resolves to: 10.1.1.10 and 10.1.2.10                    │ │
│  └──────────────────────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────────────────────┘

CIDR Block Summary:
├── VPC CIDR: 10.1.0.0/20 (4,096 IPs)
│
├── Public Subnets (for ALB + NAT):
│   ├── 10.1.1.0/24 (AZ 2a) - 256 IPs
│   └── 10.1.2.0/24 (AZ 2b) - 256 IPs
│
├── Private Subnets (for Fargate):
│   ├── 10.1.11.0/24 (AZ 2a) - 256 IPs  ⚠️ Note: outside /20 range — extend VPC to /16 if required
│   └── 10.1.12.0/24 (AZ 2b) - 256 IPs  ⚠️ Note: outside /20 range — extend VPC to /16 if required
│
├── Database Subnets (for RDS):
│   ├── 10.1.21.0/24 (AZ 2a) - 256 IPs  ⚠️ Note: outside /20 range — extend VPC to /16 if required
│   └── 10.1.22.0/24 (AZ 2b) - 256 IPs  ⚠️ Note: outside /20 range — extend VPC to /16 if required
│
└── Available within /20 range (10.1.0.0 - 10.1.15.255):
    └── 10.1.3.0/24 - 10.1.15.0/24 (13 subnets available for future expansion)
```

> **⚠️ CIDR Advisory:** The VPC CIDR of `10.1.0.0/20` covers `10.1.0.0 – 10.1.15.255`. The private subnets (`10.1.11.x`, `10.1.12.x`) fall within this range, however the database subnets (`10.1.21.x`, `10.1.22.x`) fall **outside** this range. It is recommended to either expand the VPC CIDR to `10.1.0.0/16` to accommodate all subnets, or re-address the database subnets to fall within `10.1.0.0/20` (e.g. `10.1.13.0/24` and `10.1.14.0/24`). Please confirm the preferred approach before implementation.

### 3.4 Authentication Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                   LITELLM VIRTUAL KEY AUTHENTICATION            │
│                                                                 │
│  0. Request inspected by AWS WAF v2 before reaching ALB        │
│     ┌─────────────────────────────────────────────────────┐   │
│     │ WAF Rule Evaluation (in priority order):            │   │
│     │  • IP Reputation List → Block known bad actors      │   │
│     │  • OWASP Common Rules → Block SQLi, XSS, etc.      │   │
│     │  • Known Bad Inputs → Block exploit signatures      │   │
│     │  • Rate-based rule → Block >2,000 req/5min per IP  │   │
│     │                                                     │   │
│     │ If any rule matches → HTTP 403 Forbidden (blocked) │   │
│     │ If no rules match  → Request forwarded to ALB      │   │
│     └─────────────────────────────────────────────────────┘   │
│                                                                 │
│  1. Admin generates virtual key                                │
│     ┌─────────────────────────────────────────────────────┐   │
│     │ POST /key/generate                                  │   │
│     │ {                                                   │   │
│     │   "user_id": "john.doe@company.com",               │   │
│     │   "team_id": "engineering",                        │   │
│     │   "max_budget": 100.0,                             │   │
│     │   "tpm_limit": 100,                                │   │
│     │   "rpm_limit": 100,                                │   │
│     │   "models": ["claude-3-5-sonnet", "claude-3-opus"] │   │
│     │ }                                                   │   │
│     └─────────────────────────────────────────────────────┘   │
│                              ↓                                  │
│     ┌─────────────────────────────────────────────────────┐   │
│     │ Response: { "key": "sk-1234...abcd" }              │   │
│     └─────────────────────────────────────────────────────┘   │
│                                                                 │
│  2. User makes API request with virtual key                    │
│     ┌─────────────────────────────────────────────────────┐   │
│     │ POST /v1/chat/completions                           │   │
│     │ Authorization: Bearer sk-1234...abcd                │   │
│     │ Content-Type: application/json                      │   │
│     │                                                     │   │
│     │ {                                                   │   │
│     │   "model": "claude-3-5-sonnet",                    │   │
│     │   "messages": [...]                                │   │
│     │ }                                                   │   │
│     └─────────────────────────────────────────────────────┘   │
│                              ↓                                  │
│  3. LiteLLM validates key against PostgreSQL                   │
│     ┌─────────────────────────────────────────────────────┐   │
│     │ SELECT * FROM litellm_verificationtoken             │   │
│     │ WHERE token = 'sk-1234...abcd'                      │   │
│     │                                                     │   │
│     │ Checks:                                             │   │
│     │ • Key exists and not expired?                       │   │
│     │ • User within rate limits (TPM/RPM)?                │   │
│     │ • User within budget?                               │   │
│     │ • Model allowed for this key?                       │   │
│     └─────────────────────────────────────────────────────┘   │
│                              ↓                                  │
│  4. If valid, forward to Bedrock                               │
│     ┌─────────────────────────────────────────────────────┐   │
│     │ LiteLLM → AWS Bedrock (Claude models)               │   │
│     │ UPDATE litellm_spend with usage metrics             │   │
│     │ Log request to CloudWatch + S3                      │   │
│     └─────────────────────────────────────────────────────┘   │
│                              ↓                                  │
│  5. Return response to user                                    │
│     ┌─────────────────────────────────────────────────────┐   │
│     │ HTTP 200 OK                                         │   │
│     │ { "choices": [...], "usage": {...} }               │   │
│     └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

---

## 4. Component Specifications

### 4.1 AWS WAF v2

**Purpose:** Protect the ALB and LiteLLM gateway from common web exploits, malicious traffic, and API abuse at the edge — before requests reach application infrastructure.

**Configuration:**

| Setting | Value |
|---------|-------|
| WebACL Name | llmlite-waf-acl |
| Scope | REGIONAL |
| Association | llmlite-alb (ARN) |
| Default Action | Allow |
| Metrics | Enabled (CloudWatch namespace: AWS/WAFV2) |
| Sampled Requests | Enabled |

**Managed Rule Groups:**

| Priority | Rule Group | Action | Purpose |
|----------|------------|--------|---------|
| 1 | AWSManagedRulesAmazonIpReputationList | Block | Block IPs associated with bots and threat actors |
| 2 | AWSManagedRulesCommonRuleSet | Block | OWASP Top 10: SQLi, XSS, LFI, RFI, etc. |
| 3 | AWSManagedRulesKnownBadInputsRuleSet | Block | Block known exploit signatures and malformed inputs |

**Custom Rules:**

| Priority | Rule Name | Type | Condition | Action |
|----------|-----------|------|-----------|--------|
| 4 | RateLimit-PerIP | Rate-based | > 2,000 requests / 5 minutes per IP | Block |
| 5 | GeoBlock (optional) | Geo match | Countries outside allowed list | Block |

**Logging Configuration:**
- Log Destination: CloudWatch Log Group (`aws-waf-logs-llmlite`) and S3 (`llmlite-waf-logs-{account-id}`)
- Log Fields: Timestamp, action, client IP, URI, terminating rule, rule group list
- Redacted Fields: Authorization header (to prevent virtual key exposure in logs)
- Encryption: KMS (llmlite-key)

**CloudWatch Metrics (AWS/WAFV2 namespace):**
- AllowedRequests
- BlockedRequests
- CountedRequests
- PassedRequests

**IAM Permissions Required:**
- `wafv2:AssociateWebACL` — to associate WebACL with ALB
- `wafv2:GetWebACL`, `wafv2:ListWebACLs` — for read access
- `logs:CreateLogDelivery` — for WAF log delivery to CloudWatch

### 4.2 LiteLLM Proxy Server

**Purpose:** OpenAI-compatible API gateway with virtual key authentication and rate limiting

**Configuration:**

| Setting | Value |
|---------|-------|
| Container Port | 4000 |
| Protocol | HTTP (ALB handles HTTPS) |
| Base Image | ghcr.io/berriai/litellm:main-latest |
| Health Check | /health |
| Admin Endpoint | /key/generate, /key/delete, /key/info |

**Key Features:**
- Virtual key generation and management
- OpenAI-compatible API endpoints
- Built-in rate limiting (TPM, RPM, budget)
- Cost tracking per key
- Model access control per key
- Request/response logging
- PostgreSQL backend for key storage

**Environment Variables:**
- DATABASE_URL: PostgreSQL connection string
- LITELLM_MASTER_KEY: Admin key for key management
- AWS_REGION: eu-west-2
- LITELLM_LOG: INFO
- STORE_MODEL_IN_DB: true

### 4.3 Application Load Balancer (ALB)

**Purpose:** HTTPS endpoint, SSL termination, request routing

**Specifications:**

| Property | Value |
|----------|-------|
| Type | Application Load Balancer |
| Scheme | Internet-facing |
| IP Address Type | IPv4 |
| Subnets | public-subnet-2a, public-subnet-2b |
| Security Group | alb-sg |
| WAF WebACL | llmlite-waf-acl (associated) |
| Deletion Protection | Enabled (production) |
| Access Logs | S3 bucket (optional) |

**Listeners:**

**HTTPS Listener (Port 443):**
- Protocol: HTTPS
- Port: 443
- SSL Policy: ELBSecurityPolicy-TLS13-1-2-2021-06
- Certificate: ACM certificate (*.your-domain.com)
- Default Action: Forward to llmlite-tg
- Rules:
  - Path: /health → Forward to llmlite-tg (public health check)
  - Path: /* → Forward to llmlite-tg (requires virtual key)

**HTTP Listener (Port 80):**
- Protocol: HTTP
- Port: 80
- Default Action: Redirect to HTTPS (301)

**Target Group (llmlite-tg):**
- Name: llmlite-tg
- Target Type: IP (for Fargate)
- Protocol: HTTP
- Port: 4000
- VPC: llmlite-vpc
- Health Check:
  - Protocol: HTTP
  - Path: /health
  - Port: 4000
  - Interval: 30 seconds
  - Timeout: 5 seconds
  - Healthy Threshold: 2
  - Unhealthy Threshold: 3
  - Matcher: 200
- Deregistration Delay: 30 seconds
- Stickiness: Disabled

### 4.4 RDS PostgreSQL (Virtual Keys Storage)

**Purpose:** Store virtual keys, user metadata, and usage tracking with ACID compliance

**Database Configuration:**

| Property | Value |
|----------|-------|
| DB Identifier | llmlite-postgres |
| Engine | PostgreSQL 15.x |
| Instance Class | db.t4g.small (2 vCPU, 2 GB RAM) |
| Storage | 20 GB GP3 SSD (auto-scaling to 100 GB) |
| Multi-AZ | Enabled (automatic failover) |
| Backup Retention | 7 days (automatic backups) |
| Backup Window | 03:00-04:00 UTC |
| Maintenance Window | Sun 04:00-05:00 UTC |
| Encryption | AWS KMS (llmlite-key) |
| Enhanced Monitoring | Enabled (60-second granularity) |
| Performance Insights | Enabled (7 days retention) |
| Deletion Protection | Enabled (production) |
| Port | 5432 |

**Network Configuration:**
- Subnets: database-subnet-2a, database-subnet-2b
- Security Group: rds-sg (allows 5432 from fargate-sg only)
- Public Access: No (private only)
- Endpoint: llmlite-postgres.xxxxxx.eu-west-2.rds.amazonaws.com


**Database:** 

litellm_db

Tables Created by LiteLLM:


### 4.5 LiteLLM Container (Fargate)

**Purpose:** Run LiteLLM proxy server in containerized environment

**Container Specifications:**

| Property | Value |
|----------|-------|
| Base Image | ghcr.io/berriai/litellm:main-latest |
| CPU | 1024 (1.0 vCPU) |
| Memory | 2048 MB |
| Port | 4000 |
| Health Check | /health endpoint |

**ECS Task Definition:**
- Family: llmlite-task
- Network Mode: awsvpc
- Requires Compatibilities: FARGATE
- CPU: 1024 (1.0 vCPU)
- Memory: 2048 MB
- Execution Role: ecsTaskExecutionRole
- Task Role: llmlite-task-role
- Container Port: 4000

**Environment Variables:**
- DATABASE_URL: postgresql://username:password@llmlite-postgres.xxxxxx.eu-west-2.rds.amazonaws.com:5432/litellm_db
- LITELLM_MASTER_KEY: (secure admin key)
- AWS_REGION: eu-west-2
- LITELLM_LOG: INFO
- STORE_MODEL_IN_DB: true
- DATABASE_CONNECTION_POOL_MIN_SIZE: 10
- DATABASE_CONNECTION_POOL_MAX_SIZE: 50

**IAM Task Role Permissions:**
- bedrock:InvokeModel (Claude models only)
- logs:CreateLogStream, logs:PutLogEvents
- s3:PutObject (audit logs bucket)
- kms:Decrypt, kms:GenerateDataKey

**ECS Service Configuration:**
- Service Name: llmlite-service
- Cluster: llmlite-cluster
- Launch Type: FARGATE
- Platform Version: LATEST
- Desired Count: 2
- Deployment Configuration:
  - Maximum Percent: 200
  - Minimum Healthy Percent: 100
  - Deployment Circuit Breaker: Enabled with rollback
- Network Configuration:
  - Subnets: private-subnet-2a, private-subnet-2b
  - Security Groups: fargate-sg
  - Assign Public IP: DISABLED
- Load Balancer: llmlite-tg
- Health Check Grace Period: 60 seconds

**Auto-Scaling Configuration:**
- Min Capacity: 2
- Max Capacity: 5
- Policy Type: Target Tracking Scaling
- Metric: ECS Service Average CPU Utilization
- Target Value: 70%
- Scale In Cooldown: 300 seconds
- Scale Out Cooldown: 60 seconds

### 4.6 Amazon Bedrock

**Purpose:** Anthropic Claude model hosting and inference

**Configuration:**

| Property | Value |
|----------|-------|
| Region | eu-west-2 (Europe - London) |
| Model Access | Request via AWS Console → Bedrock → Model Access |
| Models | Claude 3.5 Sonnet, Claude 3 Opus |
| Endpoint | AWS Bedrock Runtime API |

**Claude Models:**

| Model | ID | Use Case | Input Cost | Output Cost |
|-------|---|----------|------------|-------------|
| Claude 3.5 Sonnet | anthropic.claude-3-5-sonnet-20241022-v2:0 | General-purpose, code, docs | $3/1M tokens | $15/1M tokens |
| Claude 3 Opus | anthropic.claude-3-opus-20240229-v1:0 | Complex reasoning, quality | $15/1M tokens | $75/1M tokens |

**LiteLLM Configuration for Bedrock:**

LiteLLM automatically translates OpenAI-compatible requests to Bedrock API format. Users send requests using model names like "claude-3-5-sonnet" and LiteLLM handles the translation to the full Bedrock model ID.

---

## 5. Network Design

### 5.1 VPC Configuration

**VPC CIDR:** 10.1.0.0/20 (4,096 IP addresses)

> **⚠️ Note:** The `10.1.0.0/20` range covers `10.1.0.0 – 10.1.15.255`. The private subnets (`10.1.11.x`, `10.1.12.x`) fall within this range, but the database subnets (`10.1.21.x`, `10.1.22.x`) fall outside it. Recommend either expanding the VPC to `10.1.0.0/16`, or re-addressing the database subnets to e.g. `10.1.13.0/24` and `10.1.14.0/24`. Please confirm before implementation.

**Subnets:**

| Name | Type | CIDR | AZ | Purpose | IP Range |
|------|------|------|-----|---------|----------|
| public-subnet-2a | Public | 10.1.1.0/24 | eu-west-2a | ALB + NAT | 10.1.1.1 - 10.1.1.254 |
| public-subnet-2b | Public | 10.1.2.0/24 | eu-west-2b | ALB + NAT | 10.1.2.1 - 10.1.2.254 |
| private-subnet-2a | Private | 10.1.11.0/24 | eu-west-2a | Fargate tasks | 10.1.11.1 - 10.1.11.254 |
| private-subnet-2b | Private | 10.1.12.0/24 | eu-west-2b | Fargate tasks | 10.1.12.1 - 10.1.12.254 |
| database-subnet-2a | Database | 10.1.21.0/24 | eu-west-2a | RDS primary | 10.1.21.1 - 10.1.21.254 |
| database-subnet-2b | Database | 10.1.22.0/24 | eu-west-2b | RDS standby | 10.1.22.1 - 10.1.22.254 |

**Route Tables:**

**Public Route Table (public-rt):**
```
Destination       Target
10.1.0.0/20       local
0.0.0.0/0         igw-xxxxxx (Internet Gateway)
```

**Private Route Table AZ 2a (private-rt-2a):**
```
Destination       Target
10.1.0.0/20       local
0.0.0.0/0         nat-xxxxxx (NAT Gateway in AZ 2a - 10.1.1.20)
```

**Private Route Table AZ 2b (private-rt-2b):**
```
Destination       Target
10.1.0.0/20       local
0.0.0.0/0         nat-yyyyyy (NAT Gateway in AZ 2b - 10.1.2.20)
```

**Database Route Table (database-rt):**
```
Destination       Target
10.1.0.0/20       local
(No internet access - isolated for security)
```

### 5.2 Security Groups

**ALB Security Group (alb-sg):**
- Name: llmlite-alb-sg
- VPC: llmlite-vpc
- Inbound Rules:
  - HTTPS (TCP 443) from 0.0.0.0/0 - Allow HTTPS from internet (WAF inspects before ALB)
  - HTTP (TCP 80) from 0.0.0.0/0 - Allow HTTP (redirect to HTTPS)
- Outbound Rules:
  - Custom TCP (Port 4000) to fargate-sg - Forward to Fargate tasks

**Fargate Security Group (fargate-sg):**
- Name: llmlite-fargate-sg
- VPC: llmlite-vpc
- Inbound Rules:
  - Custom TCP (Port 4000) from alb-sg - Allow traffic from ALB only
- Outbound Rules:
  - HTTPS (TCP 443) to 0.0.0.0/0 - Allow outbound to AWS services (Bedrock)
  - PostgreSQL (TCP 5432) to rds-sg - Database access

**RDS Security Group (rds-sg):**
- Name: llmlite-rds-sg
- VPC: llmlite-vpc
- Inbound Rules:
  - PostgreSQL (TCP 5432) from fargate-sg - Allow database access from Fargate only
- Outbound Rules:
  - None (database doesn't initiate outbound connections)

### 5.3 Network Flow

**Inbound Traffic (User → Claude):**
```
User Workstation
    ↓ HTTPS:443 (Internet)
AWS WAF v2 (Regional WebACL: llmlite-waf-acl)
    ↓ Inspect & allow/block request
Internet Gateway
    ↓
Application Load Balancer (Public Subnet: 10.1.1.10, 10.1.2.10)
    ↓ HTTP:4000
Fargate Task - LiteLLM Proxy (Private Subnet: 10.1.11.10, 10.1.12.10)
    ↓ Validate virtual key
RDS PostgreSQL (Database Subnet: 10.1.21.10)
    ↓ TCP:5432 (SELECT query)
Fargate Task - Key validated
    ↓ HTTPS:443 (via NAT Gateway: 10.1.1.20 or 10.1.2.20)
Internet Gateway
    ↓
AWS Bedrock API (eu-west-2)
```

**Database Connection Flow:**
```
LiteLLM Proxy (Private Subnet)
    ↓ TCP:5432 (within VPC - no internet)
RDS PostgreSQL (Database Subnet: 10.1.21.10)
    ↓ SQL Query (SELECT, UPDATE, INSERT)
PostgreSQL Engine processes query
    ↓ Return result set
RDS PostgreSQL → LiteLLM Proxy
    ↓
LiteLLM validates and applies rate limits
```

**Multi-AZ Failover Flow:**
```
RDS Primary (10.1.21.10 in eu-west-2a)
    ↓ Failure detected
AWS RDS Automatic Failover
    ↓ DNS update (30-60 seconds)
RDS Standby promoted to Primary (10.1.22.10 in eu-west-2b)
    ↓ Resume operations
Fargate Tasks reconnect to new primary
```

**Logging Flow:**
```
Fargate Task (Private Subnet)
    ↓ HTTPS:443 (via NAT Gateway)
Internet Gateway
    ↓
S3 Bucket (Audit Logs)

Fargate Task (Private Subnet)
    ↓ Log stream (via NAT Gateway)
Internet Gateway
    ↓
CloudWatch Logs (AWS Service Endpoint)

AWS WAF v2
    ↓ Near real-time log delivery
CloudWatch Logs (aws-waf-logs-llmlite) + S3 (llmlite-waf-logs-{account-id})
```

---

## 6. Security Design

### 6.1 Security Layers

```
┌─────────────────────────────────────────────────────────────────┐
│                    SECURITY ARCHITECTURE                        │
│                                                                 │
│  Layer 0: EDGE PROTECTION (AWS WAF v2)                         │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  • AWS Managed Rules (OWASP Top 10)                     │   │
│  │  • Known Bad Inputs Rule Set                            │   │
│  │  • Amazon IP Reputation List                            │   │
│  │  • Rate-based rules (per-IP throttling)                 │   │
│  │  • Optional geo-blocking                                │   │
│  │  • WAF logs to CloudWatch and S3                        │   │
│  │  • Authorization header redacted from WAF logs          │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  Layer 1: AUTHENTICATION & AUTHORIZATION                       │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  • LiteLLM Virtual Keys (Bearer token)                  │   │
│  │  • Key-based rate limiting (TPM, RPM)                   │   │
│  │  • Budget enforcement per key                           │   │
│  │  • Model access control per key                         │   │
│  │  • Key expiration and revocation                        │   │
│  │  • Admin key for key management operations              │   │
│  │  • PostgreSQL-backed authentication (ACID)              │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  Layer 2: NETWORK SECURITY                                     │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  • VPC Isolation (RFC1918 private addressing)           │   │
│  │  • Security Groups (least privilege)                    │   │
│  │  • Network ACLs (stateless firewall)                    │   │
│  │  • Private Subnets (no direct internet access)          │   │
│  │  • Database Subnets (isolated, no internet)             │   │
│  │  • NAT Gateway (controlled egress)                      │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  Layer 3: TRANSPORT SECURITY                                   │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  • TLS 1.3 (ALB to client)                              │   │
│  │  • ACM Certificate Management                           │   │
│  │  • Strong Cipher Suites Only                            │   │
│  │  • HTTP Strict Transport Security (HSTS)                │   │
│  │  • SSL/TLS for RDS connections (in-transit encryption)  │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  Layer 4: APPLICATION SECURITY                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  • Virtual Key Validation (PostgreSQL lookup)           │   │
│  │  • Rate Limiting (prevent abuse)                        │   │
│  │  • Budget Enforcement (cost control)                    │   │
│  │  • PII Detection & Blocking                             │   │
│  │  • Input Validation                                     │   │
│  │  • Container Image Scanning                             │   │
│  │  • SQL Injection Prevention (parameterized queries)     │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  Layer 5: DATA SECURITY                                        │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  • Encryption at Rest (S3, RDS, CloudWatch)             │   │
│  │  • KMS Customer-Managed Keys                            │   │
│  │  • Automatic Key Rotation                               │   │
│  │  • S3 Bucket Versioning                                 │   │
│  │  • RDS Automated Backups (7 days)                       │   │
│  │  • RDS Multi-AZ (High Availability)                     │   │
│  │  • Database credentials in Secrets Manager              │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  Layer 6: MONITORING & AUDIT                                   │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  • CloudTrail (all API calls logged)                    │   │
│  │  • VPC Flow Logs (network traffic)                      │   │
│  │  • WAF Logs (allowed/blocked requests)                  │   │
│  │  • Application Logs (requests/responses)                │   │
│  │  • RDS Logs (connections, queries, errors)              │   │
│  │  • Immutable Audit Logs (S3)                            │   │
│  │  • Real-Time Alerts (CloudWatch Alarms)                 │   │
│  │  • Per-key usage tracking (PostgreSQL)                  │   │
│  │  • Database Performance Insights                        │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

### 6.2 Authentication Flow (Virtual Keys)

**LiteLLM Virtual Key Authentication Process:**

```
0. AWS WAF v2 inspects incoming HTTP request
   ↓ Block if: IP reputation match, OWASP rule match,
     known bad input, or rate limit exceeded (403)
   ↓ Allow if: no matching rules
1. User Application prepares HTTP request
   ↓
2. User adds Authorization header with virtual key
   - Authorization: Bearer sk-1234...abcd
   - Content-Type: application/json
   ↓
3. Request sent to ALB
   - HTTPS POST /v1/chat/completions
   - TLS 1.3 encrypted connection
   ↓
4. ALB forwards to LiteLLM Proxy
   - SSL termination at ALB
   - HTTP to Fargate task
   ↓
5. LiteLLM extracts virtual key from Authorization header
   - Parse "Bearer sk-1234...abcd"
   - Extract key: "sk-1234...abcd"
   ↓
6. LiteLLM queries RDS PostgreSQL for key metadata
   - SQL: SELECT * FROM litellm_verificationtoken WHERE token = $1
   - Returns: user_id, rate_limits, budget, allowed_models, expires
   ↓
7. LiteLLM validates key and enforces policies
   - Key exists and is_active = true?
   - Key not expired (expires > now)?
   - User within rate limits (TPM, RPM)?
   - User within budget (current_spend < max_budget)?
   - Requested model in allowed_models list?
   ↓
8. If valid: Forward to Bedrock
   - LiteLLM translates OpenAI format to Bedrock format
   - Invoke AWS Bedrock with IAM role credentials
   ↓
9. Update PostgreSQL with usage
   - SQL: INSERT INTO litellm_spend (token, model, tokens, spend, ...)
   - SQL: UPDATE litellm_verificationtoken SET updated_at = now()
   - Transaction committed (ACID guarantee)
   ↓
10. Return response to user
   - Translate Bedrock response to OpenAI format
   - HTTP 200 OK with model output
   
If WAF blocks request:
   - HTTP 403 Forbidden (before reaching application)

If validation fails:
   - HTTP 401 Unauthorized (invalid/expired key)
   - HTTP 429 Too Many Requests (rate limit exceeded)
   - HTTP 403 Forbidden (budget exceeded or model not allowed)
```

### 6.3 Virtual Key Management

**Key Generation (Admin Operation):**

Admins use the master key to generate new virtual keys via the /key/generate endpoint. Each key includes:
- User identifier (email)
- Team identifier
- Rate limits (TPM, RPM)
- Budget limit (USD)
- Allowed models
- Expiration date (optional)

The key is stored in PostgreSQL with a transaction to ensure data consistency.

**Key Rotation:**

Keys should be rotated periodically:
- Generate new key for user
- Provide new key via secure channel
- User updates application configuration
- Monitor old key usage
- Disable old key after grace period (UPDATE is_active = false)
- Archive old key metadata

**Key Revocation:**

To revoke a key immediately:
- Admin calls /key/delete endpoint
- PostgreSQL: UPDATE litellm_verificationtoken SET is_active = false WHERE token = $1
- All subsequent requests with that key are rejected
- Log revocation event to S3 audit log

### 6.4 WAF Operations

**Reviewing Blocked Requests:**

WAF logs can be queried via CloudWatch Logs Insights to identify blocked requests:
- Filter by `action = "BLOCK"` to see all blocked requests
- Group by `terminatingRuleId` to identify which rule is triggering most blocks
- Filter by `httpRequest.clientIp` to investigate specific IP addresses
- Monitor the `BlockedRequests` CloudWatch metric for anomaly detection

**Tuning WAF Rules:**

Rule tuning process:
1. Deploy new managed rules in **Count** mode initially
2. Review counted requests over 1-2 weeks to identify false positives
3. Create rule exclusions for known-good traffic patterns if needed
4. Switch rules to **Block** mode once false positive rate is acceptable
5. Document any exclusions and review quarterly

**IP Allow Listing:**

For known trusted IP ranges (e.g., corporate egress IPs):
- Create a custom IP Set in WAF (e.g., `llmlite-trusted-ips`)
- Add a high-priority Allow rule referencing the IP Set
- This ensures trusted IPs bypass rate-based and managed rules as appropriate

### 6.5 RDS Security

**Database Access Control:**
- Private subnets only (no public access)
- Security group allows 5432 only from fargate-sg
- IAM database authentication (optional)
- Master password stored in AWS Secrets Manager
- Automatic password rotation enabled

**Data Protection:**
- Encryption at rest using KMS (llmlite-key)
- Encryption in transit using SSL/TLS
- Automated backups to S3 (encrypted)
- Multi-AZ deployment for high availability
- Point-in-time recovery (up to 7 days)

**Monitoring and Auditing:**
- Enhanced monitoring (60-second intervals)
- Performance Insights (query analysis)
- CloudWatch Logs integration:
  - postgresql.log (general logs)
  - error.log (error messages)
  - slowquery.log (slow queries > 1s)
- CloudWatch Alarms for CPU, memory, connections, storage

### 6.6 Encryption

**In Transit:**
- TLS 1.3 for all internet-facing connections
- ALB SSL/TLS Policy: `ELBSecurityPolicy-TLS13-1-2-2021-06`
- Certificate from AWS Certificate Manager (ACM)
- HTTPS only (HTTP redirects to HTTPS)
- SSL/TLS for RDS connections (enforced)

**At Rest:**
- RDS PostgreSQL: Encryption with KMS (SSE-KMS)
- S3: Server-side encryption with KMS (SSE-KMS) — including WAF log bucket
- CloudWatch Logs: Encrypted with KMS — including WAF log group
- ECS task storage: EBS encryption enabled
- RDS backups: Encrypted with same KMS key
- KMS key rotation: Annual automatic rotation

**KMS Key Policy:**

The KMS key policy allows:
- Root account full access for management
- RDS, S3, and CloudWatch Logs services to decrypt and generate data keys
- ECS task role to decrypt and generate data keys
- WAF log delivery service to encrypt log data
- Restrict usage to LLMLite services only

### 6.7 IAM Roles and Policies

**ECS Task Execution Role (ecsTaskExecutionRole):**

This role allows ECS to:
- Pull container images from ECR
- Push logs to CloudWatch Logs
- Retrieve secrets from Secrets Manager (RDS password)

**ECS Task Role (llmlite-task-role):**

This role allows the LiteLLM application to:
- Invoke Bedrock models (Claude only)
- Write audit logs to S3
- Write application logs to CloudWatch
- Decrypt data using KMS key
- Access Secrets Manager for RDS credentials

**RDS IAM Policy:**

Optional IAM database authentication allows:
- Connect to RDS using IAM credentials
- No password management required
- Temporary credentials (15-minute expiry)

### 6.8 Rate Limiting and Budget Enforcement

**Rate Limiting:**

LiteLLM supports multiple rate limit types:
- **TPM (Tokens Per Minute):** Limit total tokens processed per minute
- **RPM (Requests Per Minute):** Limit number of requests per minute
- **Budget (USD):** Limit total spend per key

The WAF rate-based rule provides an additional upstream layer of rate limiting at the IP level, complementing LiteLLM's per-key limits.

**Standard User Limits:**
- TPM: 10,000 tokens/minute
- RPM: 100 requests/minute
- Budget: $50/month

**Admin User Limits:**
- TPM: 100,000 tokens/minute
- RPM: 1,000 requests/minute
- Budget: $500/month

**WAF Rate Limit:**
- 2,000 requests per 5-minute window per source IP (blocks before reaching LiteLLM)

**Enforcement:**

LiteLLM tracks usage in PostgreSQL and rejects requests when limits are exceeded. Rate limit counters are stored in the database with timestamps for accurate tracking across multiple Fargate instances. The WAF layer blocks abusive IPs before they consume application resources.

### 6.9 Compliance Considerations

**Data Residency:**
- All data stored in eu-west-2 (Europe - London)
- No cross-border data transfer
- Bedrock models deployed in eu-west-2
- RDS data remains in eu-west-2
- WAF WebACL is regional (eu-west-2)
- Single AWS account architecture

**Audit Requirements:**
- All API calls logged to CloudWatch Logs
- Audit logs written to S3 (immutable)
- WAF logs written to CloudWatch and S3
- CloudTrail enabled for AWS API calls
- RDS query logs enabled (slow queries)
- Log retention: 90 days minimum
- Per-key usage tracking in PostgreSQL

**Data Privacy:**
- PII detection and blocking (optional)
- Virtual keys do not contain user PII
- Authorization header redacted from WAF logs
- User data not shared with third parties
- GDPR consideration: Right to be forgotten support
- Key deletion removes all associated data from PostgreSQL

**Database Compliance:**
- ACID transactions ensure data integrity
- Automated backups for disaster recovery
- Point-in-time recovery capability
- Multi-AZ for high availability
- Encryption at rest and in transit

---

## 7. Operations and Maintenance

### 7.1 Daily Operations

**Morning Health Check:**

Daily operations include:
- Check ECS service status (desired vs running count)
- Verify ALB target health (all targets healthy)
- Review CloudWatch Logs for recent errors
- Check CloudWatch Dashboard for key metrics
- Review any CloudWatch Alarms in ALARM state
- Check RDS instance status (available, healthy)
- Verify RDS Multi-AZ synchronization
- Check database connections (current vs max)
- **Review WAF BlockedRequests metric for anomalous spikes**
- **Check WAF logs for any false positive blocks against legitimate traffic**

**RDS-Specific Checks:**
- Review RDS Performance Insights for slow queries
- Check database CPU and memory utilization
- Verify automated backups completed successfully
- Review RDS logs for connection errors
- Check database storage usage (< 80% threshold)

### 7.2 Weekly Maintenance

**Every Monday:**

1. **Review Cost and Usage:**
   - Check Bedrock token usage for the week
   - Query PostgreSQL for per-key spending
   - Review S3 storage growth (including WAF logs)
   - Analyze Cost Explorer for unexpected charges
   - Review RDS storage growth and forecast

2. **Key Management:**
   - Review active virtual keys in PostgreSQL
   - Check for expired keys (clean up if needed)
   - Review users approaching budget limits
   - Rotate keys for users on 90-day schedule
   - Generate usage reports from PostgreSQL

3. **WAF Review:**
   - Review WAF metrics: AllowedRequests vs BlockedRequests ratio
   - Identify top blocked IPs and rules triggered
   - Assess whether any blocked requests appear to be false positives
   - Review AWS Managed Rule Group update notices and assess impact

4. **Database Maintenance:**
   - Review slow query log in RDS Performance Insights
   - Check for missing indexes (query optimization)
   - Verify backup retention policy
   - Review database connection pool utilization
   - Check for long-running transactions

5. **Log Rotation:**
   - Verify S3 lifecycle policies working (audit logs and WAF logs)
   - Check CloudWatch Logs retention
   - Archive old logs if needed
   - Review RDS log file sizes

6. **Security Review:**
   - Review CloudTrail logs for suspicious activity
   - Check Security Hub findings
   - Review unusual usage patterns (spikes, anomalies)
   - Audit database access logs

### 7.3 Monthly Maintenance

**First Monday of Month:**

1. **Patch Management:**
   - Update LiteLLM container image to latest version
   - Review release notes for breaking changes
   - Deploy new image via rolling deployment
   - Test functionality after update
   - Check for RDS maintenance windows (automatic patching)
   - Review AWS Managed WAF Rule Group version updates

2. **WAF Rule Review:**
   - Review any new AWS Managed Rule Groups available
   - Assess whether additional rule sets should be enabled
   - Review and update custom IP allow/block lists
   - Review geo-blocking configuration if enabled
   - Test WAF rules against sample requests in Count mode before applying changes

3. **Database Optimization:**
   - Run VACUUM ANALYZE on PostgreSQL tables
   - Review and optimize slow queries
   - Add indexes if needed (based on query patterns)
   - Review table statistics and update if stale
   - Check for table bloat and fragmentation

4. **Capacity Planning:**
   - Review auto-scaling metrics (Fargate and RDS)
   - Analyze peak usage patterns
   - Adjust min/max task counts if needed
   - Review RDS instance class (upgrade if needed)
   - Review database storage auto-scaling threshold

5. **Backup and Recovery:**
   - Test RDS snapshot restoration (quarterly)
   - Verify S3 audit logs and WAF logs intact
   - Test infrastructure restore from Terraform
   - Document any configuration changes
   - Update disaster recovery runbook

6. **Cost Optimization:**
   - Review Bedrock usage by model
   - Identify high-usage users
   - Consider adjusting rate limits or budgets
   - Review RDS reserved instance pricing
   - Optimize database storage type (GP3 vs provisioned IOPS)

### 7.4 Quarterly Maintenance

**Quarterly Review:**

1. **Security Audit:**
   - Run AWS Security Hub assessment
   - Review IAM policies and roles
   - Audit virtual key usage logs
   - Review VPC Flow Logs for anomalies
   - Database security audit (user permissions)
   - **Review WAF effectiveness: block rate trends, false positive rate, rule coverage**
   - **Consider adding additional WAF rule groups based on emerging threats**
   - Penetration testing (if required)

2. **Disaster Recovery Test:**
   - Simulate RDS failover (Multi-AZ)
   - Test point-in-time recovery
   - Simulate infrastructure failure
   - Measure RTO and RPO
   - Update runbook based on findings

3. **Performance Tuning:**
   - Analyze CloudWatch metrics trends
   - Optimize container resource allocation
   - Review and adjust rate limits
   - Database query optimization
   - Connection pool tuning

4. **Database Health Check:**
   - Full database integrity check
   - Review replication lag (Multi-AZ)
   - Test automated failover
   - Review backup and restore procedures
   - Update database parameter group if needed

5. **Documentation Update:**
   - Update architecture diagrams
   - Refresh user guides
   - Update operational procedures
   - Document lessons learned
   - Update disaster recovery plan

### 7.5 Virtual Key Management

**Generating a New Key (Admin Operation):**

Admins generate new virtual keys using the master key:
1. Call POST /key/generate with master key in Authorization header
2. Specify user details, rate limits, budget, allowed models
3. LiteLLM inserts record into PostgreSQL (litellm_verificationtoken table)
4. PostgreSQL transaction committed (ACID guarantee)
5. LiteLLM returns virtual key (sk-...)
6. Provide key to user via secure channel (email, password manager)
7. Document key assignment

**Revoking a Key:**

To revoke a virtual key:
1. Call DELETE /key/delete with master key
2. Provide key_id (token) to delete
3. LiteLLM updates PostgreSQL: UPDATE litellm_verificationtoken SET is_active = false
4. All subsequent requests with that key are rejected
5. Log revocation event to S3
6. Notify user of revocation

**Rotating a Key:**

Key rotation process:
1. Generate new key for user
2. Provide new key to user via secure channel
3. User updates application configuration
4. Monitor old key usage in PostgreSQL (grace period)
5. After grace period, revoke old key
6. Archive old key metadata (update is_active = false)

### 7.6 Container Updates

**Updating LiteLLM Version:**

The deployment process includes:
1. Check LiteLLM GitHub releases for new version
2. Review release notes for changes and database migrations
3. Test new version in dev environment
4. Backup RDS database before update
5. Update task definition with new image tag
6. Deploy via ECS service update (rolling deployment, zero downtime)
7. Monitor deployment progress
8. Test API functionality after update
9. Monitor RDS connections and query performance
10. Rollback to previous version if issues detected

### 7.7 Database Operations

**Backup and Restore:**

RDS automated backups:
- Backup window: 03:00-04:00 UTC daily
- Retention: 7 days
- Encrypted with KMS
- Stored in S3 (AWS managed)

Manual snapshots:
- Create before major updates
- Retention: Indefinite (until manually deleted)
- Can be copied to other regions

Point-in-time recovery:
- Restore database to any point in last 7 days
- 5-minute granularity
- Creates new RDS instance


---

## 8. Monitoring and Alerting

### 8.1 CloudWatch Metrics

**Key Metrics to Monitor:**

| Metric | Namespace | Threshold | Action |
|--------|-----------|-----------|--------|
| TargetResponseTime | AWS/ApplicationELB | p95 > 3s | Investigate latency |
| RequestCount | AWS/ApplicationELB | < 10/min | Verify traffic |
| HTTPCode_Target_5XX_Count | AWS/ApplicationELB | > 5% | Check application logs |
| HTTPCode_Target_4XX_Count | AWS/ApplicationELB | Spike | Check auth failures |
| HealthyHostCount | AWS/ApplicationELB | < 1 | Critical - check ECS |
| CPUUtilization | AWS/ECS | > 80% | Scale up tasks |
| MemoryUtilization | AWS/ECS | > 85% | Scale up tasks |
| CPUUtilization | AWS/RDS | > 80% | Scale RDS instance |
| DatabaseConnections | AWS/RDS | > 80% of max | Check connection leaks |
| FreeStorageSpace | AWS/RDS | < 2 GB | Enable auto-scaling or add storage |
| ReadLatency | AWS/RDS | > 100ms | Check slow queries |
| WriteLatency | AWS/RDS | > 100ms | Check indexes, write load |
| ReplicaLag | AWS/RDS | > 1000ms | Multi-AZ sync issue |
| ThrottledRequests | Custom/LiteLLM | > 50/hr | Review rate limits |
| BlockedRequests | AWS/WAFV2 | > 100/5min | Investigate attack or false positives |
| AllowedRequests | AWS/WAFV2 | Sudden drop | Check WAF misconfiguration |

**RDS-Specific Metrics:**
- FreeableMemory: Available RAM for database
- SwapUsage: Memory paging (should be near 0)
- ReadIOPS / WriteIOPS: Disk I/O operations
- NetworkReceiveThroughput / NetworkTransmitThroughput: Network bandwidth
- BinLogDiskUsage: Binary log storage (if enabled)
- TransactionLogsDiskUsage: PostgreSQL WAL logs

**WAF-Specific Metrics (AWS/WAFV2 namespace):**
- AllowedRequests: Total requests permitted through WAF
- BlockedRequests: Total requests blocked by WAF rules
- CountedRequests: Requests matched by Count-mode rules
- PassedRequests: Requests that passed all rule evaluations

### 8.2 CloudWatch Dashboard

**Dashboard Configuration:**

The dashboard includes widgets for:

**Application Metrics:**
- **Request Metrics:** Total requests, 2xx/4xx/5xx counts, success rate
- **Response Time:** p50, p95, p99 percentiles over time
- **Container Utilization:** CPU and memory percentage per task

**WAF Metrics:**
- **WAF Request Summary:** AllowedRequests vs BlockedRequests over time
- **Top Blocked Rules:** Which rule groups are triggering the most blocks
- **Block Rate %:** BlockedRequests / (AllowedRequests + BlockedRequests)

**Database Metrics:**
- **RDS CPU & Memory:** CPUUtilization, FreeableMemory, SwapUsage
- **Database Connections:** DatabaseConnections (current vs max)
- **Query Performance:** ReadLatency, WriteLatency, query throughput
- **Storage:** FreeStorageSpace, usage trend
- **Replication:** ReplicaLag (Multi-AZ sync status)

**Bedrock Usage:**
- **Requests per model:** Claude 3.5 Sonnet vs Claude 3 Opus
- **Token usage:** Input tokens, output tokens over time

**Logs:**
- **Recent Errors:** Filtered logs for ERROR and WARN level messages
- **Database Errors:** RDS error log entries
- **WAF Blocks:** Recent WAF block events with client IP and rule ID

**Key Usage:**
- **Top users by request count:** From PostgreSQL query
- **Top users by token usage:** From PostgreSQL query
- **Budget utilization:** Users approaching budget limits

### 8.3 CloudWatch Alarms

**Alarm Configuration:**

Critical alarms configured:

**WAF Alarms:**

1. **High WAF Block Rate:** Triggers when WAF block count exceeds threshold (potential attack)
   - Metric: BlockedRequests (AWS/WAFV2)
   - Threshold: > 100 blocks in 5 minutes
   - Evaluation Periods: 1
   - Priority: HIGH
   - Action: Investigate WAF logs for attack pattern or false positive

2. **WAF AllowedRequests Drop:** Triggers when allowed requests drop suddenly (potential WAF misconfiguration)
   - Metric: AllowedRequests (AWS/WAFV2)
   - Threshold: < 50% of baseline over 5 minutes
   - Evaluation Periods: 2
   - Priority: HIGH
   - Action: Review WAF rules for misconfiguration, check for outage

**Application Alarms:**

3. **High Error Rate:** Triggers when 5xx errors exceed 5% over 10 minutes
   - Metric: HTTPCode_Target_5XX_Count / RequestCount
   - Threshold: > 5%
   - Evaluation Periods: 2
   - Priority: CRITICAL

4. **High Latency:** Triggers when p95 response time exceeds 3 seconds
   - Metric: TargetResponseTime (p95)
   - Threshold: > 3 seconds
   - Evaluation Periods: 2
   - Priority: HIGH

5. **Unhealthy Targets:** Triggers when fewer than 1 healthy target exists
   - Metric: HealthyHostCount
   - Threshold: < 1
   - Evaluation Periods: 1
   - Priority: CRITICAL

6. **High 401 Rate:** Triggers when 401 errors spike (invalid keys)
   - Metric: HTTPCode_Target_4XX_Count (filtered for 401)
   - Threshold: > 50 in 5 minutes
   - Priority: MEDIUM

**Database Alarms:**

7. **RDS High CPU:** Triggers when database CPU exceeds 80%
   - Metric: CPUUtilization (RDS)
   - Threshold: > 80%
   - Evaluation Periods: 2
   - Priority: HIGH
   - Action: Consider scaling RDS instance

8. **RDS Low Storage:** Triggers when free storage < 2 GB
   - Metric: FreeStorageSpace
   - Threshold: < 2 GB (2,000,000,000 bytes)
   - Evaluation Periods: 1
   - Priority: HIGH
   - Action: Enable storage auto-scaling

9. **RDS High Connections:** Triggers when connections > 80% of max
   - Metric: DatabaseConnections
   - Threshold: > 80% of max_connections (default: 100)
   - Evaluation Periods: 2
   - Priority: MEDIUM
   - Action: Check for connection leaks

10. **RDS High Latency:** Triggers when read or write latency > 100ms
    - Metric: ReadLatency or WriteLatency
    - Threshold: > 100ms
    - Evaluation Periods: 3
    - Priority: MEDIUM
    - Action: Check slow queries in Performance Insights

11. **RDS Replication Lag:** Triggers when Multi-AZ replica lag > 1 second
    - Metric: ReplicaLag
    - Threshold: > 1000ms
    - Evaluation Periods: 2
    - Priority: HIGH
    - Action: Check network or database load

12. **RDS Backup Failure:** Triggers when automated backup fails
    - Metric: BackupRetentionPeriodStorageUsed
    - Threshold: No recent backup
    - Priority: CRITICAL
    - Action: Check RDS events, retry backup

### 8.4 Log Analysis

**Useful CloudWatch Logs Insights Queries:**

**WAF Logs:**

**Top Blocked IPs:**
Filter WAF logs for BLOCK actions and aggregate by client IP to identify top offenders

**Top Triggered Rules:**
Parse WAF logs and count occurrences by terminatingRuleId to identify most active rules

**False Positive Investigation:**
Filter WAF BLOCK events and join with application logs on timestamp and IP to identify legitimate traffic being blocked

**Block Rate Over Time:**
Calculate ratio of blocked to total requests binned by time window to spot attack patterns

**Application Logs:**

**Top Errors:**
Filter logs for ERROR messages and count occurrences by message type

**Top Users by Request Count:**
Parse logs and count requests grouped by user identifier

**Authentication Failures:**
Filter for 401 Unauthorized responses and count by key

**Rate Limited Requests:**
Filter for 429 Too Many Requests responses and count by user

**Budget Exceeded Events:**
Filter for 403 Forbidden (budget) responses and identify users

**Average Response Time by Model:**
Parse logs and calculate average duration grouped by model

**RDS Logs:**

**Slow Queries:**
Filter for queries with duration > 1000ms and display top offenders

**Connection Errors:**
Filter for connection-related errors and count by time window

**Deadlocks:**
Filter for deadlock messages and display details

**Database Usage:**

Query PostgreSQL directly for detailed analytics:

**Total Spend by User:**
Sum spending per user for the last 30 days

**Request Count by Model:**
Count requests and total tokens by model for the last 7 days

**Keys Approaching Budget:**
Identify keys that have used > 80% of their budget

**Active Users Last 24 Hours:**
Count distinct users and their request counts

---
