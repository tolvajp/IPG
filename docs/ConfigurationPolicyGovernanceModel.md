# Understanding the Configuration Policy Governance Model

> [!IMPORTANT]
> Policies that do not follow the structure described in this document are reported under **Metadata Parsing Issues**.
>
> These policies are excluded from the remaining audit checks because IPG cannot safely evaluate their assignment topology, review intervals, scope overlap, or setting conflicts. Fix metadata parsing issues first; the rest of the audit result may change afterwards.

## 1. Purpose

This document explains the Configuration Policy Governance Model.

It is not the rule source.

The concrete validation rules are defined in:

`ConfigurationPolicyGovernanceContract.md`

This document explains how to think about the model, why the layers exist, and how to design a policy structure that is understandable, searchable, testable and maintainable.

The goal is not to create more policies.

The goal is to make the chosen operational structure explicit.

---

## 2. The core model

A full policy name follows this structure:

`Scope-Product-Domain-[SubDomain]-Audience-Mode`

`SubDomain` is optional.

The policy name has two logical parts.

First, the governance namespace:

`Scope-Product-Domain-[SubDomain]`

Then, the value delivery model inside that namespace:

`Audience-Mode`

In simple terms:

| Part | Purpose |
|---|---|
| Governance namespace | Where the setting is governed |
| Audience | Who receives which value inside the namespace |
| Mode | Whether values combine or must be exclusive |

Example:

`Workstation-Edge-Security-DownloadRestrictions-Developers-MUX`

Meaning:

| Part | Value |
|---|---|
| Governance namespace | Workstation-Edge-Security-DownloadRestrictions |
| Audience | Developers |
| Mode | MUX |

In plain language:

Download restrictions are governed in the `Workstation-Edge-Security-DownloadRestrictions` namespace.

Developers receive a specific value inside that namespace.

Because the mode is `MUX`, a workstation should receive exactly one effective download restriction value.

---

## 3. Governance namespace

The governance namespace is the most important concept.

It defines where a setting is owned, managed, searched, changed and validated.

A governance namespace is:

`Scope-Product-Domain-[SubDomain]`

Examples:

| Governance namespace | Meaning |
|---|---|
| Workstation-Edge-Security | Edge Security settings managed for workstation devices |
| Workstation-Edge-Security-DownloadRestrictions | Edge download restrictions managed as a dedicated area for workstation devices |
| Workstation-Edge-LegacyCompatibility-InternetExplorerMode | Edge IE mode compatibility managed as a dedicated area for workstation devices |
| Employee-Edge-PlatformIntegration-ExtensionGovernance | Edge extension governance managed for employee users |
| Workstation-BitLocker-Encryption | BitLocker encryption managed for workstation devices |

In this model, setting ownership is evaluated by `SettingDefinitionId`.

A `SettingDefinitionId` can belong to exactly one authoritative governance namespace per Scope.

This means:

`Per Scope, one SettingDefinitionId can belong to exactly one Product-Domain-[SubDomain] namespace.`

The same setting may be handled differently in another Scope if that is an intentional architecture or operations decision.

Example:

`Workstation-Edge-Security-DownloadRestrictions`

`Kiosk-Edge-Security`

This can be valid if kiosk devices have a simpler policy model and do not need a separate DownloadRestrictions SubDomain.

The point is not to force identical structure across all Scopes.

The point is to make the chosen structure intentional.

---

## 4. Architect and operations engineering responsibility

The model separates architectural governance boundaries from operational engineering structure.

This does not mean that operations is a low-trust execution layer.

The operations engineering team may include senior engineers and platform owners who understand how the policy estate is assigned, changed, rolled out, troubleshot and audited in practice.

The architect defines the required governance boundaries, such as:

- Scope
- Product
- Domain
- Mode
- high-level model constraints

Within those boundaries, the operations engineering team may define SubDomains when they improve:

- searchability
- assignment topology
- rollout handling
- exception handling
- day-to-day maintainability
- troubleshooting
- auditability

SubDomain design is an operational engineering design layer.

It is not uncontrolled randomness.

It is also not a low-level service desk execution detail.

A good SubDomain structure captures how the policy estate is actually operated, as long as the architect-defined governance boundaries are respected.

Example:

The architect may require Edge security settings to belong to the `Security` Domain and may require ADD and MUX settings to remain separate.

Inside that boundary, the operations engineering team may decide whether Edge Security should remain at Domain level or be split into SubDomains such as:

- SmartScreen
- DownloadRestrictions
- HTTPSOnly

The architect cares that security configuration stays in the Security Domain and that the model remains valid.

The operations engineering team decides whether additional internal structure is useful for operating the environment.

Many organizations do not have a dedicated architect role for this area. In that case, the same responsibility may be carried by a senior engineer, platform owner, operations lead or engineering team.

The important distinction is not the job title.

The important distinction is between architectural responsibility and operational engineering responsibility, and change management process.

---

## 5. SubDomain decision model

A SubDomain is optional.

A SubDomain is useful when it creates a meaningful operational boundary.

A Domain-level namespace is acceptable when:

- the number of settings is small
- the assignment topology is simple
- there are few or no variants
- ownership is clear
- the Domain is easy to search and understand without further splitting

Example:

`Workstation-BitLocker-Encryption-Baseline-MUX`

For BitLocker, a Domain-level namespace may be enough if the configuration is simple and all workstation devices receive the same encryption model.

A SubDomain becomes useful when complexity appears.

Use a SubDomain when it improves:

- searchability
- ownership clarity
- assignment topology
- rollout handling
- exception handling
- lifecycle management
- validation
- operational understanding

SubDomain is not a taxonomy exercise.

SubDomain is useful when it explains a real operational boundary.

A different deployment axis can justify a SubDomain.

This is a rule of thumb, not an absolute rule.

Do not blindly name SubDomains after the audience dimension.

Weak names:

`DownloadRestrictionsByTeam`

`DownloadRestrictionsByLocation`

Better names describe the actual logical boundary:

`DownloadRestrictionsSmartScreen`

`DownloadRestrictionsExtension`

`InternetExplorerMode`

`ExtensionGovernance`

The concrete groups inside that namespace are Audiences.

Example:

`Workstation-Edge-Security-DownloadRestrictionsSmartScreen-Default-MUX`

`Workstation-Edge-Security-DownloadRestrictionsSmartScreen-Developers-MUX`

Here:

| Part | Meaning |
|---|---|
| DownloadRestrictionsSmartScreen | SubDomain / governance boundary |
| Developers | Audience |

The SubDomain says where the setting is governed.

The Audience says who receives a specific value.

---

## 6. Audience and policy roles

These words describe the role of a policy inside a governance namespace.

| Role | Meaning |
|---|---|
| Baseline | Common configuration shared by all objects in Scope |
| Default | Fallback configuration when specialized Audiences exist |
| Audience | Specialized configuration for a permanent group |
| Rollout | Temporary configuration used to validate a change |

### MUX policy families

MUX means mutually exclusive.

A MUX setting should have exactly one effective value for a target object.

Examples:

- download restriction level
- startup page
- browser sign-in mode
- SmartScreen behavior
- IE mode behavior

In a MUX namespace, use one of these patterns:

`Baseline only`

or:

`Default + specialized Audiences`

Do not use:

`Baseline + specialized Audiences`

That mixes common configuration with mutually exclusive specialized values.

Example baseline-only MUX policy:

`Workstation-Edge-Security-Baseline-MUX`

Example Default + Audience MUX policy family:

`Workstation-Edge-Security-DownloadRestrictions-Default-MUX`

`Workstation-Edge-Security-DownloadRestrictions-Developers-MUX`

`Workstation-Edge-Security-DownloadRestrictions-Marketing-MUX`

### ADD policy families

ADD means additive.

Multiple policies may safely contribute to the final effective configuration.

Examples:

- extension allow lists
- trusted sites
- allow lists
- additive integration lists

In an ADD namespace, use:

`Baseline + Audience additions`

Default is not used in ADD namespaces.

Default is forbidden because there is no exclusive fallback value.

Example ADD policy family:

`Employee-Edge-PlatformIntegration-ExtensionGovernance-Baseline-ADD`

`Employee-Edge-PlatformIntegration-ExtensionGovernance-Developers-ADD`

`Employee-Edge-PlatformIntegration-ExtensionGovernance-Marketing-ADD`

### Rollout

Rollout is used for temporary validation.

A Rollout policy makes temporary change visible.

Example:

`Workstation-Edge-Security-DownloadRestrictions-Rollout202606-MUX`

After validation, the final value should be moved into the permanent policy, for example:

`Workstation-Edge-Security-DownloadRestrictions-Default-MUX`

Then the Rollout policy should be removed.

Rollout is recommended for temporary changes because it is visible and testable.

Whether Rollout is used is an architect or operations engineering decision.

---

## 7. Worked Edge examples

### 7.1 Simple Edge Security baseline

Requirement:

All workstation devices receive the same common Edge security posture.

There are no specialized Audiences.

There is no separate assignment topology.

There is no separate lifecycle.

Policy:

`Workstation-Edge-Security-Baseline-MUX`

Meaning:

| Part | Value |
|---|---|
| Scope | Workstation |
| Product | Edge |
| Domain | Security |
| SubDomain | Not used |
| Audience | Baseline |
| Mode | MUX |

This is acceptable when the Edge Security Domain is simple enough to manage directly.

The policy should contain only settings that share the same:

- ownership
- lifecycle
- assignment model
- exception model
- rollout model

Baseline means:

`common configuration with common ownership and common lifecycle`

It does not mean:

`everything that happens to apply to everyone today`

---

### 7.2 Download restrictions with specialized Audiences

Requirement:

Download restrictions need different values for different groups.

Most workstation devices receive the default value.

Developers and Marketing require different values.

Policies:

`Workstation-Edge-Security-DownloadRestrictions-Default-MUX`

`Workstation-Edge-Security-DownloadRestrictions-Developers-MUX`

`Workstation-Edge-Security-DownloadRestrictions-Marketing-MUX`

Governance namespace:

`Workstation-Edge-Security-DownloadRestrictions`

Audiences:

- Default
- Developers
- Marketing

Mode:

`MUX`

Why this structure makes sense:

Download restrictions now have their own assignment topology.

They are no longer just part of the common Edge Security baseline.

The namespace defines where the SettingDefinitionId is governed.

The Audience defines who receives which value.

---

### 7.3 IE mode by office

Requirement:

Some offices require different IE mode behavior because of legacy application dependencies.

Policies:

`Workstation-Edge-LegacyCompatibility-InternetExplorerMode-Default-MUX`

`Workstation-Edge-LegacyCompatibility-InternetExplorerMode-NewYork-MUX`

`Workstation-Edge-LegacyCompatibility-InternetExplorerMode-Amsterdam-MUX`

Governance namespace:

`Workstation-Edge-LegacyCompatibility-InternetExplorerMode`

Audiences:

- Default
- NewYork
- Amsterdam

Mode:

`MUX`

Important point:

`NewYork` and `Amsterdam` are Audiences.

They are not SubDomains.

The SubDomain is `InternetExplorerMode`.

The location-specific groups receive different values inside that namespace.

---

### 7.4 Extension governance

Requirement:

All employees receive the standard extension governance model.

Developers and Marketing may receive additional approved extensions.

Policies:

`Employee-Edge-PlatformIntegration-ExtensionGovernance-Baseline-ADD`

`Employee-Edge-PlatformIntegration-ExtensionGovernance-Developers-ADD`

`Employee-Edge-PlatformIntegration-ExtensionGovernance-Marketing-ADD`

Governance namespace:

`Employee-Edge-PlatformIntegration-ExtensionGovernance`

Audiences:

- Baseline
- Developers
- Marketing

Mode:

`ADD`

Why this structure makes sense:

Extension governance is additive.

The Baseline policy gives everyone the common model.

Audience policies add extra allowed extensions.

Default is not used because ADD policy families do not need a mutually exclusive fallback.

---

## 8. Bad structure vs better structure

### Bad structure

Policy:

`Workstation-Edge-Security-Baseline-MUX`

Contents:

- common Edge security settings
- developer download restriction values
- marketing download restriction values
- New York IE mode values
- Amsterdam IE mode values
- temporary rollout values
- one-off compatibility exceptions

Problem:

The name says Baseline.

The contents are not baseline behavior.

The policy mixes:

- common settings
- specialized values
- team-specific behavior
- location-specific behavior
- temporary changes
- compatibility exceptions

This makes the policy harder to search, validate, troubleshoot and explain.

The structure looks simple, but it hides operational complexity.

### Better structure

Common Edge security baseline:

`Workstation-Edge-Security-Baseline-MUX`

Download restrictions:

`Workstation-Edge-Security-DownloadRestrictions-Default-MUX`

`Workstation-Edge-Security-DownloadRestrictions-Developers-MUX`

`Workstation-Edge-Security-DownloadRestrictions-Marketing-MUX`

IE mode:

`Workstation-Edge-LegacyCompatibility-InternetExplorerMode-Default-MUX`

`Workstation-Edge-LegacyCompatibility-InternetExplorerMode-NewYork-MUX`

`Workstation-Edge-LegacyCompatibility-InternetExplorerMode-Amsterdam-MUX`

Extension governance:

`Employee-Edge-PlatformIntegration-ExtensionGovernance-Baseline-ADD`

`Employee-Edge-PlatformIntegration-ExtensionGovernance-Developers-ADD`

`Employee-Edge-PlatformIntegration-ExtensionGovernance-Marketing-ADD`

Temporary rollout:

`Workstation-Edge-Security-DownloadRestrictions-Rollout202606-MUX`

Result:

Each policy family has one clear purpose.

The governance namespace shows where the setting is managed.

The Audience shows who receives the value.

The Mode shows whether values combine or must be exclusive.

---

## 9. Potential cross-scope conflicts

The namespace rule is evaluated per Scope.

However, different Scopes may still overlap on the same effective target.

Example:

A device may be in the `Workstation` Scope while the signed-in user is in the `Employee` Scope.

If the same SettingDefinitionId is configured in both a device-scope policy and a user-scope policy, the policies may still affect the same real-world endpoint experience.

The validator may report potential conflicts when the same setting appears in different Scopes that can overlap on the same effective target.

This does not mean every cross-scope occurrence is automatically wrong.

It means the overlap should be reviewed intentionally.

---

## 10. What the validator can and cannot decide

The validator can check structural consistency.

For example, it can detect:

- invalid policy names
- missing or invalid metadata
- unsupported Product, Scope, Domain, Audience or Mode values
- ADD and MUX mixing for the same setting
- Default usage in ADD policy families
- invalid MUX Baseline and Audience combinations
- missing Default policies in MUX Audience models
- the same SettingDefinitionId appearing in multiple governance namespaces per Scope
- potential cross-scope setting conflicts

The validator cannot decide whether the chosen SubDomain structure is architecturally elegant.

It cannot decide whether `DownloadRestrictions` should be split further.

It cannot decide whether a Domain-level BitLocker model is better than a SubDomain-level BitLocker model.

Those are architect and operations engineering decisions.

The validator checks whether the chosen structure follows the contract.

It does not replace engineering judgment.

---

## 11. Design checklist

Before creating or modifying a policy, ask:

### Namespace

What is the governance namespace?

`Scope-Product-Domain-[SubDomain]`

Is this where the SettingDefinitionId should be governed?

### Scope

Is this the correct target population?

### Product

Is this policy configuring only one product?

### Domain

Which governance area owns this setting?

### SubDomain

Is a SubDomain useful?

Use one when it improves:

- searchability
- assignment topology
- lifecycle management
- exception handling
- rollout handling
- validation
- operational clarity

Do not use one just because the model allows it.

### Setting ownership

Does this SettingDefinitionId already belong to another namespace in the same Scope?

If yes, do not manage it here.

A setting may have multiple Audience values.

It must not have multiple governance namespaces per Scope.

### Audience

Who receives which value inside the namespace?

Flat Audiences are recommended.

However, Audience structure is an architect and operations engineering decision.

### Mode

Can multiple policies safely combine?

Use `ADD`.

Must exactly one value be effective?

Use `MUX`.

### MUX check

MUX must be either:

`Baseline only`

or:

`Default + specialized Audiences`

Do not use:

`Baseline + specialized Audiences`

### ADD check

ADD uses:

`Baseline + Audience additions`

Do not use Default in ADD namespaces.

### Rollout check

Is this a temporary change?

If yes, consider Rollout.

Rollout makes temporary state visible and easier to test.

### Final check

Can someone understand the reason for the policy by reading its name?

If not, the structure is probably not clear enough.

