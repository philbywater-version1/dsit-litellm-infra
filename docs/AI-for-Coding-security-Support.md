> ALPHA
> This is a new service. Your [feedback](https://github.com/govuk-digital-backbone/aiengineeringlab/discussions) will help us to improve it.

# AI for coding guidance

> Guidance on the safe and secure use of AI coding assistants for UK government development teams.

## Purpose

This document provides practical guidance for using AI coding assistants safely in UK government. It covers approved tools, security controls and governance requirements for day-to-day development work.

This document defines:

- which AI coding assistants are approved and their data classification limits
- security controls and usage boundaries for AI-assisted development
- copyright, licensing and intellectual property obligations
- governance and audit requirements for projects using AI tools

## Who this is for

This guidance is for:

- developers using GitHub Copilot Enterprise through the AI Engineering Lab
- developers using Microsoft Copilot Chat outside the Lab
- Senior Responsible Officers (SROs) and project leads approving AI tool use
- code reviewers checking AI-assisted pull requests
- information governance and security teams completing risk assessments
- GitHub and platform administrators configuring tool policies

## Contents

Use the links below to navigate to each section.

1. [Overview](#overview)
2. [Approved tools and data classification limits](#approved-tools-and-data-classification-limits)
3. [Secure by design principles](#secure-by-design-principles)
4. [Training exclusion and data retention guarantees](#training-exclusion-and-data-retention-guarantees)
5. [Data processing and infrastructure](#data-processing-and-infrastructure)
6. [Copyright and code matching](#copyright-and-code-matching)
7. [Prohibited content](#prohibited-content)
8. [Security and quality requirements](#security-and-quality-requirements)
9. [Common AI coding risks and mitigation](#common-ai-coding-risks-and-mitigation)
10. [Acceptable and prohibited use cases](#acceptable-and-prohibited-use-cases)
11. [Legal and intellectual property](#legal-and-intellectual-property)
12. [Governance and audit requirements](#governance-and-audit-requirements)
13. [Further information and support](#further-information-and-support)
14. [Quick reference checklist](#quick-reference-checklist)
15. [Related documents](#related-documents)
16. [References](#references)

---

## Overview

[GDS guidance](https://www.gov.uk/government/publications/ai-insights/ai-insights-ai-coding-assistants-for-developers-in-hmg-html) endorses the safe and secure use of AI coding assistants in government.

GitHub Copilot Free is not approved for use in government. It carries significant security, privacy and legal risks. Those not participating in the AI Engineering Lab can use Microsoft Copilot Chat for AI coding support. You can do this by copying code in or uploading scripts as text files.

This guidance implements security controls outlined in the [Security Guidance for AI Coding Assistants](https://www.gov.uk/government/publications/ai-insights). It aligns with National Cyber Security Centre (NCSC) Guidelines for Secure AI System Development. It is grounded in NCSC secure by design principles.

---

## Approved tools and data classification limits

| Tool | Approved for | Maximum data classification | Data processing location | Data retention | Training on private code |
|------|--------------|---------------------------|-------------------------|----------------|-------------------------|
| GitHub Copilot Enterprise | AI Engineering Lab participants only | OFFICIAL | EU and US (configurable, see [data residency note](#where-does-my-code-go)) | Zero retention for code content (see [caveats](#github-copilot-enterprise-what-is-protected)) | Never, contractually excluded |
| Microsoft Copilot Chat | All staff | OFFICIAL | EU and UK | Consult Information Governance (IG) team | Consult IG team |
| GitHub Copilot Free | Prohibited | N/A | N/A | No contractual guarantees | Not by default, but no enterprise Data Processing Agreement (DPA) or contractual safeguards |
| Other public AI tools | Prohibited | N/A | N/A | Unknown | Likely yes |

You must never input OFFICIAL-SENSITIVE, SECRET or TOP SECRET data into any AI coding assistant. You must also never input personal or health information. For the full classification framework, see [guardrails base G-DH-01](../governance/guardrails-base.md#g-dh-01-data-classification-limits).

---

## Secure by design principles

All AI-assisted development must follow [NCSC secure development and deployment principles](https://www.ncsc.gov.uk/collection/developers-collection). AI tools change how code is written, but they do not change the security standards it must meet. For the full evidence framework and audit requirements, see [secure by design evidence for AI-assisted development](../governance/secure-by-design-ai-evidence.md).

The following principles apply to all work that uses AI coding assistants.

| Principle | What this means in practice |
|-----------|----------------------------|
| Security ownership | You remain responsible for all code you produce, including AI-generated code. Your project's Senior Responsible Officer (SRO) is ultimately accountable. AI assistance does not reduce accountability. |
| Secure coding | AI-generated code must meet the same standards as human-written code. Review every line before committing. |
| Security testing | AI-generated code requires the same or greater testing rigour as human-written code. Run SAST tools and submit all changes through peer review. |
| Threat understanding | Document AI-specific risks in your project threat model. Be aware of limitations such as hallucinated dependencies, deprecated methods and insecure patterns. |

The remaining secure by design principles (secure architecture, security monitoring, incident preparedness and continuous improvement) are addressed in the [security and quality requirements](#security-and-quality-requirements), [common risks](#common-ai-coding-risks-and-mitigation) and [governance](#governance-and-audit-requirements) sections of this document.

When using AI tools day to day, you should follow these rules:

- do not input secrets, API keys or personal data into these tools
- do not accept suggestions containing secrets, API keys or personal data
- always review AI-generated code yourself line by line
- require peer review of code through pull or merge requests
- be transparent about your use of AI during development in project documentation

---

## Training exclusion and data retention guarantees

### Why enterprise tiers matter

Free and personal AI tools lack the contractual safeguards that government work requires. GitHub states that Copilot Free does not use code for model training by default. However, the Free tier provides no DPA, no contractual zero-retention guarantees and no organisational admin controls. Vendor policies on free tiers can change without notice. They are not backed by legally binding enterprise agreements. This is why GitHub Copilot Free is prohibited. It lacks the contractual protections needed for government work.

Enterprise tiers provide legally binding commitments that protect departmental code and data. These are not just policies, which can change. They are contractual terms that vendors are obligated to honour.

### GitHub Copilot Enterprise, what is protected

GitHub provides the following contractual commitments:

- private repository code is never used for model training, covering all code, prompts and completions
- zero data retention agreements are in place with all AI model providers used by Copilot ([OpenAI, Anthropic, Google, xAI, Amazon or AWS, Fireworks AI and Microsoft Azure](https://docs.github.com/en/site-policy/privacy-policies/github-subprocessors))
- prompts and completions are processed in-memory only and immediately deleted after processing
- no persistent storage of code content exists for IDE completions and chat, meaning your code is not written to disk, logged or retained
- no human review of code content takes place, meaning vendor personnel at GitHub, OpenAI, Anthropic, Google, xAI, Amazon, Fireworks AI or Microsoft cannot access your prompts or completions for code suggestions
- no model improvement takes place, meaning your code is not used to improve or fine-tune AI models

When you use GitHub Copilot Enterprise, the following steps occur.

1. Your prompt is sent to AI infrastructure.
2. It exists only in random access memory (RAM) during processing.
3. A response is generated and sent back to you.
4. The code content of your prompt and the completion are discarded immediately.

This applies to code completions and chat suggestions accessed through your IDE. The Copilot coding agent works differently. It creates commits and pull requests as part of its workflow, and session logs are retained as part of the GitHub repository and accessible through the GitHub UI. GitHub also collects user engagement data, such as which features you used and whether you accepted a suggestion. This engagement data does not contain your code content.

### Microsoft Copilot Chat, what is protected

Microsoft Copilot Chat provides the following protections:

- prompts and responses are not used to train foundation models when using your organisational account
- your prompts and completions are not stored beyond what is needed for processing
- data is processed within EU and UK regions under the EU Data Boundary

These protections only apply when using your `@.gov.uk` account. Personal Microsoft accounts lack these safeguards.

For specific questions about Microsoft's data handling, contact the IG team.

### What zero data retention actually means

You may hear vendors say they do not 'train on your data' but still retain it for other purposes. Zero data retention for code content is stronger. For IDE code completions and chat, it means that:

- your code content exists only in RAM during processing, typically for seconds
- no logs of your prompts or completions are created or stored
- your code is not written to disk at any point
- vendor support teams cannot access historical prompts or completions
- content is deleted immediately after processing (see [GitHub model hosting documentation](https://docs.github.com/en/copilot/reference/ai-models/model-hosting) for per-provider commitments)

GitHub does collect user engagement data such as feature usage and suggestion acceptance rates. This metadata does not contain your code content and is handled separately under GitHub's privacy terms.

This level of data protection is appropriate for government work at OFFICIAL classification.

### Data retention and training are two different questions

These are separate concerns.

| Question | GitHub Copilot Enterprise | GitHub Copilot Free |
|----------|--------------------------|---------------------|
| Is my code used for training? | No, contractually excluded | Not by default, but no contractual guarantee |
| Is my code retained or stored? | No, zero retention for code content | No contractual zero-retention guarantee |
| Can vendor staff see my code? | No, code content is not retained beyond processing | No contractual safeguard preventing it |
| Can I get documentation? | Yes, DPA available from procurement | No, consumer terms only |

Always verify both training exclusion and data retention when evaluating AI tools.

### Red flags, when a tool is not suitable

Do not use an AI coding tool if any of the following apply:

- the vendor cannot provide written confirmation that private code is excluded from training
- 'enterprise' features are optional add-ons rather than default
- the vendor only commits to 'not training on your data' without specifying retention
- data processing location is unspecified or outside UK, EU or US
- there is no DPA available
- the tool is free or personal-tier

If in doubt, consult IG before using any AI tool not listed in the approved tools table.

---

## Data processing and infrastructure

### Where does my code go?

When you submit a prompt to GitHub Copilot Enterprise, your code travels through the following stages.

1. Your local machine packages relevant context including open files and project structure.
2. The data is transmitted securely to GitHub's processing systems.
3. GitHub forwards it to a model provider such as OpenAI, Anthropic, Google, xAI, Amazon Bedrock, Fireworks AI or Microsoft Azure.
4. The suggestion is sent back to your integrated development environment (IDE).
5. The code content of your prompt and the completion are discarded by the model provider.

GitHub Enterprise Cloud offers [data residency](https://docs.github.com/enterprise-cloud@latest/admin/data-residency/about-github-enterprise-cloud-with-data-residency) in the EU, US, Australia and Japan. However, GitHub's [data pipeline documentation](https://resources.github.com/learn/pathways/copilot/essentials/how-github-copilot-handles-data) notes that traffic is routed based on capacity. It cannot be guaranteed to stay within a single region. Confirm your organisation's data residency configuration with your GitHub administrator.

All data is encrypted using Transport Layer Security (TLS) 1.2 or higher during transmission. Due to zero data retention for code content, no code from your prompts or completions exists 'at rest' in vendor systems. For detailed analysis of data residency, jurisdiction and CLOUD Act exposure, see [data sovereignty and jurisdiction](../policy/data-sovereignty-and-jurisdiction.md).

### What context does the AI see?

GitHub Copilot Enterprise can access the following:

- currently open file
- other open files in your IDE
- file names and directory structure in your project
- code context such as imports and function signatures
- repository metadata such as repo name and branch name
- terminal agent, which allows you to interact with the terminal through GitHub Copilot
- workspace indexing, which allows you to ask questions about the entire project

The scope of context varies by mode. Inline completions typically use only open files. Chat and Agent modes can search across the entire workspace and run terminal commands. In all modes, the AI does not automatically access:

- environment variables or secrets, unless present in open files or workspace code
- your filesystem outside the project
- network resources or databases
- other repositories you have access to

Even though the AI does not automatically grab secrets, you must ensure no sensitive data is present in your workspace files. This is particularly important when using Chat or Agent modes. These modes can access files beyond those currently open in your IDE.

### Network and firewall considerations

GitHub Copilot proxies all requests through GitHub's own infrastructure. Developers do not connect directly to model provider APIs such as OpenAI or Anthropic. Your organisation must allow specific endpoints through firewalls and proxy servers.

The endpoints you need depend on whether your organisation uses standard GitHub Enterprise Cloud on `github.com` or GitHub Enterprise Cloud with data residency on `ghe.com`. Data residency customers use a dedicated subdomain (for example, `your-org.ghe.com`) that is isolated from the wider github.com community. This is the configuration that provides EU data residency.

For organisations on github.com, the key endpoints are:

- `copilot-proxy.githubusercontent.com` for the Copilot suggestion service
- `origin-tracker.githubusercontent.com` for the Copilot suggestion service
- `*.githubcopilot.com` for Copilot API services
- `api.github.com/copilot_internal/*` for user management
- `github.com/login/*` for authentication

For organisations on ghe.com with data residency, the key endpoints are:

- `SUBDOMAIN.ghe.com` and `*.SUBDOMAIN.ghe.com` where SUBDOMAIN is your organisation's dedicated subdomain
- the same `*.githubcopilot.com` and `copilot-proxy.githubusercontent.com` endpoints as above

Firewall teams can use plan-specific subdomains to control which Copilot plan types are permitted on the network:

- `*.enterprise.githubcopilot.com` for Copilot Enterprise
- `*.business.githubcopilot.com` for Copilot Business
- `*.individual.githubcopilot.com` for Copilot Free and Pro

Allowing only `*.enterprise.githubcopilot.com` prevents use of personal or free-tier Copilot accounts on the corporate network. Confirm with your GitHub administrator which endpoints apply to your organisation.

For the full and current allowlist including telemetry and coding agent endpoints, see the [Copilot allowlist reference](https://docs.github.com/en/copilot/reference/allowlist-reference).

---

## Copyright and code matching

### Understanding the risk

AI models are trained on large volumes of public code repositories. When generating suggestions, the AI typically creates new content based on learned patterns. However, in less than 1% of cases, suggestions may closely match existing copyrighted code from public repositories.

Matching code may carry licensing obligations:

- some open source licences require you to credit the original author
- you must comply with the matched code's licence terms, for example GPL, MIT or Apache
- substantial reproduction without appropriate licensing could infringe copyright

When you copy code from Stack Overflow, you know where it came from. With AI suggestions, the provenance is less clear unless you use detection features. This difference in visibility is what makes code referencing important.

### Policy settings for different repository types

GitHub Copilot's copyright protection can be configured at organisation or repository level.

For most OFFICIAL repositories, the default setting applies. This means that:

- code referencing detection is enabled
- suggestions that match public code are shown with attribution
- the developer reviews match information and applies appropriate attribution
- matches are logged for audit purposes

For repositories in projects that handle OFFICIAL-SENSITIVE data, or projects with strict intellectual property (IP) requirements, stricter settings are available. These mean that:

- suggestions matching public code are automatically blocked
- only original AI-generated content is shown
- maximum protection applies but may reduce suggestion usefulness
- administrator configuration is required
- you must never input OFFICIAL-SENSITIVE data itself into the AI tool, as only OFFICIAL code may be submitted as prompts

To request blocking of public code matches for your repository, contact the admin team or AI Engineering Lab coordinators. You will need to provide:

- repository name and classification
- justification for stricter policy
- project SRO approval

### GitHub Copilot Copyright Commitment

GitHub provides legal indemnification for copyright infringement claims related to Copilot output. This applies when all of the following conditions are met:

- you are using GitHub Copilot Enterprise as an AI Engineering Lab participant
- you are using Copilot's built-in filters and safety features, which are enabled by default
- the claim relates to unmodified Copilot suggestions that you have not subsequently changed
- a third party makes a copyright infringement claim against code generated by Copilot

GitHub will cover legal costs and fees to defend the claim, damages awarded if the claim is successful, and settlement costs if appropriate. If someone claims that unmodified Copilot-generated code in your project infringes their copyright, GitHub will cover the legal and financial consequences.

The indemnification does not cover output you have modified, or cases where you knew or should have known the output would infringe existing rights.

This is not a guarantee that matches will never occur. It is financial protection if claims arise despite using the tool appropriately.

For further details, see the [GitHub Copilot Copyright Commitment](https://github.blog/news-insights/product-news/github-copilot-copyright-commitment/).

### Licence compatibility quick reference

When code referencing detects a match, check if the licence is compatible with government work.

| Licence type | Examples | Compatible | Attribution required | Notes |
|--------------|----------|------------|---------------------|-------|
| Permissive | MIT, BSD, Apache 2.0 | Yes | Yes | Safe to use with attribution |
| Copyleft (weak) | LGPL, MPL | Possibly | Yes | Seek legal advice for specific use |
| Copyleft (strong) | GPL, AGPL | Possibly | Yes | May require releasing your code as GPL, seek legal advice |
| Proprietary | Custom licences | Usually no | N/A | Reject unless explicitly permitted |
| Public domain | Unlicense, CC0 | Yes | No | Safe to use without attribution |

When in doubt, reject the suggestion or consult the legal or procurement team.

### Developer responsibilities

When reviewing AI-generated code, you must:

- check for code referencing notifications from GitHub Copilot
- review licence information for any matched code
- verify licence compatibility with your workstream
- apply proper attribution in code comments where required
- document licensing decisions in pull request descriptions
- flag suspicious similarities even if not automatically detected by the tool
- ensure all suggested dependencies are from trusted sources and appropriately licensed

During code review, reviewers should:

- ask whether AI tools were used, which should be documented in the pull request description
- check that appropriate attribution is present for matched code
- verify that copyleft licences have been handled appropriately
- review for code patterns that look like they might be copied from known libraries

### What if you are not sure?

If you encounter AI-generated code and are unsure about copyright or licensing, follow these steps.

1. Check the original source using the link provided in the code referencing notification.
2. Read the licence, as most open source licences are short and readable.
3. Ask in the AI Engineering Lab Teams channel, as others may have encountered similar situations.
4. Consult legal or procurement for GPL or unclear licences.
5. When in real doubt, reject the suggestion and generate an alternative or write it yourself.

### Residual risk

Even with code referencing and copyright protections, some risk remains:

- matching algorithms are not perfect and some similarities may go undetected
- new open source projects are created constantly and the index may not be comprehensive
- generic code patterns may trigger matches even though they are not meaningfully copyrightable
- legal interpretation of 'substantial similarity' is subjective
- licensing obligations may exist even for properly attributed code

These risks are similar to traditional software development. Developers already copy patterns from Stack Overflow, reuse code from previous projects and incorporate open source libraries. All of these carry licensing obligations.

The primary defence is the same. Code review, security scanning, legal review for sensitive projects and open source compliance processes all apply. AI coding assistants do not fundamentally change this risk profile. They may change the frequency or sources of potential matches.

Code referencing features make the provenance more visible than traditional development. This helps you manage IP risk more effectively.

---

## Prohibited content

You must never input any of the following into AI coding assistants:

- any API keys, tokens, passwords or credentials
- database connection strings or configuration files with sensitive parameters
- internal URLs, hostnames or network infrastructure details
- personal data such as names, email addresses, NHS numbers, addresses or phone numbers
- health data or patient information
- commercial information marked as confidential
- code containing OFFICIAL-SENSITIVE, SECRET or TOP SECRET markings
- proprietary third-party code without licence verification

For the complete list of prohibited data types and incident reporting guidance, see [guardrails base G-DH-02](../governance/guardrails-base.md#g-dh-02-prohibited-data-types).

---

## Security and quality requirements

### Before using AI tools

Before starting, you should complete the following steps.

1. Document the use of AI tools in your project's risk register.
2. Complete a Data Protection Impact Assessment (DPIA) if processing personal data or OFFICIAL-SENSITIVE data anywhere in the project. See [DPIA guidance for AI coding assistants](../policy/dpia-ai-coding-assistants.md) for a pre-populated template.
3. Confirm with your line manager and project SRO that AI tool usage is appropriate for your project.
4. Verify all code and data remains within approved classification limits.

### When using AI tools

While working with AI tools, you should follow these rules:

- sanitise inputs by removing all sensitive data, secrets and identifiable information before submitting prompts
- review every line and never accept AI suggestions without understanding what the code does
- validate dependencies by checking that all suggested packages, libraries and versions are current, secure and licensed appropriately
- test thoroughly, as AI-generated code requires the same or greater testing rigour as human-written code

### After using AI tools

After completing your work, you should complete the following steps.

1. Run Static Application Security Testing (SAST) tools on AI-generated code.
2. Submit all AI-assisted code through standard pull or merge request review.
3. Record in commit messages or project documentation when AI was used, for example 'Implemented with GitHub Copilot assistance'.
4. Verify all suggested packages are from trusted sources and have no known vulnerabilities.

---

## Common AI coding risks and mitigation

| Risk | Example | Mitigation |
|------|---------|-----------|
| Hallucinated dependencies | AI suggests non-existent package versions | Always verify package existence before installation |
| Deprecated methods | AI trained on old documentation suggests obsolete APIs | Check official documentation for current methods |
| Licence violations | AI reproduces copyrighted code | Enable code referencing, review matches, apply attribution |
| Security vulnerabilities | AI suggests insecure patterns such as SQL injection prone code | Run security linters and review for OWASP Top 10 issues |
| Logic errors | AI misunderstands requirements | Test edge cases and validate business logic |
| Performance issues | AI suggests inefficient algorithms | Profile and benchmark critical code paths |
| Prompt injection | Malicious instructions in code comments or documents manipulate AI behaviour | Review all AI outputs, include AI configuration files in code review, use supervised modes for sensitive work |
| Malicious Model Context Protocol (MCP) connections | Third-party MCP servers contain vulnerabilities or malicious code | Vet all MCP servers before enabling, disable MCP for OFFICIAL-SENSITIVE work, only use vendor-approved servers |

For a comprehensive threat catalogue with risk ratings and control mappings, see the [threat model](../security/threat-modelling.md).

---

## Acceptable and prohibited use cases

### Acceptable uses

You may use AI coding assistants for:

- generating boilerplate code such as class structures or test templates
- explaining existing code functionality
- suggesting refactoring approaches for sanitised code samples
- writing unit tests for non-sensitive functions
- generating documentation from sanitised code
- debugging syntax errors in anonymised code snippets
- exploring alternative implementations for algorithms

### Prohibited uses

You must not use AI coding assistants for:

- processing production data or real user information
- generating security-critical code such as authentication or encryption without expert review
- analysing logs containing sensitive system information
- creating deployment configurations with real credentials
- processing health data or personally identifiable information
- developing code for systems handling SECRET or TOP SECRET data

---

## Legal and intellectual property

AI-generated code may reproduce copyrighted material. You are responsible for ensuring compliance with relevant licences. Use code referencing features to identify matches and apply proper attribution.

Crown copyright applies to all code you produce as a civil servant. This includes AI-assisted code.

The use of AI tools does not transfer liability. You and your SRO remain accountable for all outputs.

With GitHub Copilot Enterprise, prompts and code are not used for model training due to contractual commitments. With free tools and personal accounts, vendor policies state code is not used for training by default. However, these commitments are not backed by enterprise DPAs and may change without notice.

GitHub provides copyright indemnification for Copilot Enterprise users. This covers legal costs if copyright claims arise from unmodified Copilot suggestions when using the tool with its built-in filters enabled.

---

## Governance and audit requirements

### Project documentation

All projects using AI coding assistants must document the following:

- which AI tools are being used
- what types of tasks AI is being used for
- risk assessment and mitigation measures
- data classification and handling procedures

### Audit trail

You must maintain records of the following:

- when AI tools were used, recorded in commit messages and pull request descriptions
- what prompts were submitted, in sanitised form
- what review processes were applied to AI-generated code
- any security issues discovered in AI-suggested code
- code referencing matches and how they were handled

### Review and approval

SRO approval is required for AI tool usage at project level. All AI-generated code requires peer review before merging. Report any security issues, data leaks or policy violations through normal incident channels.

---

## Further information and support

This guidance should be read in conjunction with the Acceptable Use Policy.

For those taking part in the AI Engineering Lab, there is a dedicated MS Teams channel to share tips and get advice on coding with AI. For anyone else, you can use the [Coding Community of Practice](https://teams.microsoft.com/l/channel/19%3A74b6bd3618f748cdab14f79daf0e0040%40thread.tacv2/Coding%20CoP?groupId=e48fd029-20e5-4501-a622-086d57543c98&tenantId=ee4e1499-4a35-4b2e-ad47-5f3cf9de8666).

---

## Quick reference checklist

### Before submitting code to AI

- [ ] All secrets and credentials removed
- [ ] Personal and health data anonymised or removed
- [ ] Data classification verified as OFFICIAL or lower
- [ ] Internal URLs and system names redacted
- [ ] Using approved enterprise tool, not free tier
- [ ] Working on approved project with SRO consent

### When reviewing AI-generated code

- [ ] Every line reviewed and understood
- [ ] All dependencies verified and current
- [ ] Security scanning completed using SAST tools
- [ ] Licences checked for all suggested packages
- [ ] Code referencing notifications reviewed
- [ ] Attribution applied where required
- [ ] Unit tests written and passing
- [ ] Peer review completed

### Before deploying AI-assisted code

- [ ] Full test suite passed
- [ ] Security vulnerabilities addressed
- [ ] Documentation updated
- [ ] AI usage documented in commits and pull requests
- [ ] SRO approval obtained if required
- [ ] Licence compliance verified

---

## Related documents

### Governance

- [guardrails base](../governance/guardrails-base.md) - baseline security and usage boundaries for AI tool deployments
- [secure by design evidence for AI-assisted development](../governance/secure-by-design-ai-evidence.md) - evidence framework and audit requirements for secure by design compliance
- [security policies](../security/security-policies.md) - organisational security policy for AI coding assistant adoption

### Policy

- [data sovereignty and jurisdiction](../policy/data-sovereignty-and-jurisdiction.md) - data residency, retention and CLOUD Act exposure
- [DPIA guidance](../policy/dpia-ai-coding-assistants.md) - Data Protection Impact Assessment guidance for AI coding assistants

### Security

- [threat model](../security/threat-modelling.md) - threat catalogue and risk assessment for AI coding assistants

### Operational

- [context engineering](../playbooks/context-engineering.md) - techniques for providing effective context to AI code assistants
- [getting started with GitHub Copilot](../user-tool-guides/github-copilot/getting-started.md) - setup and first use guide
- [safe usage guidance](../user-tool-guides/github-copilot/safe-usage-prototyping-vs-production.md) - prototyping versus production environment controls

---

## References

### UK government (tier 1)

- [DSIT Security Guidance for AI Coding Assistants](https://www.gov.uk/government/publications/ai-insights) - comprehensive threat model and adoption guidance
- [NCSC Guidelines for Secure AI System Development](https://www.ncsc.gov.uk/collection/guidelines-secure-ai-system-development)
- [NCSC Secure Development and Deployment](https://www.ncsc.gov.uk/collection/developers-collection) - principles for building and deploying secure software
- [NCSC Cloud Security Principles](https://www.ncsc.gov.uk/collection/cloud-security)

### Vendor (tier 4)

- [GitHub Copilot Trust Center](https://resources.github.com/copilot-trust-center/) - detailed security and privacy documentation
- [GitHub subprocessors](https://docs.github.com/en/site-policy/privacy-policies/github-subprocessors) - official list of AI model providers and data processors
- [GitHub Copilot model hosting](https://docs.github.com/en/copilot/reference/ai-models/model-hosting) - per-provider data retention and training commitments

---

## Document control

| Field | Value |
|-------|-------|
| Version | 1.0.0 |
| Status | Draft |
| Classification | OFFICIAL |
| Owner | AI Engineering Lab |
| Created | 2026-02-17 |
| Updated | 2026-02-23 |
| Review date | 2027-02-17 |

### Version history

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 0.1.0 | 2026-02-17 | AI Engineering Lab | Initial draft |
| 1.0.0 | 2026-02-17 | AI Engineering Lab | Applied repo style alignment, added standard sections |
