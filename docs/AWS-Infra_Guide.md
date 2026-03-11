# AWS Platform Handover Document

**Platform Name:** AI Engineering Lab - Licence Portal Service
**Handover Date:** April 2026
**Version:** 1.0
**Classification:** Internal

---

## 1. Document Purpose & Scope

This document provides the support and maintenance team with the essential context needed to operate, monitor, and maintain the License Portal AWS platform. It covers the system architecture, key infrastructure components, monitoring approach, and operational responsibilities.

This document should be read alongside the operational runbook, which contains step-by-step procedures for common support tasks.

---

## 2. Platform Overview

### 2.1 Business Context
The Licence Portal service is a secure API gateway that provides users with controlled access to Large Language Models (LLMs) available in Amazon Bedrock. The system leverages LiteLLM virtual keys for simple, secure authentication, with key storage in Amazon RDS PostgreSQL for reliability and ACID compliance.

### 2.2 Service Criticality
| Attribute | Detail |
|---|---|
| Criticality Level | High |
| Business Hours | Mon–Fri 08:00–18:00 GMT |
| Target Uptime SLA | 99.9% |
| RPO (Recovery Point Objective) | 1 hour |
| RTO (Recovery Target Objective) | 6 hours |

### 2.3 Environments
| Environment | Purpose | URL / Endpoint |
|---|---|---|
| Production | Live customer-facing platform | https://licenseportal.aiengineeringlab.co.uk/ |
| Staging | Pre-release validation | https://licenseportal.aiengineeringlab.co.uk/ |
| Development | Active development & testing | https://licenseportal.aiengineeringlab.co.uk/ |

---

## 3. Architecture & Infrastructure

### 3.1 High-Level Architecture

![alt text](litellm-architecture.png "High Level Architecture")

Provide a short narrative (3–6 sentences) describing the diagram: how the user request flows through the system, which components handle what, and where the data lives.

#### 3.1.1 Dataflow

![alt text](litellm-dataflow.png "Data Flow Diagram")

Provide a short narrative (3–6 sentences) describing the diagram: how the user request flows through the system, which components handle what, and where the data lives.


### 3.2 AWS Account Details
| Attribute | Detail |
|---|---|
| AWS Account ID | 072136646002 |
| AWS Region (Primary) | eu-west-2 (London) |
| Account Alias | AI Engineering Lab|

### 3.3 Core Infrastructure Components

#### Web Application Layer
| Component | AWS Service | Details |
|---|---|---|
| Web / App Hosting | ECS Fargate | dsit-llmlite-gateway-main-cluster-fg |
| Load Balancing | ALB | dsit-llmlite-gateway-main-alb |
| DNS & CDN | Route 53 | licenseportal.aiengineeringlab.co.uk |
| TLS Certificates | ACM | arn:aws:acm:eu-west-2:072136646002:certificate/d1642eba-70cf-4fcb-96f7-6dc8b1ec0cf4 |

#### Database Layer
| Component | AWS Service | Details |
|---|---|---|
| Primary Database | RDS Aurora | dsit-litellm-rds-pg-prod |
| Read Replicas | Yes | dsit-litellm-rds-pg-prod-instance-1-eu-west-2b |
| Backup Schedule | Daily Automated Snapshots | 7 days |
| Database Secrets | AWS Secrets Manager | aws/rds |

#### Serverless & Supporting Services
| Component | AWS Service | Purpose |
|---|---|---|
| Security operations centre | AWS Security Hub | [Brief description] |
| Application Firewall | Amazon WAF | [Brief description] |
| File storage | S3 | Used for telemetry storage and audit logs |
| LLM Model storage | Amazon Bedrock | [Brief description] |
| AI Security | Amazon Bedrock Guardrails | [Brief description] |

### 3.4 Networking
| Component | Detail |
|---|---|
| VPC ID | vpc-0b5fd89b4223abdc9 |
| CIDR Range | 10.1.0.0/20 |
| Public Subnets | 10.1.1.0/24, 10.1.2.0/24 |
| Private Subnets | 10.1.11.0/24, 10.1.12.0/24, 10.1.21.0/24, 10.1.22.0/24 — application and database tiers |
| NAT Gateway | nat-1766d32e38494d5e2, nat-1374a32db29b24b93 |
| Security Groups (key) | dsit-llmlite-gateway-main-alb-sg, dsit-llmlite-gateway-main-fargate-sg, dsit-llmlite-gateway-main-rds-sg, dsit-llmlite-gateway-main-bedrock-vpce |

### 3.5 Infrastructure as Code
| Attribute | Detail |
|---|---|
| IaC Tool | Terraform |
| Repository | [Link to repo] |
| State Management | S3 dsit-litellm-tfstate + DynamoDb terraform-state-lock |
| Deployment Method | Manual |

---

## 4. Access & Identity

### 4.1 AWS Console Access
| Role / Group | Access Level | Who Has It |
|---|---|---|
| [e.g. PlatformAdmin] | Full admin | [Team / individuals] |
| [e.g. SupportReadOnly] | Read-only | [Support team] |
| [e.g. DeployRole] | Deploy permissions | [CI/CD pipeline] |

> Access is managed via [IAM / AWS SSO / Identity Centre]. Requests for new access should go through [process/contact].

### 4.2 Application & Database Credentials
All secrets are stored in **[AWS Secrets Manager / Parameter Store]**. The support team should never store credentials locally or in plaintext.

| Secret Name | Purpose |
|---|---|
| [secret/prod/db-password] | RDS master password |
| [secret/prod/app-keys] | Application API keys |


---

## 5. Monitoring & Alerting

### 5.1 Monitoring Tools
| Tool | Purpose | Link / Console Location |
|---|---|---|
| Amazon CloudWatch | Metrics, logs, alarms | https://eu-west-2.console.aws.amazon.com/cloudwatch/home?region=eu-west-2#home: |
| AWS Health Dashboard | Service health & events | https://health.console.aws.amazon.com/health/home?region=eu-west-2#/account/dashboard/open-issues |

### 5.2 Key CloudWatch Dashboards
| Dashboard Name | What It Shows |
|---|---|
| Platform-Overview | High-level health: CPU, error rates, request counts |
| Database-Health | RDS connections, query latency, storage |
| Application-Logs | App-level error and warning logs |


### 5.3 Log Locations
| Log Type | Location | Retention |
|---|---|---|
| Application logs | CloudWatch Log Group: `/ecs/[dsit-litellm-gateway-main-task` | 30 Days |
| Database logs | CloudWatch Log Group: `/aws/rds/cluster/dsit-litellm-rds-pg-prod/postgresql` | 7 Days |
| WAF logs | CloudWatch Log Group: `aws-waf-logs-dsit-litellm-prod` | 30 days |


---

## 6. Backup & Recovery

### 6.1 Backup Summary
| Component | Backup Method | Frequency | Retention | Verified |
|---|---|---|---|---|
| RDS Database | Automated snapshots | Daily | 7 days | Yes |
| S3 Buckets | Versioning + replication | Continuous | 30 days | Yes |
| ECS Task Definitions | Stored in IaC repo | On change | Git history | Yes |

### 6.2 Restore Procedure

- **Database restore:** RDS snapshot restore via AWS Console or CLI. Estimated RTO: 3 hours.
- **Application re-deploy:** Trigger pipeline or manually deploy ECS task revision. Estimated RTO: 60 minutes.

---

## 7. Deployment & Change Management

### 7.1 Deployment Process
[Describe at a high level how changes reach production — e.g. "Developers raise a PR, which on merge triggers the CI pipeline to build a new Docker image, push it to ECR, and deploy to ECS." Reference the runbook for detailed steps.]

### 7.2 Deployment Frequency & Freeze Periods
| Attribute | Detail |
|---|---|
| Typical deployment frequency | [e.g. Weekly / On demand] |
| Change freeze periods | [e.g. Dec 20 – Jan 3, major sporting events] |
| Emergency hotfix process | [Brief description or reference to runbook] |

### 7.3 Rollback Approach
[Describe the rollback strategy — e.g. redeploy the previous ECS task definition revision, or restore from a known-good snapshot.]

---

## 8. Known Issues & Technical Debt

Document any known limitations, workarounds, or areas of technical debt the support team should be aware of.

| Issue | Impact | Workaround | Owner / Ticket |
|---|---|---|---|
| [e.g. Manual DB failover required] | [Medium] | [Described in runbook §X] | [JIRA-123] |
| [e.g. No automated certificate renewal tested] | [Low] | [Manual renewal process in runbook] | [JIRA-456] |

---

## 9. Key Contacts & Escalation

### 9.1 Contacts
| Role | Name | Contact | Availability |
|---|---|---|---|
| Platform Owner | [Name] | [Email / Slack] | [Business hours] |
| Lead Engineer | [Name] | [Email / Slack] | [Business hours] |
| On-Call Engineer | [Name / Rotation] | [PagerDuty / Phone] | [24/7] |
| AWS Support | AWS | [Support console link] | [Support tier SLA] |
| Database Admin | [Name] | [Email] | [Hours] |

### 9.2 Escalation Path
1. **L1 Support** — Check dashboards and runbook for known issues.
2. **L2 Support / On-Call Engineer** — Escalate if runbook does not resolve within [X mins].
3. **Platform Owner / Lead Engineer** — Escalate for outages, data issues, or security events.
4. **AWS Support** — Raise a case for suspected AWS service issues (Account ID: [X], Support Plan: [Business / Enterprise]).

---

## 10. Related Documentation

| Document | Location |
|---|---|
| Operational Runbook | [Link] |
| Architecture Decision Records (ADRs) | [Link] |
| IaC Repository | [Link] |
| Incident Log | [Link] |
| AWS Cost & Billing Dashboard | [Link] |

---

## 11. Document Control

| Version | Date | Author | Changes |
|---|---|---|---|
| 1.0 | [Date] | [Author] | Initial handover document |

*This document should be reviewed and updated at each major platform change and no less than every 6 months.*
