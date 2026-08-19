# ko-skill

🌐 **English** | [中文](README.zh-CN.md) | [日本語](README.ja.md)

A set of standalone Agent Skills, usable from both Codex CLI (invoke with `$name`) and Claude Code (invoke with `/name`).

| Skill | Purpose |
|-------|---------|
| [`ko-bug`](skills/ko-bug/SKILL.md) | Evidence-first bug diagnosis and fix protocol: feedback loop → reproduce & minimize → falsifiable hypotheses → targeted instrumentation → impact/historical check → analysis confirmation gate → RED/GREEN → verified delivery |

## Install

### Ask an AI assistant to install it

Paste this into Claude Code, Codex CLI, or any coding agent with shell access:

```text
Install the "ko-bug" Agent Skill from https://github.com/kaluli123123/ko-skill directly
into the default skills location — no separate clone folder:
1. Work out whether you're running as Codex CLI or Claude Code (or both).
2. For each one, resolve its real skills directory the same way that tool does — don't
   hardcode a path:
   - Codex CLI: ${CODEX_HOME:-$HOME/.codex}/skills
   - Claude Code: ${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills
3. Download the repo's tarball and extract only skills/ko-bug straight into that
   directory as skills/ko-bug, creating the parent directory first if needed and
   replacing whatever is already there.
4. Verify skills/ko-bug/SKILL.md is readable at that path (a real directory, not left
   inside any other folder).
5. Tell me the install path(s) and how to invoke it ($ko-bug in Codex, /ko-bug in
   Claude Code).
```

### Manual install

Each command below is self-contained and installs straight into that tool's real skills directory — resolved the same way the tool itself resolves it (`$CODEX_HOME` / `$CLAUDE_CONFIG_DIR`, falling back to `~/.codex` / `~/.claude` only if unset), not a hardcoded path. No clone folder left behind. Safe to rerun (it replaces the previous install).

**Codex CLI**

```bash
mkdir -p "${CODEX_HOME:-$HOME/.codex}/skills" && rm -rf "${CODEX_HOME:-$HOME/.codex}/skills/ko-bug" && curl -fsSL https://github.com/kaluli123123/ko-skill/archive/refs/heads/main.tar.gz | tar -xz -C "${CODEX_HOME:-$HOME/.codex}/skills" --strip-components=2 ko-skill-main/skills/ko-bug && echo "ko-bug installed at ${CODEX_HOME:-$HOME/.codex}/skills/ko-bug — try: \$ko-bug <bug description>"
```

**Claude Code**

```bash
mkdir -p "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills" && rm -rf "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills/ko-bug" && curl -fsSL https://github.com/kaluli123123/ko-skill/archive/refs/heads/main.tar.gz | tar -xz -C "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills" --strip-components=2 ko-skill-main/skills/ko-bug && echo "ko-bug installed at ${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills/ko-bug — try: /ko-bug <bug description>"
```

Works with a bug description in English, Chinese, or Japanese.

## Evals (skill-up)

Each skill ships its own `evals/`, run with [skill-up](https://alibaba.github.io/skill-up/):

```bash
skill-up validate skills/ko-bug/evals/eval.yaml
skill-up run      skills/ko-bug/evals/eval.yaml              # default claude_code engine, needs ANTHROPIC_API_KEY
skill-up run      skills/ko-bug/evals/eval.yaml --engine codex
```

`ko-bug`'s three cases each lock down one core behavior, one in each supported language:

| Case | Language | Locks down |
|------|----------|-------------|
| `has-failing-test` | English | Reuses an existing failing test as the feedback loop; production code stays untouched before the analysis confirmation gate |
| `no-seam-hitl` | Japanese (日本語) | A real-device flaky bug with no test seam runs a structured HITL loop, without fabricating evidence or bailing out unilaterally |
| `should-not-trigger-feature` | Chinese (中文) | A plain feature request does not trigger the bugfix protocol |

Each case's judge also asserts the response matches the expected language (script-level regex or an `agent_judge` criterion), so the suite doubles as a regression check for the Language Policy above.

Run artifacts land in `skills/ko-bug-workspace/` (skill-up places them next to the skill under test; already gitignored).

## Layout

```
skills/
  ko-bug/
    SKILL.md              # skill body
    agents/openai.yaml    # Codex interface metadata
    evals/
      eval.yaml
      cases/*.yaml
      fixtures/scripts/   # script judge
```
