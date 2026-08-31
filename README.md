# ko-skill

🌐 **English** | [中文](README.zh-CN.md) | [日本語](README.ja.md)

A set of standalone Agent Skills — plain instruction files any AI can use, not tied to one vendor or product. Skills here follow the open [Agent Skills specification](https://agentskills.io).

| Skill | Purpose |
|-------|---------|
| [`ko-bug`](skills/ko-bug/SKILL.md) | Evidence-first bug diagnosis and fix protocol: feedback loop → reproduce & minimize → falsifiable hypotheses → targeted instrumentation → impact/historical check → analysis confirmation gate → RED/GREEN → verified delivery |
| [`ko-github`](skills/ko-github/SKILL.md) | Before building a substantial feature, find and compare reusable GitHub projects, starters, templates, and libraries; choose direct use, customization, or greenfield development with evidence |

## Install

### Recommended: the `skills` CLI

This repo is discoverable by the community-maintained [`skills` CLI](https://github.com/vercel-labs/skills) — one command, works across 77+ AI coding agents (Claude Code, Codex, Cursor, Windsurf, Gemini CLI, GitHub Copilot, and more), auto-detecting whichever ones you already have installed:

```bash
npx skills add kaluli123123/ko-skill@ko-bug
npx skills add kaluli123123/ko-skill@ko-github
```

Use `ko-github` when you are about to build a substantial feature and want to avoid reinventing an existing open-source solution. It is not needed for small bug fixes, copy or UI tweaks, configuration-only changes, or simple internal edits.

Add `-g` to install globally (all your projects) instead of just the current one, `-y` to skip confirmation prompts, or `-a <agent>` (e.g. `-a claude-code -a codex`) to target specific agents instead of auto-detecting. Run `npx skills --help` for the full option list, or see the [`skills` CLI README](https://github.com/vercel-labs/skills) for every supported agent and its install path.

### Any AI, even without a "skills" feature

Every skill is just a `SKILL.md` file: plain-language instructions. Any AI assistant that can read text can follow it, `skills` CLI or not — paste this into the chat, a system prompt, or a custom-instructions field:

```text
Read https://raw.githubusercontent.com/kaluli123123/ko-skill/main/skills/ko-github/SKILL.md
and follow it for the rest of this conversation.
```

Works with a bug description in English, Chinese, or Japanese, on any AI you give it to.

## Evals (skill-up)

Each skill ships its own `evals/`, run with [skill-up](https://alibaba.github.io/skill-up/) — itself engine-agnostic, so the same suite can target different AI backends:

```bash
skill-up validate skills/ko-bug/evals/eval.yaml
skill-up run      skills/ko-bug/evals/eval.yaml              # default claude_code engine, needs ANTHROPIC_API_KEY
skill-up run      skills/ko-bug/evals/eval.yaml --engine codex
skill-up validate skills/ko-github/evals/eval.yaml
```

`ko-bug`'s three cases each lock down one core behavior, one in each supported language:

| Case | Language | Locks down |
|------|----------|-------------|
| `has-failing-test` | English | Reuses an existing failing test as the feedback loop; production code stays untouched before the analysis confirmation gate |
| `no-seam-hitl` | Japanese (日本語) | A real-device flaky bug with no test seam runs a structured HITL loop, without fabricating evidence or bailing out unilaterally |
| `should-not-trigger-feature` | Chinese (中文) | A plain feature request does not trigger the bugfix protocol |

Each case's judge also asserts the response matches the expected language (script-level regex or an `agent_judge` criterion), so the suite doubles as a regression check for the Language Policy above.

Run artifacts land in `skills/ko-bug-workspace/` (skill-up places them next to the skill under test; already gitignored).

`ko-github` also includes three cases covering substantial-feature research, small-fix exclusions, and missing-context intake.

## Layout

```
skills/
  ko-bug/
    SKILL.md              # skill body — the only file any AI actually needs
    agents/openai.yaml    # optional: Codex-specific interface metadata, ignored elsewhere
  ko-github/
    SKILL.md
    agents/openai.yaml
    evals/
      eval.yaml
      cases/*.yaml
    evals/
      eval.yaml
      cases/*.yaml
      fixtures/scripts/   # script judge
```

The `skills/<name>/SKILL.md` layout matches what the `skills` CLI (and Codex, Claude Code, and most other agents) auto-discover — no extra manifest needed.
