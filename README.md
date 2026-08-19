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
Install the "ko-bug" Agent Skill from https://github.com/kaluli123123/ko-skill:
1. Clone or update the repo at ~/.local/share/ko-skill (git clone the URL there if
   it doesn't exist yet, otherwise `git -C ~/.local/share/ko-skill pull`).
2. Work out whether you're running as Codex CLI or Claude Code (or both), then
   symlink skills/ko-bug from that repo into the matching skills directory,
   creating the parent directory first if needed:
   - Codex CLI: ~/.agents/skills/ko-bug
   - Claude Code: ~/.claude/skills/ko-bug
   If you can't tell which one you are, create both symlinks.
3. Verify the symlink resolves and skills/ko-bug/SKILL.md is readable through it.
4. Tell me the install path(s) and how to invoke it ($ko-bug in Codex, /ko-bug in
   Claude Code).
```

### Manual install

Each command below is self-contained: run it as-is, no separate clone step. It clones (or updates) the repo into `~/.local/share/ko-skill` and symlinks `skills/ko-bug` into place; safe to rerun.

**Codex CLI**

```bash
mkdir -p ~/.agents/skills && (git clone https://github.com/kaluli123123/ko-skill.git ~/.local/share/ko-skill 2>/dev/null || git -C ~/.local/share/ko-skill pull -q) && ln -sfn ~/.local/share/ko-skill/skills/ko-bug ~/.agents/skills/ko-bug && echo 'ko-bug installed — try: $ko-bug <bug description>'
```

**Claude Code**

```bash
mkdir -p ~/.claude/skills && (git clone https://github.com/kaluli123123/ko-skill.git ~/.local/share/ko-skill 2>/dev/null || git -C ~/.local/share/ko-skill pull -q) && ln -sfn ~/.local/share/ko-skill/skills/ko-bug ~/.claude/skills/ko-bug && echo 'ko-bug installed — try: /ko-bug <bug description>'
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
