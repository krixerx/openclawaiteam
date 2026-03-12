# Bitbucket Setup Guide

## 1. Create Service Accounts

Create three workspace-level service accounts in Bitbucket:

| Account | Handle | Role |
|---------|--------|------|
| Emma AI Lead | `emma-ai-lead` | Read-only repository access, PR status tracking |
| Morgan AI Arch | `morgan-ai-arch` | PR review, design compliance comments |
| Sean AI Dev | `sean-ai-dev` | PR creation, commits, branch management |

## 2. Generate App Passwords

For each service account, create a scoped app password at:
`Bitbucket Settings > Personal Settings > App passwords`

### emma-ai-lead (read-only)
- Repositories: Read

### morgan-ai-arch (reviewer)
- Repositories: Read
- Pull requests: Read, Write (for review comments)

### sean-ai-dev (developer)
- Repositories: Read, Write
- Pull requests: Read, Write, Create

## 3. Configure Environment

Add the credentials to your `.env` file:

```
BITBUCKET_WORKSPACE=your-workspace-name
EMMA_BITBUCKET_USERNAME=emma-ai-lead
EMMA_BITBUCKET_APP_PASSWORD=<generated-password>
MORGAN_BITBUCKET_USERNAME=morgan-ai-arch
MORGAN_BITBUCKET_APP_PASSWORD=<generated-password>
SEAN_BITBUCKET_USERNAME=sean-ai-dev
SEAN_BITBUCKET_APP_PASSWORD=<generated-password>
```

## 4. Install OpenClaw Bitbucket Skill

After containers are running, install the Bitbucket skill from ClawHub in Sean's and Morgan's containers. Emma uses read-only access for status tracking only.

## 5. Test PR Workflow

1. Sean creates a feature branch and opens a PR
2. Morgan reviews the PR for design compliance
3. Emma tracks PR status and reports to PO in #po-commands
