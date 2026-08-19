---
name: ko-bug
description: Evidence-first bug diagnosis and fix protocol. Use it when the user types $ko-bug, or asks to reproduce, root-cause, or fix a crash, error, wrong result, regression, flaky failure, or performance regression — the same trigger conditions apply whether the request is written in English, Chinese (中文), or Japanese (日本語). Not for new features, UX polish, or performance tuning of behavior that is already correct; architectural changes, multi-component rework, or work that needs a pre-approved task list are out of scope.
---

# Evidence-first Bugfix

This skill targets behavior that is already broken, across any language, framework, runtime, or system. It makes no assumption about the test framework, build tool, deployment shape, or client type in use; read the repo's rules, `CONTEXT.md` (if present), relevant ADRs, and project docs first, then pick commands that are actually real for the current project.

It is a self-contained bugfix protocol: a tight feedback loop constrains diagnosis, minimization removes variables, falsifiable hypotheses prevent anchoring, RED→GREEN locks in the regression, end-to-end evidence proves the user's symptom is gone, and controlled permissions plus an archive keep the delivery traceable.

## Language Policy

Default to English for every user-visible output this skill produces — reports, hypothesis lists, the analysis confirmation gate, HITL step tables, and any other natural-language text. Detection rules (highest priority first):

1. The user explicitly requests a language in the current message (e.g. "reply in Japanese" / "用中文回答") → follow that instruction.
2. The natural language of the user's current message → match it, among the three languages this skill currently supports: English, Chinese (中文), Japanese (日本語).
3. The message's language falls outside that set, or can't be determined → default to English.

Regardless of the response language, technical identifiers stay in their original form and are never translated: file paths, commands, code, log/error text, stack traces, protocol fields, table/field/URL/ID literals, and the fixed markers this skill defines (`[DEBUG-<tag>]`, `ORIG_BRANCH`).

## Non-negotiable Rules

1. **Feedback loop before theory**: there must be a fast signal that goes red against the user's exact symptom before entering the hypothesis or fix stage.
2. **Reproduce, then minimize**: run the full-fidelity repro first, confirm it's the user-reported failure, then remove inputs, callers, config, data, and steps one at a time.
3. **No evidence, no conclusion**: without logs, data, a call chain, or a reproducible signal, only record the gap; never invent table names, fields, paths, IDs, URLs, APIs, or environment facts.
4. **Every hypothesis must be falsifiable**: write the prediction and the minimal verification action; change one variable at a time.
5. **RED before the production fix**: see the failure first on the correct test seam (a test entry point that represents the real call chain), then fix the root cause, then see the same test pass. When there is no correct seam, let Stage 2's original feedback loop stand in for RED/GREEN, and note "no correct seam" in the report.
6. **Fix the root cause, not the symptom**: the root cause must land on a specific `file:line`, function, branch, or config entry, with its causal chain explained.
7. **Redact before you show anything**: tokens, passwords, cookies, user data, and signed URLs in logs, requests, HARs, traces, core dumps, or environment output must be replaced with `<REDACTED>`.
8. **Evidence and permission are separate**: analysis, testing, and file edits are not Git/GitHub write authorization; `worktree add`, `add`, `commit`, `push`, `merge`, `checkout`, `stash`, etc. all require explicit authorization.
9. **Stop after two failed fix attempts**: stop layering more patches, explain why the current hypothesis failed, and ask for new environment evidence; or stop this skill and ask the user to switch to a planning flow with a pre-approved task list. See Stage 7 for how "one attempt" is counted.

## Stage 0: Read the Rules and Confirm Boundaries

Check the current branch, working tree, repo-root rules, and any more specific directory rules first. Preserve the user's existing changes — no reset, no cleanup, no overwrite. Read `CONTEXT.md` and relevant ADRs if present, and build a model of module boundaries and constraints.

Identify the project's real entry points and verification commands: test runner, build command, static analysis, service startup, CLI, browser/device install, database or protocol checks. Never carry over commands from a different project.

If the repo already has its own bugfix, issue-closeout, or defect-archive flow (stated explicitly in a rules file, or backed by a matching command/skill), defer to it; this skill then only fills the diagnostic stages it's missing (Stages 1–5), and does not duplicate the confirmation gate, worktree, or archiving.

### Global Stop Conditions

Any of the following, confirmed at any stage, stops this skill immediately: output the evidence gathered so far and ask the user to switch to a planning flow with a pre-approved task list.

- The fix needs an architecture redesign, a storage/protocol swap, or a new public API;
- Multiple independent components each need distinct non-trivial logic;
- The root cause can't be pinned to `file:line` or an equivalent config/data boundary (still true at the end of Stage 5);
- A feedback loop representative of the user's symptom can't be established (still true after trying the "when a loop can't be established" flow at the end of Stage 2);
- After the root cause is located, a quick diff sketch estimates the fix at clearly more than ~150 lines, or it needs a new module, a new public data structure, or a migration (don't guess this at Stage 0).

## Stage 1: Structured Intake and Evidence Redaction

Organize without speculating: source, version, platform/runtime, preconditions, repro steps, expected behavior, actual behavior, frequency, the raw error text, logs, and attachments. Keep only the lines that support a judgment in the output, and redact before quoting.

If the intake is missing key conditions, list the gaps and the material you need from the user. Don't fill gaps with guesses.

## Stage 2: Establish a Tight Feedback Loop

The feedback loop is the core of the whole diagnosis. Pick the signal closest to the real entry point that the current system can support, in this priority order:

1. A failing test that reaches the bug: unit, integration, or E2E;
2. An HTTP/API script against a running service;
3. A CLI invocation with a fixture, compared against a known-good output;
4. Browser or desktop automation asserting visible results, console, network, or process state;
5. A redacted replay of a real request, event, log, or trace;
6. A throwaway harness that starts only the necessary dependencies;
7. A property/fuzz/stress loop;
8. A bisect/differential loop over known-good/known-bad versions, configs, or datasets (if it involves `git bisect`/`checkout` switches, get authorization under Rule 8 first, and confirm the working tree is clean or already saved by the user);
9. When manual operation is unavoidable, use a structured HITL (human-in-the-loop) cycle: the agent designs a step table first and hands it to the user to execute — each round spells out the action, the expected observation, which actual-observation fields need to be recorded, and how many rounds to run (sized to the reported frequency; e.g. "one or two times in ten" calls for at least 10–20 rounds). The agent records the results once the user fills them in. HITL is a legitimate loop — when there's no automated entry point, design the HITL step table first; don't jump straight to "a loop can't be established."

Tighten the loop: shorten startup time, assert the specific symptom rather than "it didn't crash," pin time/random seed/filesystem/network, and cache irrelevant setup. For flaky bugs, raise the reproduction rate via repetition, parallelism, stress, timing control, or fixed randomness, and record the frequency and run count. For performance issues, use benchmark measurements, a profiler, a query plan, or a timing harness — don't substitute a pile of logs for measurement.

Permission tiers for new files: anything placed in a test directory, a scratch directory, or a temporary harness location, and that doesn't touch production code, can be written and run directly. Anything that needs temporary instrumentation in production code requires a one-line statement of where and why before you touch it, and the user's confirmation (this is the lightweight instrumentation confirmation, not the full confirmation gate). Existing commands, tests, and logs can be run read-only.

### Completion Criteria

Stage 2 is complete only when all of the following hold:

- A command has actually been run and its redacted output kept (HITL loops are the exception: the step table having been delivered and awaiting the user's fill-in counts);
- It reaches the real bug path and asserts the user's exact symptom;
- It goes red against this bug specifically, not just "no error was thrown";
- It's fast enough, repeatable, and can run unattended by the agent; HITL loops are the exception, but each round's manual steps, observations, and count must be recorded;
- For flaky bugs, the reproduction rate has been raised to a diagnosable level via the means above, with frequency and run count recorded.

If a loop can't be established (not even a HITL step table can be designed), stop, list what's been tried, and ask the user to provide a reproducible environment, a redacted artifact, or explicit authorization for temporary instrumentation; don't go straight to hypotheses. In HITL scenarios, hypotheses may be listed up front, but each one's "prediction/verification" must land on a field the step table asks the user to observe, to be judged once it's filled in.

## Stage 3: Reproduce and Minimize

Run the feedback loop and confirm the failure mode is the one the user described, not a neighboring failure. Save the error message, error output, wrong result, or performance numbers.

Once the loop is red, remove inputs, callers, config, data, and steps one item at a time, rerunning after each removal. Done when everything left is load-bearing — removing any one of them turns it green. The minimal repro should become the material for the later regression test.

Non-deterministic issues don't need to fail every time; the reproduction rate and run count keep updating per Stage 2's record, and reaching a level that can discriminate between hypotheses is enough.

## Stage 4: Form and Vet Hypotheses

Before testing any hypothesis, list 3–5 ranked candidate causes. Use this format for each:

```text
Hypothesis: <specific mechanism>
Evidence: <existing facts that support or argue against it>
Prediction: if it holds, running <verification action> should show <result>
Verification: <the smallest action that changes exactly one variable>
```

Show the hypothesis list to the user and let them add domain knowledge. This checkpoint doesn't block: proceed to Stage 5 if there's no reply; it also doesn't replace the pre-implementation analysis confirmation gate.

## Stage 5: Targeted Instrumentation and Root-Cause Localization

Every probe must correspond to one hypothesis's prediction. Prefer a debugger/REPL; failing that, add minimal logging at inputs, outputs, and cross-layer boundaries. Never "print everywhere and grep." Probes inside a test/scratch directory can be written directly; temporary instrumentation in production code follows the lightweight instrumentation confirmation from Stage 2.

Temporary logs use one unique marker per round, `[DEBUG-<short-tag>]` (cleaned up by that prefix in Stage 8), and must never contain unredacted credentials or user content. Use a measurement tool for performance issues. Change one variable at a time, and record whether each probe strengthened or weakened a hypothesis.

Stage 5's completion bar: the root cause is pinned to a specific location in source, config, data, or a protocol boundary, and the feedback loop can explain "why this location produces the user's symptom." If still uncertain, go back to Stage 4 to re-rank hypotheses, or request new instrumentation/environment evidence; if still unable to localize it, stop per the Global Stop Conditions. Never write the top-ranked hypothesis down as fact.

## Stage 5b: Impact Surface and Historical Check

Complete this after the root cause is located and before the confirmation gate, to produce items 6–9 of the confirmation-gate report:

1. **Historical changes**: run `git log -L <start-line>,<end-line>:<file>` on the root-cause location (or `git blame` + `git log -S<keyword>`), and record the most recent 1–3 relevant commits/PRs/issues; write "no history" if the repo isn't git.
2. **Similar bugs**: search the repo's defect archive (e.g. `docs/bugs/`), issue tracker, and CHANGELOG once each with the raw error keywords and the module name; record hits, or "no hit (searched X/Y/Z)".
3. **Regression scope**: direct callers of the root-cause function/config → must-test; other entry points in the same module → suggested test; indirect dependents → spot-check; tests attached to a matching historical commit → must-test.
4. **Risk level**: internal logic only, no persistence = low; public interface, persistence, or protocol = medium; concurrency, migration, security, or payments = high.
5. **Options compared**: write at least one line each for "minimal fix" and one alternative; if there's only one option, write "no alternative, because: …".
6. **Investigation suggestions**: for evidence gaps still open, list logging/query/capture commands the user can run; write "none" if there are no gaps.

## Analysis Confirmation Gate (sent once, before Stage 6)

Output this and wait for explicit confirmation before the production fix and any Git write operation. The lightweight confirmations for test/scratch harnesses (Stage 2) and production instrumentation (Stage 5) were already handled inline and are not repeated here. The report always includes:

1. Structured intake and redacted evidence;
2. The feedback loop that goes red, its commands, and the actual results;
3. Minimal repro and reproduction rate;
4. 3–5 ranked hypotheses, predictions, and verification results;
5. Root-cause location and call chain;
6. Investigation suggestions for open evidence gaps (Stage 5b);
7. Historical changes and related past bugs (Stage 5b);
8. Must-test / suggested / spot-check regression scope (Stage 5b);
9. Risk level, change scope, and compared options (Stage 5b);
10. Open evidence, permission needs, and any conditions still to be met before implementation (pending confirmations, pending authorizations, material still needed from the user).

## Stage 6: Isolation and RED

Once the user has confirmed the plan, create an isolated worktree only if Git write authorization has been granted; record `ORIG_BRANCH` and the worktree path. Without authorization, never run `git worktree add` — edit in the current checkout per the user's choice, or pause and wait for authorization.

If Stage 2's loop is already a failing test on the correct seam, reuse it directly as the regression test and skip items 1–3 below. Otherwise, turn the minimal repro into a regression test on a correct test seam that represents the real call chain:

1. Prefer extending an existing test that already covers the same public entry point;
2. Test user-observable behavior, not "the mock got called";
3. If a shallow seam can't reproduce the real call chain, record "missing correct seam" and let Stage 2's original feedback loop stand in for RED/GREEN (Rule 5) — don't manufacture a false sense of safety;
4. Run the test and confirm it fails for the target symptom;
5. RED is not an import error, a fixture error, or an environment error.

## Stage 7: Root-Cause Fix and GREEN

Change only the minimal area where the root cause lives. Restore the original, unminimized scenario, get the regression test to GREEN first, then rerun Stage 2's original feedback loop and confirm the user's symptom is gone.

If GREEN isn't reached, or the original loop still reproduces the bug, that counts as one failed attempt: go back to Stage 4 to re-rank hypotheses; before the second attempt, just report the delta to the user rather than the full report again; two failed attempts means stop per Rule 9.

Run whatever static analysis, build, contract check, database check, native-platform check, or device verification fits the stack identified in Stage 0. Don't default to assuming any particular language, framework, package manager, database, or client tool.

## Stage 8: Cleanup, Verification, and Delivery

Before claiming completion:

- The original feedback loop no longer reproduces the bug;
- The regression test passes; any missing-correct-seam limitation is recorded;
- Every `[DEBUG-<short-tag>]` temporary probe has been removed (check off each marker recorded in Stage 5);
- Any throwaway harness/prototype has been deleted or moved to a clearly labeled debug location;
- The project's real full test suite, static checks, and any necessary end-to-end entry points have been run;
- Tests attached to a historical commit hit in Stage 5b are run separately and their result reported; write "historical check: no hit" if there was none;
- `git diff --check` passes;
- The actual commands, exit codes, pass/fail counts, and anything unverified are reported;
- The finally-confirmed root cause is written into the commit/PR description or a bug archive.

Project fit comes from "read the rules, then pick commands": mobile, desktop, server, CLI, browser, data-pipeline, and hardware systems each only run the verification layers that actually exist for them. If the repo mandates `docs/bugs/` or another defect-archive directory (stated explicitly in a rules file, or the directory already exists), archive regardless of whether an issue is linked, with at minimum the symptom, root cause, fix, changed files, historical check, RED/GREEN, regression scope, and anything not covered; if neither condition holds, write "no archive directory" in the report.

Only commit, write back to the issue, merge back into `ORIG_BRANCH`, delete the worktree, or push once the user has explicitly authorized it. Close out using the repo's existing issue/commit/merge flow; if there's no authorization, state clearly "no Git write operations were performed."

## Trigger Examples

Use this skill for:

- "This test is failing — build a stable minimal repro first, then fix it."
- "This endpoint occasionally returns a wrong result — diagnose it and add a regression check."
- "Performance has degraded recently — find the root cause from evidence, don't just guess it's the database."
- "Fix this cross-service/cross-platform bug and keep historical and E2E evidence."
- 「テストが落ちる。まず安定して再現する最小ケースを作ってから直して。」
- 「このエンドポイントがたまに間違った結果を返す。証拠ベースで原因を特定して直して。」
- “最近性能变差了，按证据找根因，不要直接猜是数据库。”
- “修复这个跨服务/跨平台 Bug，并保留历史和 E2E 证据。”

Don't use this skill for:

- A new feature, UX polish, or tuning already-correct behavior for performance: don't use this skill.
- Log-reading only, no file edits allowed: run only the read-only subset of Stages 0–5, and don't enter Stage 6.
- An architecture migration, a rework of multiple independent components, or work that needs a pre-approved task list: don't use this skill — switch to a planning flow with a pre-approved task list instead.
- A verified fix that just needs to be committed/written back to an issue: close it out via the repo's existing commit and issue flow; don't use this skill.
