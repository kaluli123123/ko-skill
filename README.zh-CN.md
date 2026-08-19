# ko-skill

🌐 [English](README.md) | **中文** | [日本語](README.ja.md)

一组独立的 Agent Skill，同时适用于 Codex CLI（用 `$name` 调用）和 Claude Code（用 `/name` 调用）。

| Skill | 用途 |
|-------|------|
| [`ko-bug`](skills/ko-bug/SKILL.md) | 证据优先的 Bug 诊断与修复协议：反馈循环 → 复现与最小化 → 可证伪假设 → 定向插桩 → 影响面/历史核查 → 分析确认门 → RED/GREEN → 验证交付 |

## 安装

### 让 AI 助手帮你装

把下面这段贴进 Claude Code、Codex CLI，或任何能跑 shell 命令的 coding agent：

```text
从 https://github.com/kaluli123123/ko-skill 安装 "ko-bug" 这个 Agent Skill：
1. 在 ~/.local/share/ko-skill 克隆或更新这个仓库（不存在就 git clone 这个 URL 到该路径；
   已存在就执行 `git -C ~/.local/share/ko-skill pull`）。
2. 判断你自己是 Codex CLI 还是 Claude Code（或者两者都是），然后把该仓库里的
   skills/ko-bug 软链到对应的技能目录——目标目录的父目录不存在就先建好：
   - Codex CLI：~/.agents/skills/ko-bug
   - Claude Code：~/.claude/skills/ko-bug
   分不清是哪一个就两个软链都建。
3. 核实软链能正确解析，且能通过它读到 skills/ko-bug/SKILL.md。
4. 告诉我安装到了哪些路径，以及怎么调用它（Codex 里用 $ko-bug，Claude Code 里用 /ko-bug）。
```

### 手动安装

把 `skills/<name>` 放到（或软链到）对应的技能目录：

```bash
git clone https://github.com/kaluli123123/ko-skill.git
# Codex CLI
ln -s "$PWD/ko-skill/skills/ko-bug" ~/.agents/skills/ko-bug
# Claude Code
ln -s "$PWD/ko-skill/skills/ko-bug" ~/.claude/skills/ko-bug
```

使用方式：在 Codex 里输入 `$ko-bug <bug 描述>`，或在 Claude Code 里输入 `/ko-bug <bug 描述>`——用英文、中文或日文描述都可以。

## 评测（skill-up）

每个 skill 自带 `evals/`，用 [skill-up](https://alibaba.github.io/skill-up/) 运行：

```bash
skill-up validate skills/ko-bug/evals/eval.yaml
skill-up run      skills/ko-bug/evals/eval.yaml              # 默认 claude_code 引擎，需要 ANTHROPIC_API_KEY
skill-up run      skills/ko-bug/evals/eval.yaml --engine codex
```

`ko-bug` 的三个用例分别锁住一处核心行为，并且各自使用一种被支持的语言：

| 用例 | 语言 | 锁住什么 |
|------|------|----------|
| `has-failing-test` | 英文 | 已有 failing test 时复用为反馈循环；分析确认门前生产代码保持不变 |
| `no-seam-hitl` | 日文（日本語） | 无测试 seam 的真机偶发 Bug 走结构化 HITL 循环，不编造证据、不擅自终止 |
| `should-not-trigger-feature` | 中文 | 纯新功能请求不触发 Bug 修复协议 |

每个用例的 judge 还会校验响应语言是否匹配预期（script 级别的正则，或 `agent_judge` 判据），所以这套用例同时也是上面 Language Policy 的回归检查。

运行产物落在 `skills/ko-bug-workspace/`（skill-up 会把它放在被测 Skill 的同级目录，已加入 `.gitignore`）。

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
