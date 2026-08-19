# ko-skill

🌐 **English** | [中文](README.zh-CN.md) | [日本語](README.ja.md)

A set of standalone Agent Skills — plain instruction files any AI can use, not tied to one vendor or product.

| Skill | Purpose |
|-------|---------|
| [`ko-bug`](skills/ko-bug/SKILL.md) | Evidence-first bug diagnosis and fix protocol: feedback loop → reproduce & minimize → falsifiable hypotheses → targeted instrumentation → impact/historical check → analysis confirmation gate → RED/GREEN → verified delivery |

## Install

### Works with any AI — no "skills" feature required

Every skill is just a `SKILL.md` file: plain-language instructions. Any AI assistant that can read text can follow it, whether or not it has a formal skills mechanism — paste this into the chat, a system prompt, or a custom-instructions field:

```text
Read https://raw.githubusercontent.com/kaluli123123/ko-skill/main/skills/ko-bug/SKILL.md
and follow it for the rest of this conversation.
```

### If your AI has a native skills directory, let it install itself

Many coding agents auto-load `SKILL.md` files from a per-tool directory. If yours does, paste this into the agent (it has shell access, so it can work out its own convention rather than you having to know it):

```text
Install the "ko-bug" Agent Skill from https://github.com/kaluli123123/ko-skill into your
own skills directory — no separate clone folder:
1. Work out where your own tool's user-level skills directory is (check your own docs or
   config for a SKILL.md-loading convention, e.g. an env var like $CODEX_HOME or
   $CLAUDE_CONFIG_DIR, or a fixed path under your config directory).
2. Download the repo's tarball and extract only skills/ko-bug straight into that
   directory as skills/ko-bug, creating the parent directory first if needed and
   replacing whatever is already there.
3. Verify skills/ko-bug/SKILL.md is readable at that path (a real directory, not left
   inside any other folder).
4. Tell me the install path and how to invoke the skill (whatever your tool's own
   invocation convention is).
```

### Known examples

Verified concretely on these two — a quick copy-paste if you use one of them, not the full list of what's supported. Each command is self-contained, resolves the tool's real skills directory the way the tool itself does (`$CODEX_HOME` / `$CLAUDE_CONFIG_DIR`, falling back to `~/.codex` / `~/.claude` only if unset), leaves no clone folder behind, and is safe to rerun.

**Codex CLI**

```bash
mkdir -p "${CODEX_HOME:-$HOME/.codex}/skills" && rm -rf "${CODEX_HOME:-$HOME/.codex}/skills/ko-bug" && curl -fsSL https://github.com/kaluli123123/ko-skill/archive/refs/heads/main.tar.gz | tar -xz -C "${CODEX_HOME:-$HOME/.codex}/skills" --strip-components=2 ko-skill-main/skills/ko-bug && echo "ko-bug installed at ${CODEX_HOME:-$HOME/.codex}/skills/ko-bug — try: \$ko-bug <bug description>"
```

**Claude Code**

```bash
mkdir -p "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills" && rm -rf "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills/ko-bug" && curl -fsSL https://github.com/kaluli123123/ko-skill/archive/refs/heads/main.tar.gz | tar -xz -C "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills" --strip-components=2 ko-skill-main/skills/ko-bug && echo "ko-bug installed at ${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills/ko-bug — try: /ko-bug <bug description>"
```

Works with a bug description in English, Chinese, or Japanese, on any AI you give it to.

## Evals (skill-up)

Each skill ships its own `evals/`, run with [skill-up](https://alibaba.github.io/skill-up/) — itself engine-agnostic, so the same suite can target different AI backends:

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
    SKILL.md              # skill body — the only file any AI actually needs
    agents/openai.yaml    # optional: Codex-specific interface metadata, ignored elsewhere
    evals/
      eval.yaml
      cases/*.yaml
      fixtures/scripts/   # script judge
```
