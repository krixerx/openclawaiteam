## ADDED Requirements

### Requirement: Bitbucket service accounts per agent
The system SHALL use three Bitbucket workspace service accounts: `emma-ai-lead`, `morgan-ai-arch`, and `sean-ai-dev`. Each account SHALL have an app password scoped to the minimum required permissions for its role.

#### Scenario: Sean creates a PR using service account
- **WHEN** Sean opens a Pull Request on Bitbucket
- **THEN** the PR is created under the `sean-ai-dev` account with appropriate permissions

#### Scenario: Morgan reviews a PR using service account
- **WHEN** Morgan reviews Sean's PR for design compliance
- **THEN** the review comment is posted under the `morgan-ai-arch` account

### Requirement: Bitbucket skill installation
The OpenClaw Bitbucket skill SHALL be installed from the official ClawHub registry in Sean's container for PR creation and in Morgan's container for PR review. Emma SHALL have read-only Bitbucket access for status tracking.

#### Scenario: Sean creates PR via Bitbucket skill
- **WHEN** Sean completes feature implementation and tests pass
- **THEN** Sean uses the Bitbucket skill to create a PR with the implementation branch

#### Scenario: Morgan reviews PR via Bitbucket skill
- **WHEN** Emma assigns a PR review to Morgan
- **THEN** Morgan uses the Bitbucket skill to read PR changes and post design compliance review comments

### Requirement: End-to-end PR workflow
The system SHALL support the full PR workflow: Sean creates a PR with implementation, Morgan reviews for design compliance, and upon approval the PR is ready for merge. Each step SHALL be communicated via the appropriate Slack channel.

#### Scenario: Complete PR lifecycle
- **WHEN** Sean opens a PR and posts the link to #dev-updates
- **THEN** Morgan reviews the PR and posts review results to #architecture, and Emma reports completion status to #po-commands

### Requirement: Bitbucket credentials via app passwords
Bitbucket authentication SHALL use workspace-level app passwords (not personal access tokens). App passwords SHALL be scoped per-account and stored in the `.env` file, never hardcoded.

#### Scenario: App password rotation without disruption
- **WHEN** the operator rotates a Bitbucket app password in the `.env` file and restarts the affected container
- **THEN** the agent reconnects to Bitbucket with the new credentials without affecting other agents
