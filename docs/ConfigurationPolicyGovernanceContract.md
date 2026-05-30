# Disclaimer

This is a template document for the current policy name and description regex.

The exact naming and description pattern may vary by company naming standardss set in src\IPG\Config\configuration.json

---


# Configuration Policy Governance Contract

This document defines the decision path for creating governed Intune configuration policies.

Use it when creating or changing a policy.

The decisions in this document define:

- policy name
- policy description
- assignment model
- architecture review requirement

The policy name and description are not cosmetic metadata. They are part of the governance contract used by the audit.

For PowerShell usage, validation internals, reason codes, dataset mode, and troubleshooting, see:

```text
src/IPG/README.md
```

## 1. Scope

Scope defines the broad user or device population.

Select one of the available options:

- Workstation
- Employee
- Admin
- Contractor

Contract:

- Scope must represent the intended target population.
- Policies must not silently cross Scope boundaries.
- A new Scope is an architecture decision.

Note:

In a larger enterprise model, Scope could also include boundaries such as SharedDevice, Kiosk, VDI, or Guest.

## 2. Product

Product defines the product or platform area controlled by the policy.

Select a Product that is valid for the selected Scope:

| Scope | Available Products |
|---|---|
| Workstation | Windows, Edge, Defender |
| Employee | Edge |
| Admin | Edge |
| Contractor | Edge |

Contract:

- Product must be valid under the selected Scope.
- Policies should not mix unrelated Product areas.
- A new Product under a Scope is an architecture decision.

## 3. Domain

Domain defines the governance and ownership boundary inside the selected Product.

Select a Domain that is valid for the selected Scope and Product:

| Scope | Product | Available Domains |
|---|---|---|
| Workstation | Windows | Security, UpdateServicing, PlatformOperations |
| Workstation | Edge | Security, IdentityProfile, PlatformIntegration, UserExperience |
| Workstation | Defender | Prevention, AttackSurfaceReduction, DetectionResponse |
| Employee | Edge | Security, IdentityProfile, PlatformIntegration, UserExperience |
| Admin | Edge | Security, IdentityProfile, PlatformIntegration, UserExperience |
| Contractor | Edge | Security, IdentityProfile, UserExperience |

Contract:

- Domain must be valid under the selected Scope and Product.
- Domain is an ownership boundary, not naming decoration.
- A new Domain is an architecture decision.
- If a setting could reasonably belong to multiple Domains, architecture review is required.


Note:
May include consultation matrix like:

| Domain | Possible stakeholders |
|---|---|
| Security | Security, Workplace Engineering |
| IdentityProfile | IAM, Entra ID owners, Workplace Engineering |
| PrivacyTelemetry | Security, Legal, Privacy |
| PlatformIntegration | Workplace Engineering, application/platform owners |
| UserExperience | Workplace Engineering, Support, Communications |
| UpdateServicing | Workplace Engineering, Operations |
| PlatformOperations | Workplace Engineering, Operations |
| Prevention | Security, Defender owners |
| AttackSurfaceReduction | Security, Defender owners |
| DetectionResponse | Security, SOC, Defender owners |

The consultation mapping is guidance. The actual RACI model should be maintained by the architecture and change-management process.

## 4. SubDomain

SubDomain is optional specialization inside a Domain.

Common patterns include SmartScreen, Extensions, Homepage, DownloadRestrictions, BrowserSignin, UpdateRings, DriverUpdates, or ASRRules.

Contract:

- SubDomain may be skipped when the Domain is already precise enough.
- SubDomain may be as narrow as a single setting area.
- When present, SubDomain becomes part of the governance namespace.
- SubDomain must not be used to hide a missing Domain or new ownership boundary.
- If a SubDomain creates a new ownership area, architecture review is required.

Different namespaces:

```text
Workstation-Edge-Security
Workstation-Edge-Security-SmartScreen
Workstation-Edge-Security-DownloadRestrictions
```

Note:
Subdomains may exist in different deployment coordinate than domain. FE Domain deployed per location, subdomain deployed  per function or vica versa.

## 5. Mode

Mode defines conflict behavior.

Select one of the available options:

- ADD
- MUX

| Mode | Meaning |
|---|---|
| ADD | Multiple policies may contribute additive configuration |
| MUX | Only one effective configuration should exist |

Use ADD for cumulative configuration such as allow lists, approved extensions, trusted sites, or approved integrations.

Use MUX for single-effective-state configuration such as SmartScreen behavior, browser sign-in behavior, download restriction level, startup page behavior, or camera access.

Contract:

- Mode must be selected from the available options above.
- ADD and MUX settings must not be mixed in one policy.
- If ADD vs MUX is unclear, architecture review is required.

## 6. Audience for ADD policies

ADD policies contain settings where multiple policies may combine safely.

ADD has two audience patterns:

| Audience | Function | Include | Exclude |
|---|---|---|---|
| Baseline | Common additive configuration shared by the full Scope | Scope group | None |
| Custom Audience | Additional additive configuration for a specific audience | Audience group | None |

Contract:

- ADD Baseline is used for common additive configuration.
- ADD Custom Audience is used for additional audience-specific additive configuration.
- Default is not valid for ADD.
- Rollout is not part of the ADD audience model.
- ADD policies should not rely on exclusions.
- Custom Audience values must represent real permanent business or technical needs.

Valid ADD audience examples:

```text
Baseline
Developers
Marketing
EMEA
```

Invalid ADD audience examples:

```text
Default
RolloutPilot
```

## 7. Audience for MUX policies

MUX policies contain settings where only one effective value should exist.

MUX has four audience patterns:

| Audience | Function | Include | Exclude |
|---|---|---|---|
| Baseline | Same configuration for the full Scope | Scope group | Rollout groups |
| Default | Fallback configuration when Custom audiences exist | Scope group | Custom and Rollout groups |
| Custom Audience | Permanent specialized configuration | Audience group | Rollout groups |
| Rollout* | Temporary override for rollout or emergency change | Rollout group | None |

Contract:

- MUX Baseline is used when the same configuration applies to the full Scope.
- If MUX Custom Audiences exist, MUX Default must exist.
- MUX Baseline must not coexist with permanent MUX Default or Custom Audience policies in the same governance namespace.
- MUX Custom Audience must represent a permanent business or technical need.
- MUX Rollout* must remain temporary and reviewable.
- MUX Rollout* is for temporary validation or override of existing Baseline or Default behavior.
- MUX Rollout* is not for creating new permanent specialized audiences.

Valid MUX audience examples:

```text
Baseline
Default
Developers
EMEA
RolloutPilot
RolloutEmergency
```

Audience values must not contain hyphens because hyphen is the policy-name segment separator.

Invalid MUX audience examples:

```text
Rollout-Pilot
Rollout-Emergency
```

## 8. Policy name

The policy name is part of the governance contract.

Allowed structures:

```text
[Scope]-[Product]-[Domain]-[Audience]-[Mode]
[Scope]-[Product]-[Domain]-[SubDomain]-[Audience]-[Mode]
```

Examples:

```text
Employee-Edge-PlatformIntegration-Extensions-Baseline-ADD
Employee-Edge-PlatformIntegration-Extensions-Developers-ADD
Workstation-Edge-Security-SmartScreen-Baseline-MUX
Workstation-Edge-Security-SmartScreen-Default-MUX
Workstation-Edge-Security-SmartScreen-Developers-MUX
Workstation-Edge-Security-SmartScreen-RolloutPilot-MUX
```

Contract:

- The name must expose Scope, Product, Domain, optional SubDomain, Audience, and Mode.
- The name must be understandable without opening the policy.
- Scope, Product, Domain, and Mode must match the governance configuration.
- Do not use extra hyphens inside any segment.

## 9. Description

The policy description is lifecycle metadata.

It is not a free-text comment field.

Required structure:

```text
[ReviewDate]|[TicketNumber]|[PolicyReason]
```

Example:

```text
31-12-2026|CHG-123456|Default SmartScreen configuration for managed workstations.
```

Contract:

- ReviewDate is mandatory.
- ReviewDate must use `dd-MM-yyyy`.
- TicketNumber is mandatory.
- PolicyReason is mandatory.
- PolicyReason must explain why the policy exists.
- Weak reasons such as `Test`, `Needed`, or `Security setting` are not acceptable.

## 10. Architecture review

Architecture review is required when the change modifies or bypasses the governance model.

Request architecture review when:

- a new Scope, Product, or Domain is needed
- a setting could belong to multiple Domains
- a policy crosses Scope boundaries
- ADD vs MUX is unclear
- the same setting appears in multiple governance namespaces
- a Custom Audience changes the operating model
- regional, functional, or platform teams may create conflicting intent
- Default coverage cannot be designed cleanly
- stakeholder consultation is unclear

Do not hide architecture decisions inside SubDomains, assignments, exclusions, or naming tricks.

## 11. Audit

Run the audit after creating or changing the policy.

The policy should be technically valid in Intune and valid against the governance model.

Expected audit confirmation:

- valid name
- valid description
- valid Scope/Product/Domain combination
- valid Mode and Audience
- valid assignment topology
- expected coverage exists
- valid lifecycle metadata
- no unmanaged ownership ambiguity
- no unmanaged drift

## Final checklist

Before creating or changing a governed policy, confirm:

- Scope selected from the available options
- Product selected from the available options for that Scope
- Domain selected from the available options for that Scope and Product
- SubDomain selected or intentionally skipped
- ADD or MUX selected
- correct Audience model selected for the Mode
- policy name follows the contract
- description follows the contract
- assignment model matches Mode and Audience
- architecture review completed when required
- audit planned after the change