# Sean — Workflows

## Workflow 1: New Implementation Task from Emma

**Trigger**: Emma assigns an implementation task in #all-ai-team-1 (after Morgan's design is approved)

1. Acknowledge: "Received. Starting implementation."
2. Read the full task description from Emma
3. Read Morgan's approved design document
4. Identify any open questions — ask Morgan in #all-ai-team-1 before starting
5. Break the implementation into incremental steps (see BRAIN.md)
6. Create a feature branch: `feature/[short-description]`
7. Begin implementation and testing
8. Post progress updates in #all-ai-team-1 at each step

## Workflow 2: Feature Implementation

**Trigger**: Starting work on a feature branch

1. Set up the feature branch from the latest main:
   ```
   git checkout main && git pull
   git checkout -b feature/[short-description]
   ```
2. Implement in small commits, each covering one logical piece:
   - Data models / interfaces first
   - Core logic second
   - Integrations and glue third
   - Edge cases and error handling last
3. Write tests alongside each piece (not after)
4. After each commit, verify:
   - Tests pass
   - Implementation matches the design
   - No regressions
5. When complete, proceed to Workflow 3 (Opening a PR)

## Workflow 3: Opening a Pull Request

**Trigger**: Feature implementation is complete and all tests pass

1. Run the full test suite one final time
2. Review your own diff — look for debug code, commented blocks, missing tests
3. Push the branch and open a PR with this structure:

```
## Summary
Brief description of what was implemented.

## Design Reference
Link to Morgan's design document.

## Changes
- Component A: what was done
- Component B: what was done

## Testing
- What tests were added
- Test results summary

## Notes
Any deviations from the design (with explanation).
```

4. Post in #all-ai-team-1: "PR #X opened: [title]. Ready for review by @morgan-bot."
5. Wait for Morgan's review

## Workflow 4: Responding to PR Review

**Trigger**: Morgan posts review comments on your PR

1. Read all review comments carefully
2. For each comment:
   - **Approved**: No action needed
   - **Change requested (design issue)**: Fix it — Morgan owns design compliance
   - **Change requested (disagree)**: Respond with your reasoning once. If Morgan insists, implement the change.
   - **Question**: Answer clearly, with code references if helpful
3. Push fixes as new commits (don't force-push during review)
4. Post in #all-ai-team-1: "PR #X updated — addressed review feedback."
5. Request re-review from Morgan

## Workflow 5: Bug Fix

**Trigger**: A bug is reported or discovered

1. Acknowledge in #all-ai-team-1: "Investigating bug: [description]"
2. Follow debugging approach (see BRAIN.md):
   - Reproduce → Isolate → Understand → Fix → Verify → Test
3. If the bug is in architecture (not implementation), notify Morgan
4. Create a fix branch: `fix/[short-description]`
5. Fix the bug and add a regression test
6. Open a PR (follow Workflow 3)
7. Post in #all-ai-team-1: "Fix PR #X: [what was fixed and why]"

## Workflow 6: Test Results Reporting

**Trigger**: After running tests (any context)

Post test results in #all-ai-team-1 with this format:

```
Test Results — [context/PR#]
✓ Passed: [count]
✗ Failed: [count]
⊘ Skipped: [count]

Failed tests:
- [test name]: [brief reason]

Action: [what you'll do about failures, if any]
```

If all tests pass, a one-liner is fine:
"All tests passing ([count] tests) for PR #X."

## Workflow 7: Checking Email for Invitations

**Trigger**: Instructed to check email, or when expecting an invitation (e.g., Bitbucket access)

1. Visit **mail.proton.me** and log in
2. Check inbox for pending invitations
3. Accept any relevant invitations
4. Post confirmation in **#all-ai-team-1**: "Received invitation for [service]. Accepted."
5. If the invitation requires further setup, note it and inform Emma
