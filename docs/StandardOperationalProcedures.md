# Standard Operational Procedures

This document defines operational procedures for using IPG in a company environment.

The procedures are written for operators, service owners, architects, and change owners who use IPG to keep Intune configuration policy governance aligned with approved architecture.

These procedures do not describe how to maintain the IPG repository. They describe how to use IPG when the governed environment changes.

---

# Goal

The purpose of these procedures is to ensure that operational changes remain aligned with approved governance architecture.

IPG is used to turn architectural decisions into machine-readable governance configuration, validate the current Intune state against that configuration, and produce audit evidence for operational review.

Every relevant operational change should end with an IPG validation result proving one of the following:

- the change stayed inside the approved governance model
- the change requires an architectural decision
- the change created findings that must be fixed, accepted, or escalated

---

# Core rule

Any architectural decision that affects governance behavior must be reflected in both the machine-readable configuration file and the human-readable governance contract before the change is considered operationally valid.

Required review:

- configuration.json
- ConfigurationPolicyGovernanceContract.md

The configuration file defines what IPG validates.

The governance contract defines what humans are expected to follow when creating or changing policies.

If the two disagree, the governance model is ambiguous and must be corrected before relying on audit results.

---

# Responsibility model

## Operational changes

Operational changes are usually owned by the endpoint, workplace, platform, or Intune operations team.

Examples:

- adding a new scope group
- adding a new audience group
- changing policy assignments
- introducing a temporary rollout group
- introducing a temporary exception
- updating review dates
- changing company-specific configuration values
- validating policy drift after a change

Operational changes must be validated with IPG.

## Architectural changes

Architectural changes require architecture review before they are operationalized.

Examples:

- introducing a new Scope
- introducing a new Product
- introducing a new Domain
- changing ADD/MUX behavior
- changing the baseline/default/variant model
- changing policy naming rules
- changing ownership boundaries
- changing supported topology behavior

Architectural decisions must be translated into both documentation and configuration.

---

# SOP-01: Operational Configuration Change

## Purpose

Define how company-specific governance configuration changes are requested, reviewed, implemented, and validated.

## Typical triggers

- new department, role, or device population
- new policy scope
- new assignment group
- new exception group
- change in baseline/default/variant logic
- change in policy naming convention
- change in review date or time-bound exception
- change requested through the normal change-management process

## Procedure

1. Identify the business or operational reason for the change.
2. Identify the affected Scope, Product, Domain, SubDomain, Mode, and Audience.
3. Review whether the change is operational or architectural.
4. If architectural, route it for architecture review first.
5. Update configuration.json where required.
6. Update ConfigurationPolicyGovernanceContract.md where required.
7. Apply or adjust the relevant Intune configuration policy or assignment.
8. Run IPG audit.
9. Review the generated problem catalog.
10. Resolve, accept, or escalate every finding.
11. Store or attach the audit result according to the company process.

## Required review

- configuration.json
- ConfigurationPolicyGovernanceContract.md
- current Intune policy assignments
- expected scope groups
- latest IPG audit output

## Expected outcome

The operational change is either validated as compliant with the approved governance model or explicitly escalated because the governance model needs to change.

---

# SOP-02: Architectural Decision Operationalization

## Purpose

Ensure architectural decisions are translated into enforceable governance configuration.

## Typical triggers

- architect defines a new policy Domain
- architect changes ADD/MUX behavior
- architect introduces a new baseline/default/variant model
- architect changes scope ownership
- architect changes exception handling rules
- architect changes policy naming semantics

## Procedure

1. Record the architectural decision in the appropriate architecture or governance process.
2. Determine which governance dimensions are affected.
3. Review ConfigurationPolicyGovernanceContract.md and update the human-readable rules.
4. Review configuration.json and update the machine-readable rules.
5. Confirm whether existing Intune policies need to be renamed, reassigned, split, merged, or retired.
6. Run IPG audit against the current tenant state.
7. Review all findings caused by the architectural change.
8. Create remediation actions for policies, assignments, or groups that no longer match the approved model.
9. Store the audit result as evidence.

## Required review

- configuration.json
- ConfigurationPolicyGovernanceContract.md
- affected Intune policy names
- affected assignment groups
- governance owner mapping
- latest IPG audit output

## Expected outcome

The architectural decision is represented both in human-readable governance documentation and in machine-readable configuration.

---

# SOP-03: Onboarding New Policy Domain

## Purpose

Define how a new governance domain is introduced into the company-specific IPG configuration.

## Typical triggers

- new Intune policy area becomes governed
- new product area is added
- security or compliance introduces a new controlled area
- operational ownership changes
- a previously unmanaged policy family becomes part of governance

## Procedure

1. Define the purpose of the new Domain.
2. Define whether the Domain is ADD or MUX.
3. Define whether the Domain requires Baseline, Default, and Variant policies.
4. Define valid SubDomains if needed.
5. Define valid Audiences if needed.
6. Define naming expectations.
7. Define the responsible owner.
8. Add the Domain to configuration.json.
9. Document the Domain in ConfigurationPolicyGovernanceContract.md.
10. Review existing Intune policies that may already belong to the Domain.
11. Run IPG audit.
12. Review and remediate findings.

## Required review

- governance ownership model
- configuration.json
- ConfigurationPolicyGovernanceContract.md
- current Intune policies in the same functional area
- latest IPG audit output

## Expected outcome

The new Domain is clearly defined, documented, represented in configuration, and validated against the existing tenant state.

---

# SOP-04: Onboarding New Scope or Audience

## Purpose

Define how new user or device populations are added to governance.

## Typical triggers

- new business unit
- new department
- new admin population
- new device type
- new country or site
- new contractor, guest, or external population
- new high-risk user group
- new rollout or pilot population

## Procedure

1. Define the business purpose of the Scope or Audience.
2. Determine whether it applies to users, devices, or both.
3. Identify or create the authoritative Entra group.
4. Confirm group ownership.
5. Confirm membership rules.
6. Confirm whether the group is mutually exclusive with other scope groups.
7. Add the Scope or Audience to configuration.json.
8. Update ConfigurationPolicyGovernanceContract.md where required.
9. Review affected policy assignments.
10. Run IPG audit.
11. Review findings related to group membership, assignment, and naming.

## Required review

- authoritative Entra group
- group ownership
- group membership logic
- configuration.json
- ConfigurationPolicyGovernanceContract.md
- affected policy assignments
- latest IPG audit output

## Expected outcome

The new Scope or Audience can be used in policy governance without creating ambiguous assignment or ownership behavior.

---

# SOP-05: Time-Bound Exception Review

## Purpose

Ensure temporary exceptions are reviewed before they become permanent drift.

## Typical triggers

- temporary exception requested
- temporary variant created
- exception review date approaching
- audit flags expired review date
- emergency workaround needs formal review
- project-specific deviation from the standard model

## Procedure

1. Identify the exception and its owner.
2. Review the original business justification.
3. Review the affected policy, group, Scope, Domain, and Audience.
4. Determine whether the exception is still required.
5. Decide one of the following outcomes:
   - remove the exception
   - extend the exception with a new review date
   - convert the exception into a permanent governed variant
   - escalate to architecture or security review
6. Update configuration.json if required.
7. Update ConfigurationPolicyGovernanceContract.md if the governance model changes.
8. Run IPG audit.
9. Store the result as evidence.

## Required review

- exception owner
- original justification
- review date
- affected policy or assignment
- configuration.json
- ConfigurationPolicyGovernanceContract.md
- latest IPG audit output

## Expected outcome

Temporary exceptions remain visible, reviewed, and controlled.

---

# SOP-06: Governance Audit Review

## Purpose

Define how daily or change-triggered IPG audit output is reviewed operationally.

## Typical triggers

- scheduled daily audit
- post-change validation
- pre-release validation
- incident investigation
- drift investigation
- change-management evidence request

## Procedure

1. Open the latest IPG audit output.
2. Review findings in the machine-readable branch for automation or tracking.
3. Review findings in the human-readable branch for operational triage.
4. Group findings by owner, Scope, Domain, or severity where applicable.
5. Decide an outcome for each finding:
   - fixed immediately
   - assigned to an owner
   - accepted with justification
   - escalated to architecture
   - escalated to security
   - linked to an existing change record
6. Track unresolved findings according to the company process.
7. Store the audit output as operational evidence.

## Findings to review

- expired exceptions
- policies assigned to empty groups
- invalid policy names
- objects in multiple mutually exclusive scope groups
- mixed ADD/MUX assignment conflicts
- policies violating configured architecture
- policies missing expected governance metadata
- policies outside the approved naming or assignment model

## Expected outcome

Every audit finding has a clear operational disposition.

---

# SOP-07: Change Management Integration

## Purpose

Define how IPG governance output supports the company change process.

## Typical triggers

- planned Intune policy change
- new policy rollout
- scope expansion
- emergency policy change
- policy remediation after an audit finding
- architecture-driven governance change

## Procedure

1. Identify whether the change affects governed Intune configuration.
2. Identify the affected Scope, Product, Domain, SubDomain, Mode, and Audience.
3. Attach or reference the latest pre-change IPG audit output where applicable.
4. Implement the approved change.
5. Run IPG audit after the change.
6. Attach or reference the post-change IPG audit output.
7. Confirm whether the change stayed inside the approved governance model.
8. Escalate if the change requires architecture documentation or configuration updates.

## Required review

- change record
- affected governance dimensions
- pre-change audit output
- post-change audit output
- configuration.json if governance behavior changed
- ConfigurationPolicyGovernanceContract.md if architectural rules changed

## Expected outcome

The change record shows whether the change remained inside the approved governance model or required architectural review.

---

# SOP-08: Rollout Change

## Purpose

Define how staged rollout changes are handled without creating unmanaged policy drift.

## Typical triggers

- pilot rollout
- production rollout
- ring expansion
- staged deployment to departments
- temporary rollout group introduced
- rollout group retired

## Procedure

1. Define the rollout purpose.
2. Define the rollout population.
3. Confirm whether the rollout group is temporary or permanent.
4. Confirm whether the rollout changes governance behavior or only assignment timing.
5. Update configuration.json if the rollout group is part of the governance model.
6. Update ConfigurationPolicyGovernanceContract.md if the rollout model changes the documented process.
7. Apply or adjust policy assignments.
8. Run IPG audit.
9. Review assignment and scope findings.
10. Remove or update temporary rollout groups after rollout completion.

## Expected outcome

Rollout activity remains visible and does not become permanent unmanaged configuration drift.

---

# SOP-09: Emergency Change and Rollback

## Purpose

Define how urgent policy changes are handled when normal governance review cannot be completed before implementation.

## Typical triggers

- security incident
- production outage
- broken policy assignment
- user-impacting misconfiguration
- urgent vendor or compliance requirement
- emergency rollback

## Procedure

1. Record why emergency handling is required.
2. Identify the affected policy, assignment, Scope, Domain, and owner.
3. Apply the minimum required change.
4. Record the temporary deviation from normal governance.
5. Run IPG audit as soon as possible after the emergency change.
6. Review findings caused by the emergency change.
7. Decide whether to:
   - roll back
   - keep temporarily with a review date
   - convert into a governed configuration change
   - escalate to architecture or security
8. Update configuration.json and ConfigurationPolicyGovernanceContract.md if the change becomes part of the approved model.
9. Store audit output and decision evidence.

## Expected outcome

Emergency changes are allowed when required, but they must not remain invisible or unmanaged.

---

# SOP-10: Evidence Handling

## Purpose

Define how IPG output is handled as operational evidence.

## Typical triggers

- daily audit run
- change validation
- compliance review
- internal audit
- security review
- architecture review
- management reporting

## Procedure

1. Generate or collect the relevant IPG output.
2. Confirm the audit date and source environment.
3. Store the output in the approved evidence location.
4. Link the output to related change records, incidents, reviews, or decisions where applicable.
5. Keep machine-readable output available for automation and reporting.
6. Keep human-readable output available for operational review.
7. Do not manually edit audit output used as evidence.
8. If a summary is created, keep the original output available.

## Expected outcome

IPG output can be used as reliable evidence for operational, architectural, and compliance review.

---

# Operational validation checklist

Use this checklist after any governed operational change.

- Was the affected Scope identified?
- Was the affected Product identified?
- Was the affected Domain or SubDomain identified?
- Was the affected Mode identified?
- Was the affected Audience identified?
- Was configuration.json reviewed?
- Was ConfigurationPolicyGovernanceContract.md reviewed?
- Was the Intune policy assignment reviewed?
- Was the relevant Entra group reviewed?
- Was IPG audit executed?
- Were findings reviewed?
- Were findings fixed, accepted, assigned, or escalated?
- Was the audit output stored or attached as evidence?

---

# Decision guide

Use this guide when deciding whether a change is operational or architectural.

## Usually operational

- adding a group that already fits an existing Scope
- updating a review date
- adding a policy that follows existing naming rules
- assigning a policy according to the existing model
- removing an expired exception
- remediating an audit finding without changing the governance model

## Usually architectural

- adding a new Scope
- adding a new Domain
- changing ADD/MUX behavior
- changing baseline/default/variant behavior
- changing naming semantics
- changing ownership boundaries
- changing how exceptions are governed
- accepting a pattern that the current governance model does not support

---

# Expected operational rhythm

Recommended usage pattern:

1. Run IPG on a schedule.
2. Run IPG after governed Intune changes.
3. Review findings operationally.
4. Escalate model gaps to architecture.
5. Keep configuration.json and ConfigurationPolicyGovernanceContract.md aligned.
6. Use audit output as evidence in change management, reporting, and governance review.

---

# Summary

IPG should be used as an operational control between architecture and Intune implementation.

The governance contract explains the approved human-readable model.

The configuration file defines the machine-readable model.

The audit output shows whether the tenant still follows the approved model.

A change is not complete until the affected governance model has been reviewed and the audit result has been handled.