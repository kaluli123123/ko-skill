---
name: ko-bug
description: Evidence-first bug diagnosis and fix protocol. Use it when the user names this skill directly, or asks to reproduce, root-cause, or fix a crash, error, wrong result, regression, flaky failure, or performance regression — the same trigger conditions apply whether the request is written in English, Chinese (中文), or Japanese (日本語). Not for new features, UX polish, or performance tuning of behavior that is already correct; architectural changes, multi-component rework, or work that needs a pre-approved task list are out of scope.
---

# Evidence-first Bugfix

Diagnose already-broken behavior through representative reproduction, minimization, falsifiable hypotheses, RED→GREEN, and end-to-end evidence. Read repository rules, `CONTEXT.md`, relevant ADRs, and project docs before choosing actual project commands; assume no particular language, framework, runtime, or deployment.

## Language Policy

Use the language explicitly requested in the current message; otherwise match its natural language among English, Chinese, Japanese, Korean, Spanish, French, and Portuguese. Default to English if unsupported or unclear.

Never translate technical identifiers: paths, commands, code, logs, stack traces, protocol fields, literal names/URLs/IDs, `[DEBUG-<tag>]`, or `ORIG_BRANCH`.

## Non-negotiable Rules

- **Evidence before theory:** establish a fast signal asserting the exact symptom, reproduce at full fidelity, then minimize one variable at a time. Without evidence, record gaps rather than inventing facts, identifiers, or conclusions.
- **Falsifiable hypotheses:** specify predictions and minimal verification actions. Locate the causal mechanism at a specific `file:line`, function, branch, or equivalent config/data/protocol boundary.
- **Representative RED→GREEN:** observe the target failure before the production fix, then pass the same test. If no correct seam represents the real call chain, use Stage 2's original loop and report “no correct seam.”
- **Redact before display:** replace credentials, cookies, user data, and signed URLs with `<REDACTED>` in logs, requests, HARs, traces, dumps, and environment output.
- **Permission is separate from evidence:** a general review request authorizes neither execution nor edits. Respect read-only scope. Git writes—including `worktree add`, `add`, `commit`, `push`, `merge`, `checkout`, and `stash`—require explicit authorization; testing or editing permission does not supply it. Reuse explicit existing authorization for its covered action; never require it twice.
- **Two failed fixes maximum:** count attempts as defined in Stage 7, then stop patching and request new evidence or a planning flow with a pre-approved task list.

## Stage 0: Rules and Boundaries

Check branch, working tree, root and directory rules, `CONTEXT.md`, relevant ADRs, and module constraints. Preserve existing user changes: no reset, cleanup, or overwrite.

Identify real test, build, static-check, startup, CLI, browser/device, database, and protocol entry points. Never borrow commands from another project.

If explicit repository rules or a matching command/skill define a bugfix, issue-closeout, or archive flow, defer to it. Supply only missing diagnostic stages (1–5), without duplicating its confirmation gate, worktree, or archive.

### Global Stop Conditions

Stop, report evidence, and request a planning flow with a pre-approved task list when:

- Architecture redesign, a storage/protocol swap, or a new public API is required;
- Multiple independent components need distinct non-trivial logic;
- Root cause remains unlocalized at the end of Stage 5;
- No representative loop can be established after Stage 2's fallback;
- After localization, a quick diff sketch indicates clearly more than ~150 lines, a new module/public data structure, or a migration. Do not guess this at intake.

## Stage 1: Intake

Record source, version, platform/runtime, preconditions, reproduction steps, expected/actual behavior, frequency, raw errors, logs, and attachments. Show only relevant redacted evidence. List material gaps and request the missing evidence; do not speculate.

## Stage 2: Tight Feedback Loop

Choose the closest supported signal to the real entry point, in order:

1. Failing unit, integration, or E2E test reaching the bug;
2. HTTP/API script against a running service;
3. CLI fixture compared with known-good output;
4. Browser/desktop automation asserting visible, console, network, or process state;
5. Redacted replay of a real request, event, log, or trace;
6. Throwaway harness with only necessary dependencies;
7. Property/fuzz/stress loop;
8. Differential/bisect loop over known-good/bad versions, configurations, or data. Git switches require explicit authorization and a clean tree or changes already saved by the user;
9. Structured HITL when manual operation is unavoidable.

For HITL, deliver a table specifying each action, expected observation, actual-observation fields, and round count. Size repetitions to reported frequency: one or two failures in ten calls for at least 10–20 rounds. Record returned results. Design this table before declaring automation unavailable means no loop.

Shorten startup, assert the specific symptom, control time/randomness/filesystem/network, and cache irrelevant setup. For flakes, increase reproduction through repetition, parallelism, stress, timing control, or fixed randomness; record frequency and run count. For performance regressions, use benchmark measurements, profiling, query plans, or a timing harness—not logs alone.

Within authorized diagnostic execution/edit scope, non-production test/scratch/temporary harnesses may be written and run directly. Existing commands, tests, and logs may be used read-only within scope. Before temporary production instrumentation, state where and why and obtain confirmation unless that instrumentation is already explicitly authorized.

### Completion and Fallback

Require an actually executed command with retained redacted output, reaching the real path and failing for the exact symptom. The loop must be repeatable, sufficiently fast, and unattended; flaky reproduction must distinguish hypotheses, with counts recorded.

HITL is the exception: a delivered table awaiting results can advance provisionally. Hypotheses may be listed, but predictions and verification must map to table fields; pending observations are not evidence of RED.

If no loop or HITL table can be established, list attempts and request a reproducible environment, redacted artifact, or missing instrumentation authorization. Do not proceed to hypotheses. If the representative loop remains impossible, apply the global stop condition.

## Stage 3: Reproduce and Minimize

Run the full-fidelity loop and verify the user's failure rather than a neighboring error. Retain the error, wrong result, or performance measurements.

After RED, remove inputs, callers, configuration, data, and steps one at a time, rerunning each time. Stop when each remaining element is load-bearing: removing it makes the reproduction green. Use this minimal case for regression coverage.

For nondeterministic failures, maintain frequency/run counts; reliable discrimination between hypotheses is sufficient.

## Stage 4: Ranked Hypotheses

Before testing, show 3–5 ranked candidates:

```text
Hypothesis: <specific mechanism>
Evidence: <supporting and contradicting facts>
Prediction: if true, <verification action> should show <result>
Verification: <smallest action changing one variable>
```

Invite domain knowledge without blocking progress to Stage 5. This checkpoint does not replace analysis confirmation.

## Stage 5: Instrument and Localize

Tie every probe to a prediction. Prefer debugger/REPL, then minimal input/output or cross-layer logging; never print everywhere. Test/scratch probes follow diagnostic scope; production probes follow Stage 2's instrumentation gate.

Assign temporary logs a unique `[DEBUG-<short-tag>]` per round, record markers for cleanup, and exclude unredacted secrets or user content. Use measurement tools for performance. Change one variable and record whether each result strengthens or weakens a hypothesis.

Complete only with a specific source/config/data/protocol location and an evidenced causal chain explaining the symptom. Re-rank or request evidence if uncertain; apply the global stop condition if localization remains impossible. Never promote the leading hypothesis to fact without proof.

## Stage 5b: History and Impact

Before analysis confirmation:

- **History:** run `git log -L <start-line>,<end-line>:<file>` or `git blame` plus `git log -S<keyword>`. Record the most recent 1–3 relevant commits/PRs/issues; write “no history” for a non-Git repository.
- **Related bugs:** search the defect archive (such as `docs/bugs/`), issue tracker, and CHANGELOG once each using raw error keywords and module name. Record hits, “no hit (searched X/Y/Z),” or unavailable sources.
- **Regression scope:** direct callers and tests from matching historical commits are must-test; other module entry points are suggested; indirect dependents receive spot-checks.
- **Risk/options:** internal logic without persistence is low risk; public interfaces, persistence, or protocols are medium; concurrency, migrations, security, or payments are high. Compare the minimal fix with an alternative, or state “no alternative, because: …”.
- **Remaining investigation:** provide concrete logging/query/capture commands for unresolved gaps, or “none.”

For GitHub history or issue lookup, use `gh`, quote API URLs in shells, and exhaust pagination—including nested GraphQL comments/threads—before claiming complete coverage. A 100-row list is a preview. Lookup does not authorize publication.

## Analysis Confirmation Gate

Before Stage 6, send the analysis report once. Wait for explicit implementation confirmation unless existing explicit authorization already covers the proposed fix and scope. Do not repeat covered permissions or the instrumentation gate; identify genuine unresolved permissions separately. Analysis confirmation does not implicitly authorize Git writes.

Include:

1. Intake, redacted evidence, actual RED commands/results, minimal reproduction, frequency and run count;
2. Ranked hypotheses, predictions, verification results, root-cause location and call chain;
3. Open investigation suggestions, historical changes, and related bugs;
4. Must-test/suggested/spot-check scope, risk, proposed changes, and compared options;
5. Unresolved evidence, permission needs, and conditions required before implementation.

## Stage 6: Isolation and RED

After implementation is authorized, create an isolated worktree only with explicit Git-write authorization; record `ORIG_BRANCH` and its path. Otherwise use the current checkout if the user's authorized choice permits it, or pause for the missing authorization.

Reuse Stage 2's failing test if it represents the real call chain. Otherwise convert the minimal reproduction into a regression test:

1. Prefer extending coverage of the same public entry point.
2. Assert user-observable behavior, not mock invocation.
3. If no correct seam reproduces the call chain, report “no correct seam” and retain the original loop for RED/GREEN.
4. Run and observe the target failure before changing production code. Import, fixture, and environment failures do not count as RED.

## Stage 7: Minimal Fix and GREEN

Change only the root-cause area. Get the regression test GREEN, restore the original unminimized scenario, and rerun Stage 2's loop to verify the symptom is gone.

Failure to reach GREEN, or continued failure of the original loop, counts as one failed fix attempt. Re-rank hypotheses in Stage 4; before attempt two, report only the analysis delta and resolve any newly required permission. After two failed attempts, stop patching, explain the failed hypothesis, and request new environment evidence or a planning flow with a pre-approved task list.

Run applicable static, build, contract, database, native-platform, and device checks identified from the actual project.

## Stage 8: Cleanup and Delivery

Before claiming completion:

- Verify the original loop and regression test pass; disclose missing-seam limitations.
- Remove every recorded `[DEBUG-<short-tag>]` probe. Delete skill-created throwaway harnesses or move them to a clearly labeled debug location; preserve unrelated user work.
- Run the project's full test suite, static checks, and necessary E2E entry points. Separately run/report tests from matching historical commits, or write “historical check: no hit.” Require `git diff --check` to pass.
- Report actual commands, exit codes, pass/fail counts, and unverified coverage. Record the confirmed root cause in an authorized commit/PR description or bug archive.
- If rules mandate an archive or a defect-archive directory already exists, archive even without a linked issue, within authorized edit scope. Include symptom, root cause, fix, changed files, history, RED/GREEN, regression scope, and uncovered areas. Otherwise report “no archive directory.”

Use only verification layers that exist for the project. Missing required verification or authorization remains open; do not invent completion.

Commit, issue writeback, merge into `ORIG_BRANCH`, worktree deletion, and push each require explicit authorization covering that action. Reuse existing authorization without asking twice; follow the repository's closeout flow. For GitHub writes, use `gh` and English publication text unless explicitly directed otherwise. A requested issue-only or other limited delivery does not authorize later publication steps. A permission-blocked requested PR is partial delivery. Never merge without explicit authorization.

If no Git writes occurred, state “no Git write operations were performed.”

## Scope Examples

Use for failing tests, crashes, wrong results, flaky endpoints, and performance regressions requiring evidence, minimal reproduction, root-cause repair, and historical/E2E verification—including reports in Chinese or Japanese.

For log-reading or review-only requests, use only the authorized read-only subset of Stages 0–5; do not execute, edit, or enter Stage 6 without appropriate authorization.

Do not use for new features, UX polish, tuning correct behavior, architectural migrations, or independent multi-component rework. Use a planning flow for work needing a pre-approved task list. A verified fix needing only commit/issue closeout belongs to the repository's existing closeout flow.
