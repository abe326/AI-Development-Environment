---
name: aide-init
description: プロジェクトを初期化する。dev（新規開発）/ ops（運用保守）/ dev+ops の3モードに対応。フォルダ構造・CLAUDE.md・GitHub Copilot/Codex向け設定ファイルを一括生成する。「プロジェクトを始める」「新規リポジトリにaideを入れたい」「初期設定をしたい」と言われたら必ずこのスキルを使う。要件定義や設計の前に実行するセットアップスキル。
short_description: プロジェクトを dev / ops / dev+ops で初期化する。フォルダ構成・CLAUDE.md・必要ツールを一括セットアップ
---

# aide-init: プロジェクト初期化

ユーザーに業務タイプを確認し、対応するプロジェクト構成を生成する。

## 手順

### 1. プロジェクト情報の確認

ユーザーに以下を確認する（引数で指定されている場合はスキップ）：

- **業務タイプ**（複数選択可）: `dev`（新規開発） / `ops`（運用保守）
  - 例: `dev+ops` のように組み合わせ可能
  - 単一選択でもよい
- **プロジェクト規模**: `quick`（小規模） / `standard`（通常） / `enterprise`（大規模）
  - quick: プロトタイプ・PoC・内部ツール向け。フェーズを統合し成果物を簡略化
  - standard: 通常の開発プロジェクト（デフォルト）
  - enterprise: コンプライアンス要件あり。監査証跡・品質ゲート・トレーサビリティを追加
  - 省略時は `standard` とする
- **利用AIツール**: `claude+copilot`（デフォルト） / `codex` / `claude` / `copilot`
  - 省略時は `claude+copilot` とする
- **プロジェクト名 / システム名**
- **技術スタック**（わかる範囲で）

### 2. フォルダ構成の生成

選択された業務タイプに応じて、該当するフォルダをすべて生成する。複数選択時はマージして生成する。

フォルダ構成はプロジェクト規模に応じて調整する。以下はdev を含む場合の規模別構成。

#### quick かつ dev を含む場合

```
docs-ドキュメント/
├── 00_pm-管理/
│   └── issues-課題.md
├── specs-仕様/
│   ├── artifacts-成果物/
│   ├── brainstorms-検討履歴/
│   │   └── index.md
│   └── deliverables-成果物一覧.md
├── testing-テスト/
│   ├── artifacts-成果物/
│   └── evidence-証跡/
src/
tests/
```

quickモードでは要件・設計・計画フェーズを `specs-仕様/` に統合する。meeting-notes、reviews、slides フォルダは省略する。

#### standard かつ dev を含む場合

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

#### enterprise かつ dev を含む場合

standard のフォルダ構成に加え、以下の監査フォルダを追加する：

```
docs-ドキュメント/
├── ... （standardと同じ 00_pm〜04_testing）
└── 05_audit-監査/
    ├── audit-trail-監査証跡/
    ├── compliance-台帳/
    │   └── compliance-register.md
    ├── quality-metrics-品質メトリクス/
    │   └── metrics-history.md
    ├── traceability-トレーサビリティ/
    │   └── traceability-matrix.md
    └── reports-レポート/
```

enterpriseの場合、compliance-register.md と traceability-matrix.md は `.aide/templates/` 配下のテンプレートから生成する。

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

#### standard / enterprise の場合（現行と同じ）
- docs/01_requirements/ ← .aide/templates/deliverables-requirements.md
- docs/02_design/ ← .aide/templates/deliverables-design.md
- docs/03_plans/ ← .aide/templates/deliverables-plans.md
- docs/04_testing/ ← .aide/templates/deliverables-testing.md

#### quick の場合
- docs/specs-仕様/ ← .aide/templates/deliverables-quick.md

#### enterprise の場合（上記に加えて）
- docs/05_audit-監査/ ← .aide/templates/deliverables-audit.md
- docs/05_audit-監査/compliance-台帳/compliance-register.md ← .aide/templates/compliance-register.md
- docs/05_audit-監査/traceability-トレーサビリティ/traceability-matrix.md ← .aide/templates/traceability-matrix.md
- docs/05_audit-監査/quality-metrics-品質メトリクス/metrics-history.md ← 空の初期テンプレート

brainstorms/index.md の初期内容：

```markdown
# ブレスト検討履歴インデックス

| 日付 | ドメイン | テーマ | 結論サマリ | ファイル |
|---|---|---|---|---|
```

成果物ファイル（要件書.md、設計書.md、製造計画書.md 等）は `/aide-pm-brainstorm` 実行時に artifacts-成果物/ 配下に作成されるため、init時には生成しない。artifacts-成果物/ フォルダ自体は空で生成する。

### 4. CLAUDE.md の生成（プロジェクトルールのマスター）

プロジェクトルートに CLAUDE.md を生成する。**すべてのプロジェクトルール・規約はこのファイルに集約する（Single Source of Truth）**。

CLAUDE.md のテンプレートは規模に応じて選択する：
- quick: `.aide/templates/quick-claude.md`
- standard: `.aide/templates/newdev-claude.md`（現行のまま）
- enterprise: `.aide/templates/enterprise-claude.md`

「プロジェクト規模」セクションにユーザーが選択した規模を記入する。

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

### 6. ツール導入状況の確認と自動インストール

プロジェクト初期化後、Office ファイル読み込みに必要なツールの導入状況を確認する。

#### 確認対象ツール

| ツール | 確認コマンド | 用途 | インストールコマンド |
|---|---|---|---|
| pandoc | `pandoc --version` | Word(.docx) → MD変換（高精度） | `apt install pandoc` / `brew install pandoc` |
| python-pptx | `python3 -c "import pptx"` | PowerPoint(.pptx) → MD変換 | `pip install python-pptx` |
| openpyxl | `python3 -c "import openpyxl"` | Excel(.xlsx) → MD変換 | `pip install openpyxl` |
| python-docx | `python3 -c "import docx"` | Word(.docx) → MD変換（pandoc未導入時のfallback） | `pip install python-docx` |

#### フロー

1. 各ツールの確認コマンドを実行し、導入状況を一覧表示する：
   ```
   📦 ツール導入状況
   | ツール       | 状態 | 用途                  |
   |---|---|---|
   | pandoc       | ✅    | Word → MD変換（高精度）|
   | python-pptx  | ❌    | PowerPoint → MD変換    |
   | openpyxl     | ✅    | Excel → MD変換         |
   | python-docx  | ✅    | Word → MD変換（fallback）|
   ```
2. 未導入のツールがある場合、インストールするか確認する
3. ユーザーが承認したら、該当ツールのインストールコマンドを実行する
4. 「後でインストールする」を選んだ場合はスキップし、スキル実行時に再度案内される旨を伝える

### 7. VS Code Marpプレビュー設定

スライドmdをVS Codeでリアルタイムプレビューしながら手動修正するための設定を行う。

#### 設定手順

1. ワークスペースルートの `.vscode/settings.json` を確認する
2. `markdown.marp.themes` と `markdown.marp.enableHtml` が未設定であれば追加する
3. 既に `.vscode/settings.json` が存在する場合は既存の設定を壊さないようにマージする

#### 追加する設定

```json
{
  "markdown.marp.themes": [
    "./[aideプロジェクトへの相対パス]/.aide/templates/export/marp-theme.css"
  ],
  "markdown.marp.enableHtml": true
}
```

パスは、VS Codeで開いているフォルダ（ワークスペースルート）からaideプロジェクトの `.aide/templates/export/marp-theme.css` への相対パスで指定する。

#### 案内

設定追加後、以下を案内する：

> VS Codeに **Marp for VS Code** 拡張をインストールすると、スライドmdをリアルタイムプレビューしながら手動修正できます。
> 設定を反映するには `Ctrl+Shift+P` → `Developer: Reload Window` を実行してください。

### 8. 完了報告と次のステップ案内

生成したファイル一覧を表示した後、以下の流れでユーザーを案内する：

#### 8-1. 既存資料の格納ガイド

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

#### 8-2. 次のアクションの案内

資料の有無にかかわらず、利用可能なコマンドを案内する。案内内容はプロジェクト規模に応じて分岐する：

#### quick の場合

> プロジェクトの準備が整いました（小規模モード）。以下のコマンドが利用できます：
>
> - `/aide-pm-prototype` — ラフ要件からプロトタイプコードを素早く生成
> - `/aide-pm-analyze` — 対話で要件を深掘り（ファイル更新なし）
> - `/aide-pm-brainstorm` — 通常のブレスト（必要に応じて）
>
> 小規模モードでは、まずプロトタイプを作り、動作確認後に仕様を逆生成するフローが利用できます。

#### standard の場合（現行のまま）

> プロジェクトの準備が整いました。以下のコマンドが利用できます：
>
> - `/aide-pm-analyze` — 対話で要件や設計の理解を深める（ファイル更新なし）
> - `/aide-pm-brainstorm` — ブレストしながら成果物（要件書・設計書等）を作成・更新する
>
> 既存資料がある場合は、先に格納してからコマンドを実行すると、資料の内容も踏まえて整理できます。
> どのフェーズから始めるかは自由です。通常は要件定義から進めます。

#### enterprise の場合

> プロジェクトの準備が整いました（Enterpriseモード）。以下のコマンドが利用できます：
>
> - `/aide-pm-analyze` — 対話で要件や設計の理解を深める（ファイル更新なし）
> - `/aide-pm-brainstorm` — ブレストしながら成果物（要件書・設計書等）を作成・更新する
>
> Enterpriseモードでは、各フェーズ完了時に `/aide-review-audit` で品質ゲートを確認できます。
> 監査証跡は各スキル実行時に自動記録されます。

## 注意事項

- 既存ファイルがある場合は上書きせず、ユーザーに確認する
- 未確定の情報はプレースホルダ `[...]` のまま残す
- フォルダ名には必ず日本語の補足を括弧で付ける（例: `00_pm-管理/`）
