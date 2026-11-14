---
name: ko-github-issues
description: Delivers a verified GitHub Issue-to-PR bug fix from a repository URL. Use only when the user explicitly asks to find or fix a real bug, create or reply to an Issue, open a Pull Request, or run the full Issue-to-PR workflow. Defaults to one bug and one PR per Issue; asks before auditing for a new bug when no eligible Issue is available. Not for read-only status checks, PR reviews, feature work, or GitHub reuse research.
---

# GitHub Issues Delivery

Deliver one reproducible defect through a traceable Issue and PR, preserving ownership and verification gaps.

## Authority and Defaults

- Explicit invocation with a repository authorizes the default Issue-and-PR workflow. Reuse existing explicit authorization; never ask twice. A general review request authorizes neither edits nor execution of fixes.
- Respect scope: **read-only** permits inspection; **ledger-only** permits the requested ledger update; **issue-only** permits requested Issue publication without implementation, commits, push, or PR; **full delivery** permits the authorized Issue-to-PR sequence. Never run later publication steps outside that scope.
- Default to one bug and one PR per Issue. Ask for the repository only when absent.
- External writes require explicit authorization. Preserve unresolved permission gates; a permission-blocked PR is partial delivery.
- Never merge, close Issues, deploy, or change repository settings without separate authorization.

| Input | Default / behavior |
|---|---|
| `repository` | Requested URL or `owner/repo` |
| `bug_count` | `1` |
| `one_issue_per_pr` | `true`; otherwise group only a shared root cause and verification boundary |
| `unavailable_issue_policy` | `ask`; alternatives: `skip`, `stop`, explicitly authorized `takeover` |
| `publish` | `issue-and-pr` for explicit full invocation; honor narrower requests |
| `ledger_path` | Unset; update only a user- or repository-designated in-scope ledger |

Match the user's language for status. Follow repository language requirements for Issues, PRs, comments, commits, and code comments; default to English. Use English claim comments. Use `gh` for GitHub operations and quote API URLs in shells.

## Workflow

### 1. Verify access and rules

State repository, count, Issue-to-PR mapping, scope, and unavailable-Issue policy.

```bash
gh auth status
gh repo view OWNER/REPO --json nameWithOwner,defaultBranchRef,url,viewerPermission
git status --short --branch
rg --files --hidden -g '!.git/**' -g 'AGENTS.md' -g 'CLAUDE.md' -g '.claude/rules/**/*.md' \
  -g 'CONTRIBUTING*' -g 'README*' -g '.github/ISSUE_TEMPLATE/**' \
  -g '.github/pull_request_template*' -g 'Makefile' -g 'pyproject.toml' \
  -g 'package.json'
```

Read applicable rules and templates before editing or publishing. Record branch conventions, checks, generated-file rules, forbidden paths, and publication requirements. Preserve dirty and untracked work. Verify default branch, remote, fork, and permissions rather than guessing; stop before edits if authentication or access fails.

### 2. Screen live Issues

```bash
gh issue list -R OWNER/REPO --state open --limit 100 \
  --json number,title,body,labels,assignees,author,comments,updatedAt,url
gh pr list -R OWNER/REPO --state open --limit 100 \
  --json number,title,body,headRefName,author,files,url
gh api --paginate 'repos/OWNER/REPO/issues?state=open&per_page=100'
```

The 100-row lists are previews. Exhaust relevant Issue and PR pagination before claiming complete coverage. Paginate candidate comments, linked-PR evidence, and any nested GraphQL comments or threads independently; outer pagination does not exhaust nested connections.

Reject assigned, claimed, maintainer-held, already-solved, non-reproducible Issues or those linked to an open PR. Inspect current code and reproduction evidence; questions, features, and reproduction-help requests are not automatically defects.

When no eligible Issue remains:

- `ask`: request permission once to audit for a new bug; wait unless already explicitly authorized.
- `skip`: skip unavailable work; audit only if already authorized.
- `stop`: report `found/required` and stop.
- `takeover`: require both explicit user authorization and clear release by the prior owner or maintainer.

Recheck ownership immediately before publication. If ownership changes, stop publication, refresh comments and linked PRs, and apply the policy.

### 3. Reproduce and establish the Issue

Demonstrate the defect on the current default-branch head. Retain exact SHA and environment, minimal reproduction, expected versus actual behavior, duplicate-search results, and evidence excluding configuration errors, unsupported use, or an existing fix. Without reproducible or falsifiable evidence, report the gap and do not publish.

For an authorized new Issue, follow the bug template and include reproduction evidence, impact, and environment. Redact secrets, credentials, private data, and sensitive provider payloads. Use `gh issue create`, save its number and URL, and create it before the implementation PR. Use `gh issue comment` for a narrow claim only when expected by the repository and authorized. Failed creation does not reserve work.

Stop after the requested Issue action in issue-only mode.

### 4. Implement within scope

For each Issue, use an independent `fix/<slug>-<N>` branch from the verified default-branch head:

```text
Issue -> regression test -> minimal root-cause fix -> verification
      -> one commit -> one PR closing #N -> Issue reply
```

Use an isolated worktree for dirty checkouts or coexisting fixes. Add the regression test first when a stable seam exists; reuse project patterns. Group Issues only under the configured shared-root-cause exception, referencing and replying to every covered Issue.

### 5. Verify and review

Run focused regression tests, required formatting/lint/targeted typechecks, then the repository-required full suite. Add runtime, CLI, API, browser, or device proof when needed. Obtain independent read-only review when available for security, persistence, concurrency, cancellation, or cross-provider changes.

Record exact results without inventing evidence. Read complete failure logs and distinguish changed-code failures from baseline, optional-dependency, environment, CI, and policy failures. Publish with incomplete checks only when repository rules permit, documenting every gate.

### 6. Commit and publish

Before authorized Git writes, recheck HEAD, branch, index, task scope, and remote target/head SHA where applicable:

```bash
git status --short --branch
git diff --name-only
git diff --check
git rev-parse HEAD
git rev-parse origin/DEFAULT_BRANCH
```

Substitute the verified remote/default branch. Stage only task-owned changes; use a concise imperative commit subject. On upstream `403`, use the user's existing fork or `gh repo fork` within authorization. Never overwrite unrelated branches, force-push upstream, or rewrite existing branches.

Open the PR with `gh pr create`. Include Summary, root cause, changed behavior, Test plan, Issue reference, and incomplete gates. Distinguish Draft/Ready, review, CI, and merge states.

After the PR exists, reply using `gh issue comment` with its link, root cause, fix boundary, focused-test result, incomplete checks, and readiness.

### 7. Update the ledger and report

For an in-scope ledger, read its structure, update exactly one row per PR, synchronize derived aggregate counts, verify each PR URL/title occurs once, and preserve unrelated edits. Ledger-only mode ends here without Issue or PR publication.

Full delivery requires an existing Issue, committed fix and regression test, passing focused checks, an existing PR, Issue reply, and required ledger update. A blocked PR remains **partial**, even when its permission gate is documented. Assess narrower modes against their requested deliverables.

Report Issue/PR URLs and state, commit, changed files, passed/failed/skipped checks, external gates, and whether merge or closure occurred. Do not claim completion from a preview or missing evidence.

## Exclusions and Reference

Do not activate full delivery for status checks, PR reviews, merge-readiness audits, features, reuse research, bulk dependency updates, releases, deployments, merges, or closures. For questions, feature requests, or security reports, explain the scope mismatch; do not create a public bug Issue for private disclosure.

See [`references/usage.md`](references/usage.md) for installation, invocation, policies, and output examples.
