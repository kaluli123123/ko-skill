# ko-skill

🌐 [English](README.md) | [中文](README.zh-CN.md) | **日本語**

独立した Agent Skill 集です——プレーンな指示ファイルで、特定のベンダーや製品に縛られず、どの AI でも使えます。ここにある Skill はすべて、オープンな [Agent Skills 仕様](https://agentskills.io)に従っています。

| Skill | 用途 |
|-------|------|
| [`ko-bug`](skills/ko-bug/SKILL.md) | 証拠優先のバグ診断・修正プロトコル：フィードバックループ → 再現と最小化 → 反証可能な仮説 → ターゲットを絞った計測 → 影響範囲・過去事例の確認 → 分析確認ゲート → RED/GREEN → 検証済みの成果物 |
| [`ko-github`](skills/ko-github/SKILL.md) | 大きな機能を作る前に、GitHub の再利用可能なプロジェクト、Starter、テンプレート、ライブラリを比較し、直接利用・二次開発・新規開発を証拠に基づいて選択 |

## インストール

### 推奨：`skills` CLI

このリポジトリはコミュニティメンテナンスの [`skills` CLI](https://github.com/vercel-labs/skills) から直接発見できます——コマンド 1 つで、77 種類以上の AI コーディングエージェント（Claude Code、Codex、Cursor、Windsurf、Gemini CLI、GitHub Copilot など）に対応し、あなたのマシンに入っているものを自動検出します：

```bash
npx skills add kaluli123123/ko-skill@ko-bug
npx skills add kaluli123123/ko-skill@ko-github
```

既存のオープンソース実装を再発明せずに大きな機能を作りたいときに `ko-github` を使います。小さなバグ修正、文言や UI の微調整、設定だけの変更、単純な内部ロジックの変更には不要です。

`-g` を付けると（現在のプロジェクトだけでなく）すべてのプロジェクトに対してグローバルにインストールされ、`-y` で確認プロンプトをスキップ、`-a <agent>`（例：`-a claude-code -a codex`）で自動検出ではなく特定のエージェントを指定できます。オプション全体は `npx skills --help`、対応エージェントとそれぞれのインストール先は [`skills` CLI の README](https://github.com/vercel-labs/skills) を参照してください。

### どんな AI でも使える——「Skill」機能は不要

各 Skill は単なる `SKILL.md` ファイルです：平文の指示にすぎません。テキストを読める AI であれば、`skills` CLI の有無にかかわらず従うことができます——チャット、システムプロンプト、カスタム指示欄などに以下を貼り付けてください：

```text
Read https://raw.githubusercontent.com/kaluli123123/ko-skill/main/skills/ko-github/SKILL.md
and follow it for the rest of this conversation.
```

バグの説明は英語・中国語・日本語のいずれでも構いません。どの AI に渡しても同じです。

## 評価（skill-up）

各 Skill はそれぞれ独自の `evals/` を同梱しており、[skill-up](https://alibaba.github.io/skill-up/) で実行します——skill-up 自体が特定のエンジンに縛られないため、同じテストスイートを異なる AI バックエンドに向けて実行できます：

```bash
skill-up validate skills/ko-bug/evals/eval.yaml
skill-up run      skills/ko-bug/evals/eval.yaml              # デフォルトは claude_code エンジン、ANTHROPIC_API_KEY が必要
skill-up run      skills/ko-bug/evals/eval.yaml --engine codex
skill-up validate skills/ko-github/evals/eval.yaml
```

`ko-bug` の 3 つのケースはそれぞれ核となる挙動を 1 つずつ固定しており、対応言語も 1 つずつ異なります：

| ケース | 言語 | 固定している挙動 |
|--------|------|-------------------|
| `has-failing-test` | 英語 | 既存の failing test をフィードバックループとして再利用する。分析確認ゲートより前は本番コードを変更しない |
| `no-seam-hitl` | 日本語 | テスト seam のない実機の偶発的なバグでは、構造化された HITL ループに切り替える。証拠を捏造したり、独断で打ち切ったりしない |
| `should-not-trigger-feature` | 中国語（中文） | 純粋な機能追加リクエストではバグ修正プロトコルを発動しない |

各ケースの judge はレスポンスの言語が期待どおりかも検証します（スクリプトレベルの正規表現、または `agent_judge` の判定基準）。そのため、このテストスイート自体が上記 Language Policy のリグレッションチェックも兼ねています。

実行時の成果物は `skills/ko-bug-workspace/` 配下に生成されます（skill-up がテスト対象 Skill と同じ階層に置きます。すでに `.gitignore` 済みです）。

`ko-github` にも 3 つのケースがあり、大きな機能の GitHub 調査、小さな修正の除外、情報不足時の確認をカバーします。

## ディレクトリ構成

```
skills/
  ko-bug/
    SKILL.md              # Skill 本体——どの AI にとっても本当に必要なのはこのファイルだけ
    agents/openai.yaml    # 任意：Codex 専用のインターフェースメタデータ。他のツールは無視する
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

`skills/<name>/SKILL.md` というこのディレクトリ構成は、`skills` CLI（および Codex、Claude Code、他の多くのエージェント）が Skill を自動発見する規約そのものです——追加のマニフェストは不要です。
