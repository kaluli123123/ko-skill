# ko-skill

🌐 [English](README.md) | **中文** | [日本語](README.ja.md) | [한국어](README.ko.md) | [Español](README.es.md) | [Français](README.fr.md) | [Português](README.pt.md)

一组独立的 Agent Skill——纯文本的指令文件，任何 AI 都能用，不绑定某一家产品。这里的 skill 都遵循开放的 [Agent Skills 规范](https://agentskills.io)。

| Skill | 用途 |
|-------|------|
| [`ko-bug`](skills/ko-bug/SKILL.md) | 证据优先的 Bug 诊断与修复协议：反馈循环 → 复现与最小化 → 可证伪假设 → 定向插桩 → 影响面/历史核查 → 分析确认门 → RED/GREEN → 验证交付 |
| [`ko-github`](skills/ko-github/SKILL.md) | 在开发较大功能前，查找并比较 GitHub 上可复用的项目、Starter、模板和库；基于证据决定直接使用、二次开发或从零开发 |
| [`ko-github-issues`](skills/ko-github-issues/SKILL.md) | 从一个仓库 URL 出发，把一个可复现缺陷交付为一个经过验证的 GitHub Issue 和 PR，同时避开已认领工作并如实报告未完成门槛 |

## 安装

### 推荐：`skills` CLI

本仓可以被社区维护的 [`skills` CLI](https://github.com/vercel-labs/skills) 直接发现——一条命令，覆盖 77+ 种 AI coding agent（Claude Code、Codex、Cursor、Windsurf、Gemini CLI、GitHub Copilot 等），会自动检测你机器上装了哪些：

```bash
npx skills add kaluli123123/ko-skill@ko-bug
npx skills add kaluli123123/ko-skill@ko-github
npx skills add kaluli123123/ko-skill@ko-github-issues
```

准备开发较大功能、想避免重复造轮子时使用 `ko-github`。小型 Bug 修复、文案或 UI 微调、纯配置修改、简单的内部逻辑调整不需要使用它。

明确需要将可复现 Bug 交付为 Issue 和 Pull Request 时使用 `ko-github-issues`。只提供仓库 URL 即可，默认交付一个 Bug、每个 Issue 一个 PR；它不用于只读状态检查或现有 PR 评审。策略选项和完整示例见[使用指南](skills/ko-github-issues/references/usage.md)。

加 `-g` 装成全局（对所有项目生效，而不只是当前这个），加 `-y` 跳过确认，或用 `-a <agent>`（比如 `-a claude-code -a codex`）指定具体装到哪几个 agent，而不是自动检测。完整选项跑 `npx skills --help`，每个支持的 agent 及其安装路径见 [`skills` CLI 的 README](https://github.com/vercel-labs/skills)。

### 任何 AI 都能用——不需要"技能"功能

每个 skill 就是一个 `SKILL.md` 文件：纯文本指令。任何能读文字的 AI 助手都能照着执行，不管有没有 `skills` CLI——把下面这段贴进对话、system prompt，或自定义指令栏就行：

```text
Read https://raw.githubusercontent.com/kaluli123123/ko-skill/main/skills/ko-github/SKILL.md
and follow it for the rest of this conversation.
```

支持用英文、中文、日文、韩文、西班牙文、法文或葡萄牙文描述 bug，装到哪个 AI 上都一样。

## 评测（skill-up）

每个 skill 自带 `evals/`，用 [skill-up](https://alibaba.github.io/skill-up/) 运行——它本身就不绑定具体引擎，同一套用例可以换不同 AI 后端跑：

```bash
skill-up validate skills/ko-bug/evals/eval.yaml
skill-up run      skills/ko-bug/evals/eval.yaml              # 默认 claude_code 引擎，需要 ANTHROPIC_API_KEY
skill-up run      skills/ko-bug/evals/eval.yaml --engine codex
skill-up validate skills/ko-github/evals/eval.yaml
skill-up validate skills/ko-github-issues/evals/eval.yaml
```

`ko-bug` 的三个用例分别锁住一处核心行为，并且各自使用一种被支持的语言：

| 用例 | 语言 | 锁住什么 |
|------|------|----------|
| `has-failing-test` | 英文 | 已有 failing test 时复用为反馈循环；分析确认门前生产代码保持不变 |
| `no-seam-hitl` | 日文（日本語） | 无测试 seam 的真机偶发 Bug 走结构化 HITL 循环，不编造证据、不擅自终止 |
| `should-not-trigger-feature` | 中文 | 纯新功能请求不触发 Bug 修复协议 |

每个用例的 judge 还会校验响应语言是否匹配预期（script 级别的正则，或 `agent_judge` 判据），所以这套用例同时也是上面 Language Policy 的回归检查。

运行产物落在 `skills/ko-bug-workspace/`（skill-up 会把它放在被测 Skill 的同级目录，已加入 `.gitignore`）。

`ko-github` 也自带三个用例，覆盖较大功能的 GitHub 检索、小型修改的跳过条件，以及信息不足时的需求收集。

`ko-github-issues` 自带三个用例，覆盖仅 URL 输入的默认值、代码审计前的询问门，以及只读状态查询排除。

## 目录结构

```
skills/
  ko-bug/
    SKILL.md              # 技能正文——任何 AI 真正需要的只有这一个文件
    evals/
      eval.yaml
      cases/*.yaml
  ko-github/
    SKILL.md
    evals/
      eval.yaml
      cases/*.yaml
      fixtures/scripts/   # script judge
  ko-github-issues/
    SKILL.md
    references/usage.md
    evals/
      eval.yaml
      cases/*.yaml
```

`skills/<name>/SKILL.md` 这个目录结构，正好就是 `skills` CLI（以及 Codex、Claude Code 和大多数其它 agent）自动发现技能的约定——不需要额外写一份 manifest。
