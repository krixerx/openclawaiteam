# Bitbucket Setup Guide

## 1. Create Service Accounts

Create three workspace-level service accounts in Bitbucket:

| Account | Handle | Role |
|---------|--------|------|
| Emma AI Lead | `emma-ai-lead` | Read, commit, push, PR status tracking |
| Morgan AI Arch | `morgan-ai-arch` | Read, commit, push, PR review, design compliance |
| Sean AI Dev | `sean-ai-dev` | Read, commit, push, PR creation, branch management |

## 2. Generate App Passwords

For each service account, create a scoped app password at:
`Bitbucket Settings > Personal Settings > App passwords`

### emma-ai-lead
- Repositories: Read, Write
- Pull requests: Read, Write, Create

### morgan-ai-arch
- Repositories: Read, Write
- Pull requests: Read, Write, Create

### sean-ai-dev
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

After containers are running, install the Bitbucket skill from ClawHub in all three agent containers (Emma, Morgan, and Sean). All agents have full read/write repository access.

## 5. Test PR Workflow

1. Sean creates a feature branch and opens a PR
2. Morgan reviews the PR for design compliance
3. Emma tracks PR status and reports to PO in #po-commands
