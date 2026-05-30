# Maintaining the IPG Configuration JSON

## Purpose

This document explains how to maintain the IPG `configuration.json` file.

The configuration file defines the tenant-specific governance model used by IPG when validating Intune configuration policies.

It is not only a technical settings file.

It is the operational contract that tells IPG:

- which Scopes exist
- which Entra groups represent those Scopes
- which Products and Domains are valid inside each Scope
- which policy Modes are supported
- which Scope combinations may overlap
- which review intervals are acceptable
- which Graph permissions are required
- which human-readable reason text should be used in audit output
- which policy name and description patterns IPG should parse

Changes to this file should be treated as governance changes.

---

## Terminating validation errors

Errors in this configuration file can cause terminating errors.

If the file is missing, cannot be loaded, contains invalid required properties, references invalid or missing Scope groups, or defines an unusable governance model, IPG may stop before producing a normal audit result.

Treat configuration maintenance as a control-plane change.

A broken configuration does not only create audit findings. It can prevent the audit from running.

---

## Configuration file responsibilities

The configuration file is responsible for these areas:

| Area | Purpose |
|---|---|
| `Scopes` | Defines valid policy Scopes and their target groups |
| `Products` | Defines which Products are valid inside a Scope |
| `Domains` | Defines which Domains are valid for each Product |
| `Modes` | Defines supported policy modes, currently `ADD` and `MUX` |
| `ValidScopeCombinations` | Defines Scope pairs that may apply together |
| Review interval settings | Defines when review dates are approaching, expired, or too far away |
| `Documentation` | Links the audit report to the governance documentation |
| `TenantID` | Defines the tenant where the audit is expected to run |
| `RequiredScopes` | Lists Microsoft Graph permissions required by the audit |
| `ReasonCatalog` | Maps machine-readable reason codes to human-readable report text |
| `NameRegexPattern` | Defines how IPG parses policy names |
| `DescriptionRegexPattern` | Defines how IPG parses policy descriptions |

---

## Scope maintenance

Each Scope represents a governed target population.

Example:

```json
{
    "Name": "Workstation",
    "GroupName": "ConfigurationPolicyScope-Workstation"
}
```

`Name` is the value used in policy names.

`GroupName` is the Entra group used to resolve the actual objects in that Scope.

When adding or changing a Scope:

1. Confirm that the Scope is a real governance boundary.
2. Confirm that the Entra group exists.
3. Confirm that the Entra group contains the intended objects.
4. Confirm that the Scope name is suitable for policy naming.
5. Add the Products and Domains that are valid for that Scope.
6. Update `ValidScopeCombinations` if the new Scope can overlap with another Scope.

Do not add a Scope only because a group exists.

A Scope should represent a meaningful governance boundary.

---

## Product and Domain maintenance

Products and Domains define which policy namespaces are valid inside a Scope.

Example:

```json
{
    "Name": "Edge",
    "Domains": [
        "Security",
        "IdentityProfile",
        "PlatformIntegration",
        "UserExperience"
    ]
}
```

A policy using this Scope and Product must use one of the configured Domains.

For example, this is valid if `Security` is configured for `Edge` inside `Workstation`:

```text
Workstation-Edge-Security-Baseline-MUX
```

When adding a Product or Domain:

1. Confirm that the Product is actually governed by IPG.
2. Confirm that the Domain is a stable governance area.
3. Confirm that the name is clear enough for policy naming.
4. Confirm that the same setting will not be governed from multiple namespaces in the same Scope.
5. Update documentation if the new Domain introduces a new governance area.

Do not use Domains as random folders.

A Domain should describe ownership, lifecycle, assignment model, or operational responsibility.

---

## Mode maintenance

`Modes` defines the supported configuration behavior.

Current modes:

```json
"Modes": [
    "ADD",
    "MUX"
]
```

`ADD` means multiple policies may contribute to the final effective configuration.

`MUX` means the configuration should be mutually exclusive and one effective value should apply.

Do not add a new Mode unless the validator logic, documentation, and report interpretation are updated together.

A new Mode is a framework-level change, not a tenant customization.

---

## Valid Scope combinations

`ValidScopeCombinations` defines Scope pairs that may apply together.

Example:

```json
"ValidScopeCombinations": [
    "Workstation-Employee",
    "Workstation-Admin",
    "Workstation-Contractor"
]
```

These combinations help IPG reason about possible cross-scope conflicts.

For example, a workstation device and an employee user may both influence the final endpoint experience.

When adding a valid Scope combination:

1. Confirm that both Scopes can realistically apply to the same effective endpoint context.
2. Confirm that cross-scope setting conflicts should be evaluated.
3. Use the exact Scope names from the `Scopes` section.
4. Keep the format as `ScopeA-ScopeB`.

Do not add combinations just to silence findings.

A valid combination should describe a real operational overlap.

---

## Review interval settings

The configuration file defines global review expectations.

| Setting | Purpose |
|---|---|
| `MaxAllowedReviewIntervalInDays` | Maximum allowed review interval for normal policies |
| `RolloutMaxAllowedReviewIntervalInDays` | Maximum allowed review interval for rollout policies |
| `ReportBeforeReviewDateInDays` | When normal policies should start reporting approaching review |
| `RolloutReportBeforeReviewDateInDays` | When rollout policies should start reporting approaching review |
| `DaysBeforeExpirationAlert` | General alert window before expiration |

Rollout policies should have shorter review windows because they are temporary by design.

When changing review intervals:

1. Confirm that the new value matches the organization’s change management expectations.
2. Keep rollout intervals shorter than normal policy intervals.
3. Avoid making the interval so long that stale exceptions become invisible.
4. Avoid making the interval so short that the report becomes noisy.

Review settings should support governance discipline.

They should not be tuned only to make the report quieter.

---

## Documentation link

The `Documentation` property links audit output to the governance documentation.

Example:

```json
"Documentation": "https://github.com/tolvajp/IPG/blob/main/docs/ConfigurationPolicyGovernanceModel.md"
```

Keep this link current.

The email report and JSON output may expose this link to help operators understand the audit result.

When moving or renaming documentation, update this value.

---

## Tenant ID

`TenantID` defines the tenant where the configuration is expected to run.

Example:

```json
"TenantID": "168a3426-0f87-4294-b358-2825cc292392"
```

When reusing IPG in another tenant, this value must be changed.

Do not commit a customer tenant ID into a public example configuration unless it is intentionally sanitized or a lab tenant.

---

## Required Graph permissions

`RequiredScopes` lists Microsoft Graph permissions required by the audit.

Example:

```json
"RequiredScopes": [
    "DeviceManagementConfiguration.Read.All",
    "Group.Read.All",
    "DeviceManagementManagedDevices.Read.All",
    "GroupMember.Read.All"
]
```

When the audit logic changes, review this list.

Add permissions only when they are actually required.

Remove permissions when they are no longer needed.

The configuration should reflect least privilege.

---

## ReasonCatalog maintenance

`ReasonCatalog` maps machine-readable reason codes to human-readable text.

Example:

```json
"InvalidScope": "Invalid scope"
```

The machine-readable code is used by the audit engine.

The human-readable text is used in reports and emails.

When adding a new validator reason:

1. Add the machine-readable reason code to the code path that emits the finding.
2. Add the matching human-readable text to `ReasonCatalog`.
3. Keep the message short and operationally useful.
4. Prefer clear remediation-oriented language.
5. Avoid changing existing reason codes unless compatibility is intentionally broken.

Reason codes should be stable.

Report wording may improve over time, but the code should remain machine-readable and predictable.

---

## Policy name regex

The `NameRegexPattern` property defines how IPG parses policy names.

Example:

```json
"NameRegexPattern": "^(?<Scope>[^-]+)-(?<Product>[^-]+)-(?<Domain>[^-]+)(?:-(?<SubDomain>[^-]+))?-(?<Audience>[^-]*)-(?<Mode>[^-]+)$"
```

The regex must return these named groups:

- `Scope`
- `Product`
- `Domain`
- `Audience`
- `Mode`

The regex may also return this optional named group:

- `SubDomain`

IPG uses these parsed values as canonical metadata.

This means the organization can keep a tenant-specific naming convention, as long as the regex can translate policy names into the metadata IPG needs.

Example policy name:

```text
Workstation-Edge-Security-Smartscreen-Baseline-MUX
```

Parsed values:

| Field | Value |
|---|---|
| Scope | `Workstation` |
| Product | `Edge` |
| Domain | `Security` |
| SubDomain | `Smartscreen` |
| Audience | `Baseline` |
| Mode | `MUX` |

Example without SubDomain:

```text
Workstation-Edge-Security-Baseline-MUX
```

Parsed values:

| Field | Value |
|---|---|
| Scope | `Workstation` |
| Product | `Edge` |
| Domain | `Security` |
| Audience | `Baseline` |
| Mode | `MUX` |

The regex should parse the policy name.

The validator decides whether the parsed values are valid.

For example, the regex may parse an invalid mode such as `BADMODE`. The validator will then report `InvalidMode`.

The `Audience` group should allow an empty value if the tenant wants IPG to report missing audiences as `MissingAudience`.

Example:

```json
"NameRegexPattern": "^(?<Scope>[^-]+)-(?<Product>[^-]+)-(?<Domain>[^-]+)(?:-(?<SubDomain>[^-]+))?-(?<Audience>[^-]*)-(?<Mode>[^-]+)$"
```

In this pattern, `(?<Audience>[^-]*)` allows an empty audience.

This allows a name like this to be parsed:

```text
Workstation-Edge-Security--MUX
```

The parsed `Audience` value is empty, and IPG can report `MissingAudience`.

If the regex used `(?<Audience>[^-]+)` instead, the same policy name would not match the pattern and IPG would report a policy name parsing failure instead.

---

## Policy description regex

The `DescriptionRegexPattern` property defines how IPG parses policy descriptions.

Example:

```json
"DescriptionRegexPattern": "^(?<ReviewDate>[^|]*)\\|(?<TicketNumber>[^|]*)\\|(?<PolicyReason>.*)$"
```

The regex must return these named groups:

- `ReviewDate`
- `TicketNumber`
- `PolicyReason`

The current expected logical description format is:

```text
[ReviewDate]|[TicketNumber]|[Reason]
```

Example description:

```text
08-05-2026|SCTASK12345678|Temporary SmartScreen exception
```

Parsed values:

| Field | Value |
|---|---|
| ReviewDate | `08-05-2026` |
| TicketNumber | `SCTASK12345678` |
| PolicyReason | `Temporary SmartScreen exception` |

In JSON, the pipe separator must be escaped as `\\|` because JSON uses `\` as an escape character.

The regex should parse the description.

The validator decides whether the parsed values are valid.

For example:

- invalid review date format is reported as `InvalidReviewDateFormat`
- missing ticket number is reported as `MissingTicketNumber`
- missing reason is reported as `MissingPolicyReason`

---

## Change process

Configuration JSON changes should follow this process:

1. Identify the governance change.
2. Update the configuration JSON.
3. Validate JSON syntax.
4. Run the audit against test data or a known tenant state.
5. Review **Metadata Parsing Issues** first.
6. Review setting conflict, assignment topology, review interval, and scope overlap findings.
7. Update documentation if the governance model changed.
8. Commit the change with a clear explanation.

Do not change the configuration only to suppress a finding.

If the audit reports a problem, first decide whether the configuration is wrong or the tenant policy estate is wrong.

---

## Metadata parsing impact

Policies that do not follow the configured governance model may appear under **Metadata Parsing Issues**.

These policies are excluded from the remaining audit checks.

This means IPG does not evaluate their assignment topology, review intervals, scope overlap, or setting conflicts.

Fix metadata parsing issues first.

The rest of the audit result may change after affected policies become parseable.

---

## Maintenance checklist

Before committing a configuration change, confirm:

- JSON syntax is valid.
- Every Scope has a non-empty `Name`.
- Every Scope has a non-empty `GroupName`.
- Every configured Scope group exists.
- Scope groups contain the intended objects.
- Products and Domains match the intended governance model.
- `Modes` still reflects supported validator behavior.
- `ValidScopeCombinations` reflects real operational overlap.
- Review interval values are intentional.
- `Documentation` points to the correct documentation.
- `TenantID` is correct for the target tenant.
- `RequiredScopes` reflects least privilege.
- Every emitted reason code has a `ReasonCatalog` entry.
- Audit output was reviewed after the change.

---

## Rule of thumb

The configuration file should describe the intended operating model.

It should not be used as a shortcut to hide messy policy structure.

If a configuration change makes the audit quieter but the operating model less clear, it is probably the wrong change.
