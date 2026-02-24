# Terraformer — AWS Infrastructure Import

This project uses [Terraformer](https://github.com/GoogleCloudPlatform/terraformer) to scan an AWS account, filter discovered resources by tags/criteria, and generate Terraform HCL under `generated/aws/`.

## Prerequisites

| Tool | Minimum version | Install |
|---|---|---|
| [Terraform](https://www.terraform.io/downloads) | 1.5.7 | `brew install tfenv && tfenv install` |
| [Terraformer](https://github.com/GoogleCloudPlatform/terraformer) | latest | `brew install terraformer` |
| [jq](https://stedolan.github.io/jq/) | 1.6+ | `brew install jq` |
| [tflint](https://github.com/terraform-linters/tflint) *(optional)* | latest | `brew install tflint` |
| [checkov](https://www.checkov.io/) *(optional)* | latest | `pip install checkov` |
| [pre-commit](https://pre-commit.com/) *(optional)* | latest | `brew install pre-commit` |

> AWS credentials must be configured (e.g. via `AWS_PROFILE`, `aws-vault`, or environment variables) before running any commands.

---

## Quick Start

```bash
# 1. Initialise Terraform providers at the root
make init

# 2. Scan AWS and import filtered resources (uses defaults below)
make plan

# 3. Override tag filter or resource list as needed
make plan TAG_KEY=Title TAG_VALUE=AIEL RESOURCES=sg,vpc,subnet
```

---

## `run_plan.sh` Reference

`run_plan.sh` orchestrates the full Terraformer workflow:

1. Runs `terraformer plan` for regional resources.
2. Runs a separate `terraformer plan` for IAM (global).
3. **Filters** resources from the plan using the strategies below.
4. Runs `terraformer import plan` against the filtered plan(s).

### Filter strategies

| Strategy | Resource types |
|---|---|
| **By tag** (`TAG_KEY=TAG_VALUE`) | `sg`, `vpc`, `subnet`, `aws_lb`, `aws_lb_target_group`, `ecr`, `secretsmanager` |
| **By VPC ID** (derived from matched VPCs) | `network_interface`, `route_table`, `internet_gateway`, `nat_gateway`, `vpc_endpoint` |
| **By VPC ID + Name tag** (excludes AWS defaults) | `nacl` |
| **By ALB ARN** (derived from matched ALBs) | `aws_lb_listener`, `aws_lb_listener_rule` |
| **ECS** — cluster/service by tag; task definitions included in full | `ecs` |
| **RDS** — cluster by ID, instances by tag, non-default subnet groups | `rds` |
| **IAM** — filtered by tag from separate global plan | `iam` |
| **Include all** (no filtering) | `s3`, `wafv2_regional` |

### Default parameters

| Parameter | Default |
|---|---|
| `TAG_KEY` | `Title` |
| `TAG_VALUE` | `AIEL` |
| `RESOURCES` | `sg,vpc,subnet,alb,eni,route_table,igw,nat,nacl,vpc_endpoint,s3,wafv2_regional,ecr,ecs,rds,secretsmanager` |
| `REGION` | `eu-west-2` |
| `RDS_CLUSTER_ID` | `dsit-litellm-rds-pg-prod` |

---

## Generated Output Structure

```
generated/aws/
├── alb/
├── ecr/
├── ecs/
├── eni/
├── iam/
├── igw/
├── nacl/
├── nat/
├── rds/
├── route_table/
├── s3/
├── secretsmanager/
├── sg/
├── subnet/
├── vpc/
├── vpc_endpoint/
└── wafv2_regional/
```

Each module contains:
- `<resource_type>.tf` — resource definitions
- `outputs.tf` — output values (referenced by other modules via `terraform_remote_state`)
- `provider.tf` — provider pinning
- `variables.tf` — input variables (where applicable)

---

## Common `make` Targets

```
make help           # List all targets
make plan           # Run terraformer plan + filter
make fmt            # Format all .tf files
make fmt-check      # Check formatting (CI-friendly)
make validate       # Validate root config
make validate-all   # Init + validate every generated module
make lint           # tflint across all generated modules
make security       # checkov scan of generated/
make pre-commit     # Run all pre-commit hooks
make clean-generated # Delete all generated/ output (destructive)
```

---

## Development Workflow

```bash
# Install pre-commit hooks (one-time)
pre-commit install

# After modifying .tf files, format and validate
make fmt validate

# Run the full quality gate
make pre-commit
```

---

## Notes

- The `generated/` directory is **committed to source control** — it is the versioned record of imported infrastructure.
- `.terraform/` directories (provider binaries) are **not committed** — re-run `terraform init` in any module as needed.
- Terraform state files (`*.tfstate`) are **not committed** — use remote state (e.g. S3 + DynamoDB) for any modules you plan to apply.
