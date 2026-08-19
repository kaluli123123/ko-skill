# ko-skill

🌐 [English](README.md) | [中文](README.zh-CN.md) | **日本語**

独立した Agent Skill 集です——プレーンな指示ファイルで、特定のベンダーや製品に縛られず、どの AI でも使えます。

| Skill | 用途 |
|-------|------|
| [`ko-bug`](skills/ko-bug/SKILL.md) | 証拠優先のバグ診断・修正プロトコル：フィードバックループ → 再現と最小化 → 反証可能な仮説 → ターゲットを絞った計測 → 影響範囲・過去事例の確認 → 分析確認ゲート → RED/GREEN → 検証済みの成果物 |

## インストール

### どんな AI でも使える——「Skill」機能は不要

各 Skill は単なる `SKILL.md` ファイルです：平文の指示にすぎません。テキストを読める AI であれば、正式な Skill 機構の有無にかかわらず従うことができます——チャット、システムプロンプト、カスタム指示欄などに以下を貼り付けてください：

```text
Read https://raw.githubusercontent.com/kaluli123123/ko-skill/main/skills/ko-bug/SKILL.md
and follow it for the rest of this conversation.
```

### 自分の AI にネイティブな Skill ディレクトリがあるなら、自分でインストールさせる

多くのコーディングエージェントは、専用ディレクトリから `SKILL.md` を自動的に読み込みます。あなたのツールがそうであれば、以下をそのエージェント自身に貼り付けてください（シェルを実行できるので、あなたが調べなくても自分の流儀を自分で把握できます）：

```text
https://github.com/kaluli123123/ko-skill から "ko-bug" という Agent Skill を、自分自身の
Skill ディレクトリへインストールしてください——別の clone 用フォルダは作らないこと：
1. 自分のツールのユーザーレベル Skill ディレクトリがどこかを調べる（自分のドキュメント
   や設定を確認し、SKILL.md を読み込む規則を探す——例えば $CODEX_HOME や
   $CLAUDE_CONFIG_DIR のような環境変数、または設定ディレクトリ配下の固定パスなど）。
2. リポジトリの tarball をダウンロードし、その中の skills/ko-bug だけをそのディレク
   トリ配下の skills/ko-bug へ直接展開する——親ディレクトリが無ければ先に作成し、既に
   あれば中身を新しいもので置き換える。
3. そのパスで skills/ko-bug/SKILL.md が読めること（他のフォルダの中に入っていない、
   実体のディレクトリであること）を確認する。
4. インストール先のパスと、Skill の呼び出し方（あなたのツール自身の呼び出し方式）を
   私に伝える。
```

### 確認済みの例

以下の 2 つは具体的に動作確認済みです——使っているならそのままコピペで使えますが、対応がこの 2 つに限られるわけではありません。各コマンドは単体で完結しており、そのツール自身と同じ方法（`$CODEX_HOME` / `$CLAUDE_CONFIG_DIR`。未設定のときだけ `~/.codex` / `~/.claude` にフォールバック）で実際の Skill ディレクトリを解決し、余分な clone フォルダを残さず、何度実行しても安全です。

**Codex CLI**

```bash
mkdir -p "${CODEX_HOME:-$HOME/.codex}/skills" && rm -rf "${CODEX_HOME:-$HOME/.codex}/skills/ko-bug" && curl -fsSL https://github.com/kaluli123123/ko-skill/archive/refs/heads/main.tar.gz | tar -xz -C "${CODEX_HOME:-$HOME/.codex}/skills" --strip-components=2 ko-skill-main/skills/ko-bug && echo "ko-bug installed at ${CODEX_HOME:-$HOME/.codex}/skills/ko-bug — try: \$ko-bug <bug description>"
```

**Claude Code**

```bash
mkdir -p "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills" && rm -rf "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills/ko-bug" && curl -fsSL https://github.com/kaluli123123/ko-skill/archive/refs/heads/main.tar.gz | tar -xz -C "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills" --strip-components=2 ko-skill-main/skills/ko-bug && echo "ko-bug installed at ${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills/ko-bug — try: /ko-bug <bug description>"
```

バグの説明は英語・中国語・日本語のいずれでも構いません。どの AI に渡しても同じです。

## 評価（skill-up）

各 Skill はそれぞれ独自の `evals/` を同梱しており、[skill-up](https://alibaba.github.io/skill-up/) で実行します——skill-up 自体が特定のエンジンに縛られないため、同じテストスイートを異なる AI バックエンドに向けて実行できます：

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
    SKILL.md              # Skill 本体——どの AI にとっても本当に必要なのはこのファイルだけ
    agents/openai.yaml    # 任意：Codex 専用のインターフェースメタデータ。他のツールは無視する
    evals/
      eval.yaml
      cases/*.yaml
      fixtures/scripts/   # script judge
```
