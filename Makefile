.DEFAULT_GOAL := help

REGION       ?= eu-west-2
TAG_KEY      ?= Title
TAG_VALUE    ?= AIEL
RESOURCES    ?= sg,vpc,subnet,alb,eni,route_table,igw,nat,nacl,vpc_endpoint,s3,wafv2_regional,ecr,ecs,rds,secretsmanager

GENERATED_DIR := generated/aws

# ── Help ──────────────────────────────────────────────────────────────────────
.PHONY: help
help: ## Show this help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}' | \
		sort

# ── Terraformer ───────────────────────────────────────────────────────────────
.PHONY: plan
plan: ## Run terraformer plan + filter (TAG_KEY/TAG_VALUE/RESOURCES overridable)
	@chmod +x run_plan.sh
	./run_plan.sh "$(TAG_KEY)" "$(TAG_VALUE)" "$(RESOURCES)"

.PHONY: import-all
import-all: ## Run terraformer import for all resource types in REGION
	terraformer import aws \
		--resources="$(RESOURCES)" \
		--regions="$(REGION)"

# ── Deploy ────────────────────────────────────────────────────────────────────
.PHONY: deploy-all
deploy-all: ## Apply all modules in dependency order (vpc → subnet → ... → ecs/rds)
	@chmod +x deploy.sh
	./deploy.sh

.PHONY: deploy-all-auto
deploy-all-auto: ## Apply all modules non-interactively (--auto-approve)
	@chmod +x deploy.sh
	./deploy.sh --auto-approve

.PHONY: plan-all
plan-all: ## Plan all modules in dependency order (no apply)
	@chmod +x deploy.sh
	./deploy.sh --plan-only

# ── Terraform ─────────────────────────────────────────────────────────────────
.PHONY: init
init: ## Terraform init at project root
	terraform init

.PHONY: fmt
fmt: ## Format all Terraform files (including generated/)
	terraform fmt -recursive .

.PHONY: fmt-check
fmt-check: ## Check formatting without writing changes
	terraform fmt -recursive -check .

.PHONY: validate
validate: ## Validate root Terraform configuration
	terraform validate

.PHONY: validate-all
validate-all: ## Init and validate every generated module
	@for dir in $(GENERATED_DIR)/*/; do \
		echo "--- Validating $$dir ---"; \
		(cd "$$dir" && terraform init -backend=false -input=false -no-color > /dev/null 2>&1 && terraform validate); \
	done

# ── Quality ───────────────────────────────────────────────────────────────────
.PHONY: lint
lint: ## Run tflint on all generated modules (requires tflint)
	@for dir in $(GENERATED_DIR)/*/; do \
		echo "--- Linting $$dir ---"; \
		(cd "$$dir" && tflint --no-color) || true; \
	done

.PHONY: security
security: ## Run checkov security scan on generated/ (requires checkov)
	checkov -d $(GENERATED_DIR) --quiet

.PHONY: pre-commit
pre-commit: ## Run all pre-commit hooks
	pre-commit run --all-files

# ── Utility ───────────────────────────────────────────────────────────────────
.PHONY: clean-generated
clean-generated: ## Remove all generated Terraform output (DESTRUCTIVE)
	@echo "WARNING: This will delete all files under $(GENERATED_DIR)/"
	@read -p "Are you sure? [y/N] " ans && [ "$$ans" = "y" ] || exit 0
	rm -rf $(GENERATED_DIR)/

.PHONY: tree
tree: ## Print the generated directory tree
	@find $(GENERATED_DIR) -name "*.tf" | sort
