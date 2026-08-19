# ko-skill

🌐 [English](README.md) | [中文](README.zh-CN.md) | **日本語**

Codex CLI（`$name` で呼び出し）と Claude Code（`/name` で呼び出し）の両方で使える、独立した Agent Skill 集です。

| Skill | 用途 |
|-------|------|
| [`ko-bug`](skills/ko-bug/SKILL.md) | 証拠優先のバグ診断・修正プロトコル：フィードバックループ → 再現と最小化 → 反証可能な仮説 → ターゲットを絞った計測 → 影響範囲・過去事例の確認 → 分析確認ゲート → RED/GREEN → 検証済みの成果物 |

## インストール

### AI アシスタントにインストールしてもらう

以下を Claude Code、Codex CLI、またはシェルを実行できる任意のコーディングエージェントに貼り付けてください：

```text
https://github.com/kaluli123123/ko-skill から "ko-bug" という Agent Skill を
インストールしてください：
1. ~/.local/share/ko-skill にリポジトリをクローンまたは更新する（存在しなければ
   そのパスに git clone、存在すれば `git -C ~/.local/share/ko-skill pull`）。
2. 自分が Codex CLI か Claude Code か（あるいは両方か）を判断し、そのリポジトリの
   skills/ko-bug を対応する Skill ディレクトリにシンボリックリンクする——親ディレ
   クトリが無ければ先に作成する：
   - Codex CLI：~/.agents/skills/ko-bug
   - Claude Code：~/.claude/skills/ko-bug
   どちらか判断できない場合は両方にシンボリックリンクを作る。
3. シンボリックリンクが正しく解決され、それ経由で skills/ko-bug/SKILL.md が読める
   ことを確認する。
4. インストール先のパスと、呼び出し方（Codex では $ko-bug、Claude Code では
   /ko-bug）を私に伝える。
```

### 手動インストール

以下のコマンドはそれぞれ単体で完結しています。個別に clone する手順は不要で、これ 1 行を実行するだけです。`~/.local/share/ko-skill` にリポジトリをクローン（または更新）し、`skills/ko-bug` をシンボリックリンクします。何度実行しても安全です。

**Codex CLI**

```bash
mkdir -p ~/.agents/skills && (git clone https://github.com/kaluli123123/ko-skill.git ~/.local/share/ko-skill 2>/dev/null || git -C ~/.local/share/ko-skill pull -q) && ln -sfn ~/.local/share/ko-skill/skills/ko-bug ~/.agents/skills/ko-bug && echo 'ko-bug installed — try: $ko-bug <bug description>'
```

**Claude Code**

```bash
mkdir -p ~/.claude/skills && (git clone https://github.com/kaluli123123/ko-skill.git ~/.local/share/ko-skill 2>/dev/null || git -C ~/.local/share/ko-skill pull -q) && ln -sfn ~/.local/share/ko-skill/skills/ko-bug ~/.claude/skills/ko-bug && echo 'ko-bug installed — try: /ko-bug <bug description>'
```

バグの説明は英語・中国語・日本語のいずれでも構いません。

## 評価（skill-up）

各 Skill はそれぞれ独自の `evals/` を同梱しており、[skill-up](https://alibaba.github.io/skill-up/) で実行します：

```bash
skill-up validate skills/ko-bug/evals/eval.yaml
skill-up run      skills/ko-bug/evals/eval.yaml              # デフォルトは claude_code エンジン、ANTHROPIC_API_KEY が必要
skill-up run      skills/ko-bug/evals/eval.yaml --engine codex
```

`ko-bug` の 3 つのケースはそれぞれ核となる挙動を 1 つずつ固定しており、対応言語も 1 つずつ異なります：

| ケース | 言語 | 固定している挙動 |
|--------|------|-------------------|
| `has-failing-test` | 英語 | 既存の failing test をフィードバックループとして再利用する。分析確認ゲートより前は本番コードを変更しない |
| `no-seam-hitl` | 日本語 | テスト seam のない実機の偶発的なバグでは、構造化された HITL ループに切り替える。証拠を捏造したり、独断で打ち切ったりしない |
| `should-not-trigger-feature` | 中国語（中文） | 純粋な機能追加リクエストではバグ修正プロトコルを発動しない |

各ケースの judge はレスポンスの言語が期待どおりかも検証します（スクリプトレベルの正規表現、または `agent_judge` の判定基準）。そのため、このテストスイート自体が上記 Language Policy のリグレッションチェックも兼ねています。

実行時の成果物は `skills/ko-bug-workspace/` 配下に生成されます（skill-up がテスト対象 Skill と同じ階層に置きます。すでに `.gitignore` 済みです）。

## ディレクトリ構成

```
skills/
  ko-bug/
    SKILL.md              # Skill 本体
    agents/openai.yaml    # Codex 用インターフェースメタデータ
    evals/
      eval.yaml
      cases/*.yaml
      fixtures/scripts/   # script judge
```
