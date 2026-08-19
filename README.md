# ko-skill

一组独立的 Agent Skill，同时适用于 Codex CLI（`$name` 调用）与 Claude Code（`/name` 调用）。

| Skill | 用途 |
|-------|------|
| [`ko-bug`](skills/ko-bug/SKILL.md) | 证据优先的 Bug 诊断与修复协议：反馈循环 → 复现与最小化 → 可证伪假设 → 定向插桩 → 影响面/历史核查 → 分析确认门 → RED/GREEN → 验证交付 |

## 安装

把 `skills/<name>` 放到（或软链到）对应的技能目录：

```bash
git clone https://github.com/kaluli123123/ko-skill.git
# Codex CLI
ln -s "$PWD/ko-skill/skills/ko-bug" ~/.agents/skills/ko-bug
# Claude Code
ln -s "$PWD/ko-skill/skills/ko-bug" ~/.claude/skills/ko-bug
```

使用：Codex 里输入 `$ko-bug <bug 描述>`；Claude Code 里输入 `/ko-bug <bug 描述>`。

## 评测（skill-up）

每个 skill 自带 `evals/`，用 [skill-up](https://alibaba.github.io/skill-up/) 运行：

```bash
skill-up validate skills/ko-bug/evals/eval.yaml
skill-up run      skills/ko-bug/evals/eval.yaml              # 默认 claude_code 引擎，需 ANTHROPIC_API_KEY
skill-up run      skills/ko-bug/evals/eval.yaml --engine codex
```

`ko-bug` 的三个用例分别锁住三处核心行为：

| 用例 | 锁住什么 |
|------|----------|
| `has-failing-test` | 已有 failing test 时复用为反馈循环；分析确认门前不改生产代码 |
| `no-seam-hitl` | 无测试 seam 的真机偶发 Bug 走结构化 HITL，不编造证据、不擅自终止 |
| `should-not-trigger-feature` | 纯新功能请求不触发 Bug 协议 |

运行产物在 `skills/ko-bug/ko-bug-workspace/`（已 gitignore）。

## 目录结构

```
skills/
  ko-bug/
    SKILL.md              # 技能正文
    agents/openai.yaml    # Codex 界面元数据
    evals/
      eval.yaml
      cases/*.yaml
      fixtures/scripts/   # script judge
```
