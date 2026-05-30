# Intune Policy Governance Framework

## TLDR

The Intune Policy Governance Framework turns Microsoft Intune configuration policy sprawl into a governed, reviewable, and repeatable audit result.

Microsoft Intune reporting is good at showing whether assigned policies were deployed successfully to devices. IPG answers a different question: whether the policy estate follows the agreed architectural and governance decisions.

IPG validates current Intune configuration policy state against architect-defined rules for scope boundaries, product ownership, naming, assignment topology, review metadata, assignment safety, lifecycle expectations, and setting-level conflicts.

The framework turns technical policy sprawl into a structured governance problem catalog and action plan. The output is standardized JSON designed for CI/CD, automation, ticketing, remediation, dashboards, and reporting layers.

Sample artifacts:

- [sample JSON audit result](./sample/outputs/outputs/LiveTenant/Output/result.json)
- [sample operational email report](./sample/outputs/LiveTenant/Output/MailReport.png)

The current implementation focuses on modern CSP-based Microsoft Intune configuration policies. The included scopes, products, domains, groups, and policy examples are sample governance data, not framework limitations. The architect defines the actual governance model.

## Why this exists

Microsoft 365 environments rarely become difficult to govern because of one bad policy.

They become difficult to govern because policies grow over time. Projects, pilots, security initiatives, migrations, incidents, temporary exceptions, audits, and urgent fixes all add configuration state.

Individually, those changes may make sense. Collectively, they can create an environment where ownership is unclear, assignments overlap, exceptions become permanent, review metadata goes stale, and nobody can quickly tell what is intentional, accidental, or waiting for architecture, security, IAM, privacy, workplace, or change-management review.

The same pattern appears across Microsoft 365: endpoint management, identity, security, DLP, collaboration platforms, application governance, update rings, groups, privileged access, exclusions, break-glass access, and temporary access models.

The technical implementation differs between those areas, but the governance problem is often the same: ownership, assignment safety, exception control, lifecycle review, change-management alignment, and auditability.

## What the framework does

The framework creates a governance validation layer around policy intent.

Architecture defines the guardrails. Engineering teams keep operational freedom inside those guardrails. The audit detects when policy state drifts outside the agreed model.

The result is a reviewable action plan showing what needs cleanup, what needs ownership clarification, what needs architecture review, and what should be routed through change management.

It turns operational chaos into an actionable governance plan: what to clean up, what to review, what to route, and what to prove.

The framework makes policy state explainable: what exists, why it exists, who owns it, and whether it still fits the agreed model.

It helps answer questions such as:

- Who owns this policy area?
- Which policies are supposed to apply to which scope?
- Which settings are allowed to overlap?
- Which policies are additive?
- Which policies must be mutually exclusive?
- Which assignments are unsafe?
- Which findings can be fixed operationally?
- Which findings need architecture, security, IAM, privacy, workplace, or change-management review?

It helps separate successful deployment from safe deployment, technical validity from governance validity, operational cleanup from architecture decisions, and intended exceptions from accidental drift.

## Output and examples

The audit produces a standardized JSON problem catalog with 3 main branches:

- `Machine` supports CI/CD, automation, ticketing, remediation, dashboards, and reporting integration.
- `Human` supports operator-friendly daily governance review.
- `Documentation` links findings back to the governance model.

The JSON catalog is intentionally separated from presentation and downstream processing. The same result can feed CI/CD gates, automated remediation, ticketing, dashboards, management summaries, compliance evidence, or operational email reporting.

This repository currently includes an implemented operational email report layer.

Examples:

- [sample JSON audit result](./sample/outputs/LiveTenant/Output/result.json)
- [sample operational email report](./sample/outputs/LiveTenant/Output/MailReport.png)

An exported sample dataset is also available for offline validation and testing: [sample exported dataset](./sample/outputs/AllAvailableTestsFromMockedTenant/TestData.json).

## Governance and change management

The configuration model should not be treated only as tool input.

It represents the organization’s governance model in machine-readable form. Policy names, descriptions, assignment models, review metadata, scope boundaries, product ownership, and domain ownership are part of the governance contract.

Policy domains can map to real ownership and consultation boundaries. For example, security-related policy areas may require Security review, identity-related areas may require IAM or Entra ID ownership, privacy and telemetry may require Legal or Privacy input, and user-experience changes may require Workplace Engineering, Support, or Communications.

This helps change management route findings to the right people instead of treating every policy issue as a generic technical issue.

Daily audit detects drift before drift becomes normal. Audit after every change confirms more than deployment success: it confirms that the resulting policy estate still fits the agreed governance model.

It reduces reliance on screenshots, memory, and tribal knowledge by turning policy state into repeatable audit evidence.

It helps make exceptions visible before they silently become permanent and helps surface governance drift before it becomes incident work.

Skipping audits does not remove the pain. It turns governance debt into operational pain: incidents, user complaints, cleanup projects, migration blockers, compliance findings, and security review issues. When that happens, the operational team usually pays the price, even if they did not fully design or own the policy estate.

## Permissions

For read-only audit execution, the expected Microsoft Graph permissions are:

- `DeviceManagementConfiguration.Read.All`
- `DeviceManagementManagedDevices.Read.All`
- `Group.Read.All`
- `GroupMember.Read.All`

For operational email reporting, the execution identity also needs:

- `Mail.Send`

No write permission to Intune configuration policies is required for the audit path.


## Documentation

- [Configuration policy governance model](./docs/ConfigurationPolicyGovernanceModel.md)
- [Configuration policy governance contract](./docs/ConfigurationPolicyGovernanceContract.md)
- [Configuration JSON maintenance](./docs/ConfigurationJsonMaintenance.md)
- [Standard operational procedures](./docs/StandardOperationalProcedures.md)
- [Azure Automation execution model](./docs/AzureAutomation.md)
- [Changelog](./docs/CHANGELOG.md)

## Experience-informed design

This model is informed by practical platform-engineering experience in regulated, highly audited, and high-assurance environments.

The goal is to apply lessons from environments where configuration drift matters, ownership ambiguity creates risk, auditability is required, change control must be explainable, and operational teams need actionable remediation instead of vague reports.


## Professional availability

I am currently open to senior Modern Workplace, Intune, Endpoint Management, Microsoft 365 governance, and platform-engineering roles.

I am also open to project-based work where organizations need help turning Microsoft 365 policy sprawl into a governed, reviewable, and auditable operating model, or validating an existing governance model through repeatable audit evidence.

LinkedIn: <https://www.linkedin.com/in/petertolvaj/>
