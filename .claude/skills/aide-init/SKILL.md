---
name: aide-init
description: 業務別にプロジェクトを初期化する。フォルダ構成・CLAUDE.md（マスター）と参照ファイルを一括生成する
---

# aide-init: プロジェクト初期化

ユーザーに業務タイプを確認し、対応するプロジェクト構成を生成する。

## 手順

### 1. プロジェクト情報の確認

ユーザーに以下を確認する（引数で指定されている場合はスキップ）：

- **業務タイプ**（複数選択可）: `dev`（新規開発） / `ops`（運用保守）
  - 例: `dev+ops` のように組み合わせ可能
  - 単一選択でもよい
- **利用AIツール**: `claude+copilot`（デフォルト） / `codex` / `claude` / `copilot`
  - 省略時は `claude+copilot` とする
- **プロジェクト名 / システム名**
- **技術スタック**（わかる範囲で）

### 2. フォルダ構成の生成

選択された業務タイプに応じて、該当するフォルダをすべて生成する。複数選択時はマージして生成する。

#### dev を含む場合

```
docs-ドキュメント/
├── 00_pm-管理/
│   ├── issues-課題.md
│   ├── schedule-スケジュール.md
│   ├── estimate-見積もり.md
│   └── slides-資料/
│       └── export/
├── 01_requirements-要件/
│   ├── artifacts-成果物/
│   ├── brainstorms-検討履歴/
│   │   └── index.md
│   ├── meeting-notes-打合せ/
│   ├── reviews-レビュー/
│   └── slides-資料/
│       └── export/
├── 02_design-設計/
│   ├── artifacts-成果物/
│   ├── brainstorms-検討履歴/
│   │   └── index.md
│   ├── meeting-notes-打合せ/
│   ├── reviews-レビュー/
│   └── slides-資料/
│       └── export/
├── 03_plans-製造計画/
│   ├── artifacts-成果物/
│   ├── brainstorms-検討履歴/
│   │   └── index.md
│   ├── meeting-notes-打合せ/
│   ├── reviews-レビュー/
│   └── slides-資料/
│       └── export/
├── 04_testing-テスト/
│   ├── artifacts-成果物/
│   ├── evidence-証跡/
│   │   ├── unit-単体/
│   │   ├── integration-結合/
│   │   └── quality-品質/
│   ├── brainstorms-検討履歴/
│   │   └── index.md
│   └── reviews-レビュー/
src/
tests/
```

#### ops を含む場合

```
docs-ドキュメント/
├── 00_pm-管理/
│   └── tasks-タスク.md
└── tasks-タスク/
src/
tests/
```

#### 複数選択時のマージ例

`dev+ops` の場合、dev のフォルダ構成に ops の `tasks-タスク/` を追加する。

### 3. テンプレートファイルの生成

各フォルダ内に初期テンプレートを配置する：

- **issues-課題.md**: 課題管理テンプレート（ステータス定義 + 空の課題一覧テーブル）
- **schedule-スケジュール.md**: スケジュールテンプレート（マイルストーン + 空のタスク一覧テーブル）
- **brainstorms/index.md**: ブレストインデックステンプレート（ヘッダー + 空のテーブル）
- **deliverables-成果物一覧.md**: 成果物一覧テンプレート（フェーズ毎に配置）

deliverables-成果物一覧.md はフェーズ毎に .aide/templates/ から対応するテンプレートをコピーして配置する：
- docs/01_requirements/ ← .aide/templates/deliverables-requirements.md
- docs/02_design/ ← .aide/templates/deliverables-design.md
- docs/03_plans/ ← .aide/templates/deliverables-plans.md
- docs/04_testing/ ← .aide/templates/deliverables-testing.md

brainstorms/index.md の初期内容：

```markdown
# ブレスト検討履歴インデックス

| 日付 | ドメイン | テーマ | 結論サマリ | ファイル |
|---|---|---|---|---|
```

成果物ファイル（要件書.md、設計書.md、製造計画書.md 等）は `/aide-pm-brainstorm` 実行時に artifacts-成果物/ 配下に作成されるため、init時には生成しない。artifacts-成果物/ フォルダ自体は空で生成する。

### 4. CLAUDE.md の生成（プロジェクトルールのマスター）

プロジェクトルートに CLAUDE.md を生成する。**すべてのプロジェクトルール・規約はこのファイルに集約する（Single Source of Truth）**。

検討内容/.aide/templates/ 配下の該当テンプレートを元に、ユーザーから得た情報を埋め込む。`[角括弧]` の部分はユーザー入力で置き換え、未確定の部分はプレースホルダのまま残す。

CLAUDE.md は利用AIツールに関わらず**常に生成する**。

### 5. 参照ファイルの生成（利用AIツールに応じて選択）

利用AIツールに応じて、必要な参照ファイルのみ生成する。参照ファイルにはプロジェクトルールを書かず、CLAUDE.md への参照指示のみ記載する。

#### 生成する参照ファイルの判定

| 利用AIツール | CLAUDE.md | AGENTS.md | .github/copilot-instructions.md |
|---|---|---|---|
| `claude+copilot`（デフォルト） | 生成（マスター） | 生成しない | 生成（参照のみ） |
| `claude` | 生成（マスター） | 生成しない | 生成しない |
| `copilot` | 生成（マスター） | 生成しない | 生成（参照のみ） |
| `codex` | 生成（マスター） | 生成（参照のみ） | 生成しない |

#### AGENTS.md（参照ファイル）の内容

```markdown
# AGENTS.md

このプロジェクトはaideフレームワークを使用しています。

**セッション開始時に `.aide/rules.md` を必ず読み、その内容に従ってください。**

- `.aide/rules.md`: aide共通ルール（原則・コーディング規約・コマンド一覧）
- `CLAUDE.md`: プロジェクト固有の設定（概要・フェーズ・技術スタック・制約）
- `.claude/skills/`: aideスキル定義（Agent Skills形式）

> **注意: このファイルの上記の内容は編集しないでください。**
> `.aide/rules.md` の読み込み指示はaideフレームワークの動作に必要です。

---

<!-- ここから下にプロジェクト固有のルールを記載してください。 -->
```

#### .github/copilot-instructions.md（参照ファイル）の内容

```markdown
# Copilot Instructions

このプロジェクトはaideフレームワークを使用しています。

**セッション開始時に `.aide/rules.md` を必ず読み、その内容に従ってください。**

- `.aide/rules.md`: aide共通ルール（原則・コーディング規約・コマンド一覧）
- `CLAUDE.md`: プロジェクト固有の設定（概要・フェーズ・技術スタック・制約）
- `.claude/skills/`: aideスキル定義（Agent Skills形式）

> **注意: このファイルの上記の内容は編集しないでください。**
> `.aide/rules.md` の読み込み指示はaideフレームワークの動作に必要です。

---

<!-- ここから下にプロジェクト固有のルールを記載してください。 -->
```

### 6. 完了報告と次のステップ案内

生成したファイル一覧を表示した後、以下の流れでユーザーを案内する：

#### 6-1. 既存資料の格納ガイド

ユーザーに「すでにある資料（打合せ議事録、要件メモ、仕様書、提案書など）はありますか？」と確認し、ある場合は格納先を案内する：

| 資料の種類 | 格納先 |
|---|---|
| 打合せ議事録・会議メモ | 各フェーズの `meeting-notes-打合せ/` |
| 要件・要望メモ | `docs-ドキュメント/01_requirements-要件/` |
| 設計書・アーキテクチャ図 | `docs-ドキュメント/02_design-設計/` |
| スケジュール・WBS | `docs-ドキュメント/00_pm-管理/` |
| 提案書・プレゼン資料 | `docs-ドキュメント/00_pm-管理/slides-資料/` |
| 問い合わせ記録 | `docs-ドキュメント/inquiry-問い合わせ/` |
| 既存ソースコード | `src/` |

格納後、AIが読み取って整理できることを伝える。

#### 6-2. 次のアクションの案内

資料の有無にかかわらず、利用可能なコマンドを案内する：

> プロジェクトの準備が整いました。以下のコマンドが利用できます：
>
> - `/aide-pm-analyze` — 対話で要件や設計の理解を深める（ファイル更新なし）
> - `/aide-pm-brainstorm` — ブレストしながら成果物（要件書・設計書等）を作成・更新する
>
> 既存資料がある場合は、先に格納してからコマンドを実行すると、資料の内容も踏まえて整理できます。
> どのフェーズから始めるかは自由です。通常は要件定義から進めます。

## 注意事項

- 既存ファイルがある場合は上書きせず、ユーザーに確認する
- 未確定の情報はプレースホルダ `[...]` のまま残す
- フォルダ名には必ず日本語の補足を括弧で付ける（例: `00_pm-管理/`）
