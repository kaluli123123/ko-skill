---
name: ko-github-issues
description: Delivers a verified GitHub Issue-to-PR bug fix from a repository URL. Use only when the user explicitly asks to find or fix a real bug, create or reply to an Issue, open a Pull Request, or run the full Issue-to-PR workflow. Defaults to one bug and one PR per Issue; asks before auditing for a new bug when no eligible Issue is available. Not for read-only status checks, PR reviews, feature work, or GitHub reuse research.
---

# GitHub Issues Delivery

Turn one verified defect into one traceable GitHub Issue and Pull Request without taking over claimed work or hiding verification gaps.

## Critical Contract

1. External writes require an explicit request. Invoking `ko-github-issues` with a repository URL authorizes the default Issue-and-PR workflow; a read-only request does not.
2. One repository URL is sufficient input. Default to one real bug, one Issue, and one PR.
3. Read repository rules before editing or publishing anything.
4. An open Issue is unavailable when it is assigned, claimed in comments, linked to an open PR, held by a maintainer, already solved, or not a reproducible defect.
5. If no eligible Issue remains, ask once whether to audit the code for a new bug. Only a clear yes authorizes that audit and a new Issue.
6. A Pull Request is not a merge. Do not merge, close Issues, deploy, or change repository settings unless separately requested.

## Inputs and Defaults

| Input | Default | Meaning |
|---|---|---|
| `repository` | URL or `owner/repo` from the request | Ask only when absent. |
| `bug_count` | `1` | Number of complete bug deliveries. |
| `one_issue_per_pr` | `true` | Separate branch, commit, and PR for each Issue. |
| `unavailable_issue_policy` | `ask` | `ask`, `skip`, `stop`, or explicitly authorized `takeover`. |
| `publish` | `issue-and-pr` | Use `issue-only` only when the user does not request a PR. |
| `ledger_path` | unset | Update only when the user or repository rules identify an in-scope ledger. |

Match the user's language for status reports. Use the target repository's required language for Issues, Pull Requests, comments, commits, and code comments; use English when no repository rule specifies a language.

## Workflow

### 1. Resolve authority and repository state

State the repository, requested count, mapping mode, publication scope, and unavailable-Issue policy. Then verify:

```bash
gh auth status
gh repo view OWNER/REPO --json nameWithOwner,defaultBranchRef,url,viewerPermission
git status --short --branch
```

Do not guess the default branch, remote, fork, or write permission. Stop before editing if authentication or repository access fails.

### 2. Read repository rules

From the checkout, find the applicable instructions and templates:

```bash
rg --files -g 'AGENTS.md' -g 'CLAUDE.md' -g '.claude/rules/*.md' \
  -g 'CONTRIBUTING*' -g 'README*' -g '.github/ISSUE_TEMPLATE/**' \
  -g '.github/pull_request_template*' -g 'Makefile' -g 'pyproject.toml' \
  -g 'package.json'
```

Record branch conventions, Issue and PR templates, required checks, generated-file rules, forbidden paths, and publication requirements. Preserve dirty and untracked user work.

### 3. Screen live Issue capacity

Read open Issues, open PRs, and the REST Issue inventory:

```bash
gh issue list -R OWNER/REPO --state open --limit 100 \
  --json number,title,body,labels,assignees,author,comments,updatedAt,url
gh pr list -R OWNER/REPO --state open --limit 100 \
  --json number,title,body,headRefName,author,files,url
gh api --paginate 'repos/OWNER/REPO/issues?state=open&per_page=100'
```

For each candidate, inspect assignees, claim comments, linked PRs, maintainer holds, current code, and reproduction evidence. Recheck ownership immediately before publication because availability can change during implementation.

Apply `unavailable_issue_policy`:

- `ask`: ask once whether to audit for a new unreported bug, then stop until the user answers.
- `skip`: skip unavailable Issues and continue an already-authorized code audit.
- `stop`: report `found/required` and stop.
- `takeover`: proceed only when the user authorized takeover and the prior owner or maintainer clearly released the work.

An unclaimed research question, feature request, or reproduction-help request is not automatically a bug.

### 4. Reproduce before publishing

Establish a minimal failing case on the current default-branch head. Preserve:

- the exact revision and environment;
- the smallest reproduction command or test;
- expected and actual behavior;
- evidence that the failure is not configuration, unsupported use, or an existing fix;
- duplicate-search results.

If the defect cannot be reproduced or falsifiably demonstrated, do not create an Issue or PR. Report the missing evidence.

### 5. Create or claim the Issue

For a new defect with no duplicate:

1. Follow the repository's bug template.
2. Include the revision, reproduction, actual result, expected result, impact, and environment.
3. Remove secrets, private data, credentials, and sensitive provider payloads.
4. Create the Issue before the implementation PR.
5. Save its number and URL.
6. Add a narrow English claim comment only when the repository expects claims.

Use `gh issue create` and `gh issue comment` for GitHub writes. If Issue creation fails, do not describe the work as reserved.

### 6. Implement one Issue at a time

With `one_issue_per_pr=true`, preserve this mapping:

```text
Issue #N
  -> independent fix/<slug>-<N> branch
  -> regression test
  -> minimal production fix
  -> focused verification
  -> one commit
  -> one PR closing #N
  -> one Issue reply
```

Create the branch from the verified default-branch head. Use an isolated worktree when the checkout is dirty or multiple fixes must coexist. Add the regression test first when a stable test seam exists, then implement the smallest root-cause fix using existing project patterns.

If `one_issue_per_pr=false`, group Issues only when they share one root cause and one verification boundary. Reference and reply to every covered Issue.

### 7. Verify and review

Run, in order:

1. Focused regression test.
2. Formatter, linter, and targeted typecheck required for changed files.
3. Repository-required full suite.
4. Runtime, CLI, API, browser, or device proof when the behavior requires it.
5. Independent read-only review for security, persistence, concurrency, cancellation, or cross-provider changes when available.

Record exact results. Separate changed-code failures from baseline, optional-dependency, environment, CI, and policy failures.

### 8. Commit, push, and open the Pull Request

Before Git writes, recheck:

```bash
git status --short --branch
git diff --name-only
git diff --check
git rev-parse HEAD
git rev-parse origin/DEFAULT_BRANCH
```

Stage only task-owned files. Use a concise imperative commit subject. If upstream push returns `403`, use the user's existing fork or create one with `gh repo fork`; never overwrite an unrelated remote branch.

The PR body must include Summary, root cause, changed behavior, Test plan, Issue reference, and incomplete gates. Report Draft, Ready, review, CI, and merge states separately.

### 9. Reply and update any required ledger

After the PR exists, reply to the Issue with the PR link, root cause, fix boundary, focused test result, incomplete checks, and current readiness.

When a repository rule or the user identifies a ledger:

- read its structure before editing;
- add or update exactly one row for the PR;
- synchronize aggregate counts derived from the file's current model;
- verify the PR URL and title occur once;
- preserve unrelated changes.

### 10. Report completion

A delivery is complete only when the Issue exists, code and regression test are committed, focused checks pass, the PR exists or a permission gate is documented, the Issue is replied to, and any required ledger is updated.

Report per Issue: Issue URL, PR URL and state, commit, changed files, passed checks, failed or skipped checks, external gates, and confirmation that merge and closure were not performed.

## Common Failures

### No eligible Issues remain

Apply the configured policy. Under the default `ask` policy, ask whether to start a code audit and wait for a clear answer.

### A selected Issue becomes claimed

Stop publication, refresh comments and linked PRs, then apply `unavailable_issue_policy`. Stale ownership evidence never justifies a duplicate PR.

### Upstream push returns 403

Use a fork and a cross-fork PR. Do not force-push upstream or rewrite an existing branch.

### Focused tests pass but the full suite fails

Read the complete failure log and classify each failure. Publish only if repository rules allow it, and state the exact incomplete gate in the PR and final report.

### The report is a question, feature request, or security issue

Exit this workflow. Offer the appropriate research, feature, or private disclosure path without creating a public bug Issue.

## Examples

Minimal invocation:

```text
Use ko-github-issues for https://github.com/example/project.
```

This requests one verified bug delivery and uses the default `ask` policy.

Explicit capacity and policy:

```text
Find two reproducible bugs in https://github.com/example/project. Use one Issue and PR per bug, skip claimed work, and reply to each Issue.
```

This uses `bug_count=2`, `one_issue_per_pr=true`, and `unavailable_issue_policy=skip`.

Read-only request that must not activate the delivery workflow:

```text
Show me the current status of Issue #42 and its linked PR.
```

Use a read-only status workflow instead.

## When Not to Use

- Read-only Issue or PR status checks.
- Existing PR review or merge-readiness audits.
- Feature implementation without a reproducible defect.
- GitHub project discovery or reuse research; use `ko-github` for that separate function.
- Private security disclosure.
- Bulk dependency updates, releases, deployments, merges, or Issue closures.

For installation, invocation patterns, policy choices, and output examples, read [`references/usage.md`](references/usage.md).
