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
2. For each one, download the repo's tarball and extract only skills/ko-bug straight into
   its default skills directory, creating the parent directory first if needed and
   replacing whatever is already there:
   - Codex CLI: ~/.agents/skills/ko-bug
   - Claude Code: ~/.claude/skills/ko-bug
   If you can't tell which one you are, install into both.
3. Verify skills/ko-bug/SKILL.md is readable at that path (a real directory, not left
   inside any other folder).
4. Tell me the install path(s) and how to invoke it ($ko-bug in Codex, /ko-bug in
   Claude Code).
```

### Manual install

Each command below is self-contained and installs straight into the default skills location — no clone folder left behind. Safe to rerun (it replaces the previous install).

**Codex CLI**

```bash
mkdir -p ~/.agents/skills && rm -rf ~/.agents/skills/ko-bug && curl -fsSL https://github.com/kaluli123123/ko-skill/archive/refs/heads/main.tar.gz | tar -xz -C ~/.agents/skills --strip-components=2 ko-skill-main/skills/ko-bug && echo 'ko-bug installed — try: $ko-bug <bug description>'
```

**Claude Code**

```bash
mkdir -p ~/.claude/skills && rm -rf ~/.claude/skills/ko-bug && curl -fsSL https://github.com/kaluli123123/ko-skill/archive/refs/heads/main.tar.gz | tar -xz -C ~/.claude/skills --strip-components=2 ko-skill-main/skills/ko-bug && echo 'ko-bug installed — try: /ko-bug <bug description>'
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
