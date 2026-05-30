# Changelog

## 0.1.0 - 2026-05-29

Initial public release of the Intune Policy Governance audit module.

This release introduces the first public version of the project: a PowerShell-based governance audit module that evaluates Intune configuration policy assignments against a documented architecture contract and produces a structured governance problem catalog.

The goal of this version is to make architectural intent testable, repeatable, reviewable, and usable by operational processes such as change management, exception review, CI/CD validation, reporting, ticketing, and management summaries.

### Added

- Added main Intune configuration policy audit flow.
- Added JSON-based governance configuration contract.
- Added live tenant audit mode through Microsoft Graph.
- Added offline dataset mode for repeatable testing and demonstrations.
- Added structured audit output with Machine, Human, and Documentation branches.
- Added machine-readable finding identifiers for downstream automation.
- Added human-readable finding descriptions for operational review.
- Added ADD / MUX topology validation.
- Added policy naming and topology validation.
- Added policy domain, category, scope, and assignment validation.
- Added review interval and expired review date validation.
- Added setting conflict validation across assigned configuration policies.
- Added empty assignment group validation.
- Added mutually exclusive scope membership validation.
- Added group, policy, user, and device name resolution for readable output.
- Added standardized JSON audit result output.
- Added operational email report generation.
- Added mocked tenant and live tenant sample outputs.
- Added sample operational email report output.
- Added Pester test coverage for core audit logic.
- Added GitHub Actions test workflow.
- Added module manifest with explicit public command exports.
- Added README, governance contract documentation, operational SOP, and Azure Automation deployment documentation.
- Added MIT license.

## 0.1.1 - 2026-05-30

- Mail notifies about excluded policies.
- Documentation changes.
- Name supports regex set in configuration.json
- Description supports regex set in configuration.json
- MUX-ADD distinction is optional.