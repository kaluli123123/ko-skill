# ko-skill

A set of standalone Agent Skills, usable from both Codex CLI (invoke with `$name`) and Claude Code (invoke with `/name`).

| Skill | Purpose |
|-------|---------|
| [`ko-bug`](skills/ko-bug/SKILL.md) | Evidence-first bug diagnosis and fix protocol: feedback loop → reproduce & minimize → falsifiable hypotheses → targeted instrumentation → impact/historical check → analysis confirmation gate → RED/GREEN → verified delivery |

## Supported languages

`ko-bug` is built for an international audience, not a Chinese-only one. `SKILL.md` is authored in English and carries an explicit **Language Policy**: it detects the language of the user's current message — English, Chinese (中文), or Japanese (日本語), the three languages currently supported — and answers in kind (reports, hypothesis lists, the confirmation gate, HITL step tables, etc.), defaulting to English for any other language or when detection fails. Technical identifiers (paths, commands, code, log/error text, protocol fields) are never translated.

## Install

Drop (or symlink) `skills/<name>` into the matching skills directory:

```bash
git clone https://github.com/kaluli123123/ko-skill.git
# Codex CLI
ln -s "$PWD/ko-skill/skills/ko-bug" ~/.agents/skills/ko-bug
# Claude Code
ln -s "$PWD/ko-skill/skills/ko-bug" ~/.claude/skills/ko-bug
```

Use it: type `$ko-bug <bug description>` in Codex, or `/ko-bug <bug description>` in Claude Code — in English, Chinese, or Japanese.

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
