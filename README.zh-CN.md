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
从 https://github.com/kaluli123123/ko-skill 安装 "ko-bug" 这个 Agent Skill，直接装到
默认的技能目录——不要另建一个 clone 文件夹：
1. 判断你自己是 Codex CLI 还是 Claude Code（或者两者都是）。
2. 针对每一种，按该工具自己的方式解析出它真正的技能目录，不要写死路径：
   - Codex CLI：${CODEX_HOME:-$HOME/.codex}/skills
   - Claude Code：${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills
3. 下载该仓库的 tarball，只把里面的 skills/ko-bug 解压到该目录下的 skills/ko-bug——
   目录不存在就先建好，已存在就替换掉旧内容。
4. 核实 skills/ko-bug/SKILL.md 能在该路径下读到（是一个真实目录，没有嵌在别的文件夹
   里）。
5. 告诉我安装到了哪些路径，以及怎么调用它（Codex 里用 $ko-bug，Claude Code 里用
   /ko-bug）。
```

### 手动安装

下面每条命令都是自包含的，会直接装到该工具真正的技能目录——路径按工具自己的解析方式来（`$CODEX_HOME` / `$CLAUDE_CONFIG_DIR`，只有在没设置时才退回 `~/.codex` / `~/.claude`），不是写死的路径。不会留下额外的 clone 文件夹。可以重复执行（会替换掉上一次的安装）。

**Codex CLI**

```bash
mkdir -p "${CODEX_HOME:-$HOME/.codex}/skills" && rm -rf "${CODEX_HOME:-$HOME/.codex}/skills/ko-bug" && curl -fsSL https://github.com/kaluli123123/ko-skill/archive/refs/heads/main.tar.gz | tar -xz -C "${CODEX_HOME:-$HOME/.codex}/skills" --strip-components=2 ko-skill-main/skills/ko-bug && echo "ko-bug installed at ${CODEX_HOME:-$HOME/.codex}/skills/ko-bug — try: \$ko-bug <bug description>"
```

**Claude Code**

```bash
mkdir -p "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills" && rm -rf "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills/ko-bug" && curl -fsSL https://github.com/kaluli123123/ko-skill/archive/refs/heads/main.tar.gz | tar -xz -C "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills" --strip-components=2 ko-skill-main/skills/ko-bug && echo "ko-bug installed at ${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills/ko-bug — try: /ko-bug <bug description>"
```

用英文、中文或日文描述 bug 都可以。

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
