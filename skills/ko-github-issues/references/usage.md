# ko-github-issues Usage Guide

`ko-github-issues` is an external-write workflow for delivering a reproducible defect as a GitHub Issue and Pull Request. It is separate from `ko-github`, which performs read-only research into reusable GitHub projects before substantial feature work.

## Install

Install only this skill in the current project:

```bash
npx skills add kaluli123123/ko-skill@ko-github-issues
```

Install it globally:

```bash
npx skills add -g kaluli123123/ko-skill@ko-github-issues
```

Select specific agents and skip the installer confirmation:

```bash
npx skills add -y -a claude-code -a codex kaluli123123/ko-skill@ko-github-issues
```

## Minimal Use

One repository URL is enough:

```text
Use ko-github-issues for https://github.com/owner/repository.
```

The defaults are:

- one verified bug;
- one Issue per PR;
- Issue and PR publication;
- ask before auditing for a new bug when no eligible Issue is available;
- no merge, Issue closure, deployment, or repository-setting changes.

## Control Capacity and Ownership

Skip claimed work and deliver two independent bugs:

```text
Use ko-github-issues to deliver two bugs in https://github.com/owner/repository. Skip assigned or claimed Issues and use one PR per Issue.
```

Stop rather than starting a new code audit:

```text
Use ko-github-issues for https://github.com/owner/repository. Only use existing eligible Issues; stop if none are available.
```

Group related Issues only when they share one root cause:

```text
Fix Issues #12 and #18 in one PR only if they share the same root cause and regression boundary. Reply to both Issues.
```

## Publication Boundary

Installing the skill does not authorize GitHub writes. Invoking `ko-github-issues` with a repository URL explicitly requests its default Issue-and-PR workflow; other requests must name the Issue, comment, branch, push, or Pull Request actions they need. The workflow never merges or closes the Issue by default.

Use a read-only request when publication is not wanted:

```text
Check whether Issue #42 is still unclaimed and whether it has a linked PR. Do not modify GitHub.
```

That request should not activate `ko-github-issues`; use ordinary read-only GitHub inspection instead.

## Required Evidence

Before publication, the workflow must retain:

1. The exact tested revision and environment.
2. A minimal reproduction or failing regression test.
3. Expected and actual behavior.
4. Duplicate, assignee, claim-comment, and linked-PR checks.
5. Focused test results and clearly separated incomplete gates.

## Expected Completion Report

For every delivered defect, the report includes:

```text
Issue: https://github.com/owner/repository/issues/123
PR: https://github.com/owner/repository/pull/124 (Ready)
Commit: abcdef1
Changed files: path/to/test, path/to/source
Passed: focused regression test, formatter, targeted typecheck
Incomplete: full suite skipped because <documented reason>
External gates: CI pending, maintainer review required
Not performed: merge and Issue closure
```

## Troubleshooting

### No eligible Issue exists

The default response is a single question asking whether to audit the code for a new unreported bug. A clear yes is required before that audit starts.

### The selected Issue is claimed during implementation

The workflow stops publication for that Issue and refreshes its ownership state. It does not create a competing PR from stale evidence.

### Upstream push is forbidden

The workflow uses the authenticated user's fork and opens a cross-fork PR. It does not force-push or overwrite an existing branch.

### Full verification is not clean

Focused, full-suite, baseline, environment, CI, permission, and maintainer gates are reported separately. A focused pass is never presented as a clean full suite.
