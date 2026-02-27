# AWS Infrastructure Runbook — Detailed Configuration

---

## Account Overview

| Property | Value |
|---|---|
| **Primary Region** | eu-west-2 (Europe - London) |
| **Organisation** | AI Engineering Lab (AIEL) - DSIT |
| **Infrastructure Type** | Multi-tier serverless application architecture with Aurora PostgreSQL |

---

## Database Infrastructure

### Aurora PostgreSQL Cluster: `dsit-litellm-rds-pg-prod`

#### Cluster Configuration

| Property | Value |
|---|---|
| **Engine** | Aurora PostgreSQL 17.4 |
| **Database Name** | `litellm` |
| **Deployment** | Aurora Serverless v2 |
| **Storage** | IO-optimized (`aurora-iopt1`) |
| **Encryption** | Enabled (KMS Key: `9f948df5-5bfe-41fa-9e23-84ff6001f63c`) |

#### Instance Details

| Property | Primary Instance | Secondary Instance |
|---|---|---|
| **Name** | `dsit-litellm-rds-pg-prod-instance-1` | `dsit-litellm-rds-pg-prod-instance-1-eu-west-2b` |
| **Instance Class** | `db.serverless` | `db.serverless` |
| **Availability Zone** | eu-west-2a | eu-west-2b |
| **Subnet** | `subnet-052358aaa1ec9d954` | `subnet-0c8c3706a833bcb6f` |

#### Backup Configuration

| Property | Value |
|---|---|
| **Backup Window** | 23:43–00:13 UTC (daily) |
| **Retention Period** | 7 days |
| **Backup Target** | Regional |
| **Copy Tags to Snapshots** | Disabled |

#### Monitoring & Logging

| Property | Value |
|---|---|
| **Performance Insights** | Enabled (7-day retention) |
| **Enhanced Monitoring** | Enabled (60-second intervals) |
| **CloudWatch Logs** | `iam-db-auth-error`, `instance`, `postgresql` |
| **Auto Minor Version Upgrade** | Enabled |
| **Deletion Protection** | ⚠️ Disabled |

#### Subnet Group: `dsit-litellm-rds-pg-subnetgrp`

- **Description:** RDS Aurora Subnet Group for Database subnets
- **Subnets:** Database tier subnets in eu-west-2a and eu-west-2b

---

## Load Balancer Infrastructure

### Application Load Balancer: `dsit-llmlite-gateway-main-alb`

#### Configuration

| Property | Value |
|---|---|
| **Type** | Application Load Balancer (internet-facing) |
| **DNS Name** | `dsit-llmlite-gateway-main-alb-1754853727.eu-west-2.elb.amazonaws.com` |
| **Subnets** | Public subnets in eu-west-2a and eu-west-2b |

#### Listener Configuration

| Property | Value |
|---|---|
| **Protocol** | HTTPS |
| **Port** | 443 |
| **SSL Policy** | `ELBSecurityPolicy-2016-08` |
| **Certificate** | `arn:aws:acm:eu-west-2:072136646002:certificate/d1642eba-70cf-4fcb-96f7-6dc8b1ec0cf4` |

#### Target Group: `dsit-litellm-tg-4000`

| Property | Value |
|---|---|
| **Protocol** | HTTP |
| **Port** | 4000 |
| **Target Type** | IP addresses |
| **VPC** | `vpc-0b5fd89b4223abdc9` |

#### Health Check Configuration

| Property | Value |
|---|---|
| **Protocol** | HTTP |
| **Path** | `/health/liveliness` |
| **Port** | 4000 |
| **Interval** | 30 seconds |
| **Timeout** | 5 seconds |
| **Healthy Threshold** | 5 consecutive checks |
| **Unhealthy Threshold** | 2 consecutive checks |
| **Success Codes** | 200 |

#### Current Targets

| Target | AZ | Status |
|---|---|---|
| `10.1.3.128:4000` | eu-west-2b | ✅ Healthy |

#### Additional Settings

| Property | Value |
|---|---|
| **Cross-zone Load Balancing** | Enabled |
| **HTTP/2** | Enabled |
| **Idle Timeout** | 60 seconds |
| **Deletion Protection** | Disabled |
| **Access Logs** | Disabled |

---

## Storage Infrastructure

### S3 Buckets

| Bucket | Region | Purpose | Versioning | Encryption |
|---|---|---|---|---|
| `dsit-litellm-tfstate` | eu-west-2 | Terraform state management | ✅ Enabled | AWS KMS (SSE-KMS) |
| `config-bucket-072136646002` | eu-west-2 | AWS Config service bucket | Disabled | AES-256 (SSE-S3) |
| `terraform-20260224132347096200000001` | eu-west-2 | Additional Terraform resources | Disabled | AES-256 (SSE-S3) |
| `softcat-finops-072136646002` | us-east-1 | Financial operations / cost management | Disabled | AES-256 (SSE-S3) |

> All buckets have public access blocked and `BucketOwnerEnforced` object ownership.

---

## Network Infrastructure

### VPC Configuration: `dsit-llmlite-gateway-main`

| Property | Value |
|---|---|
| **VPC ID** | `vpc-0b5fd89b4223abdc9` |
| **CIDR Block** | `10.1.0.0/20` (4,096 IP addresses) |
| **DNS Hostnames** | Enabled |
| **DNS Resolution** | Enabled |

#### Subnet Architecture

```
Public Tier (Internet Gateway attached):
├── dsit-llmlite-gateway-main-public-eu-west-2a
│   ├── CIDR: 10.1.0.0/24 (256 IPs)
│   └── AZ: eu-west-2a
└── dsit-llmlite-gateway-main-public-eu-west-2b
    ├── CIDR: 10.1.1.0/24 (256 IPs)
    └── AZ: eu-west-2b

Private Tier (NAT Gateway routing):
├── dsit-llmlite-gateway-main-private-eu-west-2a
│   ├── CIDR: 10.1.2.0/24 (256 IPs)
│   └── AZ: eu-west-2a
└── dsit-llmlite-gateway-main-private-eu-west-2b
    ├── CIDR: 10.1.3.0/24 (256 IPs)
    └── AZ: eu-west-2b

Database Tier (No internet access):
├── dsit-llmlite-gateway-main-database-eu-west-2a
│   ├── CIDR: 10.1.4.0/24 (256 IPs)
│   └── AZ: eu-west-2a
└── dsit-llmlite-gateway-main-database-eu-west-2b
    ├── CIDR: 10.1.5.0/24 (256 IPs)
    └── AZ: eu-west-2b
```

---

## Identity and Access Management

| Property | Value |
|---|---|
| **Total IAM Roles** | 34 (mix of service-linked and custom roles) |
| **Security Groups** | 6 custom security configurations |

**Key Service Roles:**
- Aurora/RDS service roles for monitoring and backups
- Application Load Balancer service roles
- AWS Config service roles
- Terraform execution roles
- Lambda execution roles (if applicable)

---

## Operational Procedures

### 1. Database Management

**Aurora Serverless Monitoring:**
- Monitor Aurora Capacity Units (ACUs) scaling
- Review Performance Insights for query optimisation
- Check backup completion in backup window (23:43–00:13 UTC)
- Monitor connection pooling and database connections

**Database Maintenance Schedule:**

| Frequency | Task |
|---|---|
| **Weekly** | Review Performance Insights dashboard |
| **Monthly** | Analyse slow query logs and optimise |
| **Quarterly** | Review backup retention and test restore procedures |

### 2. Load Balancer Operations

**Health Monitoring:**
- Monitor target health status via Target Groups Console
- Check SSL certificate expiration
- Review access patterns and traffic distribution

**Scaling Operations:**
- Add/remove targets in target group `dsit-litellm-tg-4000`
- Monitor health check endpoint `/health/liveliness`
- Review cross-zone load balancing metrics

### 3. Storage Management

- Monitor Terraform state bucket versioning
- Review access patterns for cost optimisation
- Implement lifecycle policies where appropriate
- Regular backup verification for critical buckets

### 4. Security Management

**Network Security:**
- Review security group rules for database access
- Monitor VPC Flow Logs for unusual traffic patterns
- Ensure database subnets remain isolated
- Regular SSL certificate rotation

**Access Management:**
- Audit IAM roles and their usage
- Review service-linked role permissions
- Monitor AWS Config compliance rules

### 5. Disaster Recovery Procedures

**Database Recovery:**
- Aurora automated backups available for 7 days
- Point-in-time recovery available
- Cross-region backup strategy recommended

**Infrastructure Recovery:**
- Terraform state stored in versioned S3 bucket (`dsit-litellm-tfstate`)
- Infrastructure can be recreated from Terraform configurations
- Load balancer configuration documented in target groups

---

## Monitoring and Alerting

### Key Metrics to Monitor

**Database:**
- Aurora Capacity Units (ACUs)
- Database connections
- Query performance (via Performance Insights)
- Backup success/failure

**Load Balancer:**
- Target health status
- Request count and latency
- HTTP error rates (4xx, 5xx)
- SSL certificate expiration

**Network:**
- VPC Flow Logs for security analysis
- NAT Gateway data transfer costs
- Cross-AZ data transfer

### Recommended CloudWatch Alarms

- Aurora high CPU utilisation
- Load balancer unhealthy targets
- High error rates on ALB
- Database connection threshold exceeded

---

## Cost Optimisation

### Current Architecture Benefits

| Status | Practice |
|---|---|
| ✅ | Aurora Serverless v2 for automatic scaling |
| ✅ | Multi-AZ deployment for high availability |
| ✅ | Proper subnet segmentation for security |
| ✅ | S3 encryption and access controls |

### Recommendations

- Implement S3 lifecycle policies for cost optimisation
- Consider Reserved Capacity for Aurora if usage is predictable
- Enable ALB access logs for traffic analysis
- Implement automated backup lifecycle management

---

## Emergency Contacts and Procedures

| Property | Value |
|---|---|
| **Primary Region** | eu-west-2 |
| **Backup Region** | us-east-1 (FinOps bucket exists) |
| **Critical Services** | Aurora cluster, ALB, Terraform state bucket |
| **Recovery RTO** | ~15–30 minutes (Aurora backup restoration) |

---

## Maintenance Schedule

| Frequency | Task |
|---|---|
| **Weekly** | Review CloudFormation / Terraform stack status |
| **Monthly** | Audit IAM roles and permissions |
| **Quarterly** | Review and optimise resource utilisation |
| **As needed** | Update security group rules and policies |

---

*Document Version: 2.0*
*Last Updated: 27 February 2026*
*Next Review: 27 March 2026*
*Infrastructure Tags: Organisation: DSIT | Title: AIEL | Description: AI Engineering Lab*
