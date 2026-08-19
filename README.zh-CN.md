# ko-skill

🌐 [English](README.md) | **中文** | [日本語](README.ja.md)

一组独立的 Agent Skill——纯文本的指令文件，任何 AI 都能用，不绑定某一家产品。

| Skill | 用途 |
|-------|------|
| [`ko-bug`](skills/ko-bug/SKILL.md) | 证据优先的 Bug 诊断与修复协议：反馈循环 → 复现与最小化 → 可证伪假设 → 定向插桩 → 影响面/历史核查 → 分析确认门 → RED/GREEN → 验证交付 |

## 安装

### 任何 AI 都能用——不需要"技能"功能

每个 skill 就是一个 `SKILL.md` 文件：纯文本指令。任何能读文字的 AI 助手都能照着执行，不管它有没有正式的技能加载机制——把下面这段贴进对话、system prompt，或自定义指令栏就行：

```text
Read https://raw.githubusercontent.com/kaluli123123/ko-skill/main/skills/ko-bug/SKILL.md
and follow it for the rest of this conversation.
```

### 如果你的 AI 有原生技能目录，让它自己装

不少 coding agent 会自动加载某个专属目录下的 `SKILL.md`。如果你用的就是这种，把下面这段贴给它（它有 shell 权限，能自己弄清楚该装到哪，不用你替它查）：

```text
从 https://github.com/kaluli123123/ko-skill 安装 "ko-bug" 这个 Agent Skill，装到你自己
的技能目录——不要另建一个 clone 文件夹：
1. 判断你自己这个工具的用户级技能目录在哪（查你自己的文档或配置，找 SKILL.md 的加载
   规则，比如 $CODEX_HOME、$CLAUDE_CONFIG_DIR 这类环境变量，或者配置目录下的固定路径）。
2. 下载该仓库的 tarball，只把里面的 skills/ko-bug 解压到该目录下的 skills/ko-bug——
   目录不存在就先建好，已存在就替换掉旧内容。
3. 核实 skills/ko-bug/SKILL.md 能在该路径下读到（是一个真实目录，没有嵌在别的文件夹
   里）。
4. 告诉我安装到了哪个路径，以及怎么调用这个 skill（用你这个工具自己的调用方式）。
```

### 已验证的例子

下面两个是实测确认过的——用得上就直接抄，但不代表只支持这两个。每条命令都是自包含的，会按工具自己的解析方式（`$CODEX_HOME` / `$CLAUDE_CONFIG_DIR`，只有没设置时才退回 `~/.codex` / `~/.claude`）找到真正的技能目录，不留额外的 clone 文件夹，可以重复执行。

**Codex CLI**

```bash
mkdir -p "${CODEX_HOME:-$HOME/.codex}/skills" && rm -rf "${CODEX_HOME:-$HOME/.codex}/skills/ko-bug" && curl -fsSL https://github.com/kaluli123123/ko-skill/archive/refs/heads/main.tar.gz | tar -xz -C "${CODEX_HOME:-$HOME/.codex}/skills" --strip-components=2 ko-skill-main/skills/ko-bug && echo "ko-bug installed at ${CODEX_HOME:-$HOME/.codex}/skills/ko-bug — try: \$ko-bug <bug description>"
```

**Claude Code**

```bash
mkdir -p "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills" && rm -rf "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills/ko-bug" && curl -fsSL https://github.com/kaluli123123/ko-skill/archive/refs/heads/main.tar.gz | tar -xz -C "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills" --strip-components=2 ko-skill-main/skills/ko-bug && echo "ko-bug installed at ${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills/ko-bug — try: /ko-bug <bug description>"
```

用英文、中文或日文描述 bug 都可以，装到哪个 AI 上都一样。

## 评测（skill-up）

每个 skill 自带 `evals/`，用 [skill-up](https://alibaba.github.io/skill-up/) 运行——它本身就不绑定具体引擎，同一套用例可以换不同 AI 后端跑：

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
    SKILL.md              # 技能正文——任何 AI 真正需要的只有这一个文件
    agents/openai.yaml    # 可选：Codex 专属的界面元数据，其它工具会忽略它
    evals/
      eval.yaml
      cases/*.yaml
      fixtures/scripts/   # script judge
```
