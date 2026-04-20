# AI駆動開発ベストプラクティス — aide（AI Development Environment）利用ガイド

> AIと伴走する開発ワークフロー。Claude Code / GitHub Copilot / Codex 共通。

## クイックスタート

```bash
# 1. プロジェクト初期化（最初に1回）
/aide-init dev       # 新規開発
/aide-init ops       # 運用保守
/aide-init dev+ops   # 両方

# 2. 何をすればいいか迷ったら
/aide-router         # 状況に応じたコマンドを提案してくれる

# 3. 要件を整理する / 問い合わせを受け付ける
/aide-pm-brainstorm  # dev: 要件定義から開始
/aide-ops-new        # ops: 問い合わせ受付から開始

# 4. あとはフェーズに沿って進める（下記参照）
```

---

## 利用ケース別ガイド

### A. 新規開発（`/aide-init dev`）

```
要件定義 → 設計 → 計画 → 実装 → テスト → リリース
```

| フェーズ | やること | 使うコマンド |
|---|---|---|
| **要件定義** | 打合せ→議事録、要件をブレスト、図で整理 | `meeting` → `brainstorm` → `diagram` |
| **設計** | アーキテクチャ検討、設計書作成 | `brainstorm` → `diagram` → `analyze` |
| **計画** | 製造計画書・スケジュール・見積もり | `plan` → `estimate` |
| **実装** | 仕様に基づくコード作成、レビュー | `dev-code` → `review-code` |
| **テスト** | テスト仕様書→実行→証跡→品質レポート | `dev-testspec` → `dev-test` → `review-code --scope coverage` |
| **リリース** | 成果物エクスポート、報告資料 | `export` → `slide` |

#### 要件定義フェーズの典型フロー

```bash
/aide-pm-meeting          # 打合せメモを議事録化 + 課題自動起票
/aide-pm-brainstorm       # 要件をブレスト → 要件書を生成・更新
/aide-pm-diagram          # ユースケース図などを生成
/aide-pm-analyze          # 不足や矛盾を対話で確認（ファイル更新なし）
/aide-pm-slide            # ステークホルダー向け説明資料を作成
/aide-pm-export           # 要件書をHTML/docxに変換して提出
```

#### 設計フェーズの典型フロー

```bash
/aide-pm-brainstorm       # アーキテクチャ案をブレスト → 設計書を生成
/aide-pm-diagram          # 構成図・シーケンス図を生成
/aide-pm-estimate         # 詳細見積もり作成
```

#### 実装〜テストフェーズの典型フロー

```bash
/aide-dev-code            # 製造計画書に基づきコード作成（確認→実装）
                          # → 完了後 /aide-review-code を案内
/aide-review-code         # コードレビュー（仕様準拠・品質・セキュリティ）

/aide-dev-testspec        # 単体/結合テスト仕様書を作成
/aide-dev-code            # テストコードを実装
/aide-dev-test            # テスト実行 → 証跡収集 → レポート生成
                          # → 完了後 /aide-review-code --scope coverage を案内

/aide-review-doc          # フェーズ完了時のドキュメント監査
/aide-pm-export           # テスト成果物をHTML/PDFに変換
```

---

### B. 運用保守（`/aide-init ops`）

問い合わせ・課題をタスクID（`T-XXX`）で並行管理する。

```bash
# セッション開始時にタスク一覧・滞留警告・サマリが自動表示される

/aide-ops-new             # 問い合わせ受付 → タスク起票
/aide-ops-investigate T-001  # 指定タスクの調査・原因分析
/aide-ops-fix T-001       # 修正対応
/aide-ops-close T-001     # 対応記録 + クローズ
```

#### タスク対応のライフサイクル

`/aide-ops-new` で作成されるファイルがタスクの **Single Source of Truth** となり、以降のコマンドはすべて同じファイルに追記していく。

```
docs-ドキュメント/tasks-タスク/
└── T-001-件名/
    ├── 20260328-件名.md   ← 対応記録（このファイルが正）
    └── slides-資料/        ← 報告資料用
```

| コマンド | ファイル操作 | ステータス |
|---|---|---|
| `/aide-ops-new` | フォルダ・ファイル作成 + 受付記録 | → 受付 |
| `/aide-ops-investigate` | 対応履歴に調査結果を追記 | → 調査中 |
| `/aide-ops-fix` | 対応履歴に修正内容を追記 | → 修正中 |
| `/aide-ops-close` | 対応履歴にクローズ記録を追記 | → 完了 |

各コマンドは tasks-タスク.md のステータスも同時に更新する。

**ファイル構成:**
```markdown
# T-XXX: タイトル

## 基本情報          ← ステータスはコマンド実行ごとに更新
## 問い合わせ内容    ← new で記録、以降変更しない
## 対応履歴          ← investigate / fix / close が追記していく
```

---

## 便利コマンド（任意実行）

フローに組み込まなくても、必要なときに単独で使えるコマンド。

| コマンド | 用途 | いつ使う？ |
|---|---|---|
| `/aide-pm-analyze` | 対話で理解を深める（ファイル更新なし） | 要件・設計の不明点を確認したい時 |
| `/aide-pm-diagram` | draw.io互換のSVG図を生成 | 図で説明・確認したい時 |
| `/aide-review-doc` | ドキュメントの整合性・網羅性チェック | フェーズ完了時・提出前 |
| `/aide-review-code` | コードレビュー（`--scope` で観点絞り込み可） | PR作成前・実装後 |
| `/aide-pm-retro` | 振り返り（KPT） | フェーズ完了時・問題発生後 |
| `/aide-dev-migrate` | 依存更新 + CVE脆弱性チェック | スプリント開始時・リリース前 |

---

## コマンド一覧（早見表）

### 共通

| コマンド | 一言説明 |
|---|---|
| `init` | プロジェクト初期化（dev / ops / dev+ops） |
| `router` | 状況に応じた最適コマンドを提案 |

### PM・管理系（aide-pm-*）

| コマンド | 一言説明 |
|---|---|
| `meeting` | 議事録 + 課題起票 |
| `brainstorm` | ブレスト → 成果物を作成・更新 |
| `analyze` | 対話で分析（更新なし） |
| `diagram` | SVG図を生成 |
| `plan` | 製造計画書 + スケジュール |
| `estimate` | 見積もり作成 |
| `slide` | 資料作成（4種類自動判定） |
| `export` | 成果物をHTML/PDF/docxに変換 |
| `retro` | 振り返り（KPT） |
| `prototype` | ラフ要件からプロトタイプコード生成（Quick向け） |
| `reverse-spec` | プロトタイプコードから仕様書を逆生成 |

### レビュー系（aide-review-*）

| コマンド | 一言説明 |
|---|---|
| `review-code` | コードレビュー（仕様準拠・品質・セキュリティ・カバレッジ・静的解析） |
| `review-doc` | ドキュメント監査（整合性・網羅性・トレーサビリティ） |
| `review-audit` | 監査証跡・品質ゲート・コンプライアンス横断監査（Enterprise専用） |

### 開発系（aide-dev-*）

| コマンド | 一言説明 |
|---|---|
| `code` | 仕様に基づくコード作成 |
| `testspec` | 単体/結合テスト仕様書作成 |
| `test` | テスト実行 + 証跡収集 + レポート |
| `migrate` | 依存更新 + CVEチェック |

### 運用保守系（aide-ops-*）

| コマンド | 一言説明 |
|---|---|
| `new` | 問い合わせ受付 + タスク起票 |
| `investigate` | タスクの調査 |
| `fix` | タスクの修正 |
| `close` | 対応記録 + クローズ |

### 自動実行（セッション開始時）

| 機能 | 対象 | 内容 |
|---|---|---|
| タスク状況表示 | ops プロジェクト | タスク一覧 + 滞留警告 + サマリ + アクション提案 |
| 課題状況表示 | dev プロジェクト | 課題サマリ + 停滞警告 + アクション提案 |

---

## 基本ルール

1. **Human-in-the-Loop** — AIが提案、人間が判断。承認なしで実装に進まない
2. **仕様駆動** — 仕様が正。コードは仕様の実装、テストは仕様の検証
3. **フェーズ駆動** — 飛ばさず順番に。各フェーズで成果物をレビューしてから次へ
4. **成果物ベース** — 口頭合意だけで進めない。必ずファイルに残す

詳細は `.aide/rules.md` を参照。

---

## 設計思想

### 資料構成のフレームワーク

aideのスライド生成（`/aide-pm-slide`）は、学術的に効果が実証された3つのフレームワークを組み合わせた **3層構成** を採用している。

```
第1層: SCQ（全体ストーリー） → スライド全体の流れを制御
第2層: ピラミッド原則（セクション内部） → 各セクションの論理階層を整理
第3層: 1スライド1メッセージ（スライド単位） → 認知負荷を制御
```

#### なぜSCQか

システム開発の説明資料は「なぜやるのか → 何が問題か → どうするか」の流れになる。SCQ（Situation → Complication → Question → Answer）はこの流れそのものであり、聞き手が自然に理解できる構成を保証する。

| フレームワーク | 出自 | aideでの役割 |
|---|---|---|
| **SCQ**（SituComBA） | Barbara Minto, McKinsey（1985） | スライド全体のストーリーライン |
| **ピラミッド原則** | Barbara Minto, "The Pyramid Principle" | 各セクション内の結論→根拠→詳細 |
| **MECE** | McKinsey（1960s） | 情報分解の網羅性・排他性 |
| **認知負荷理論** | John Sweller（1988） | 1スライドの情報量制御 |
| **チャンキング** | George Miller（1956） | 情報の塊分け（7±2チャンク） |

#### 他の手法を採用しなかった理由

| 手法 | 判断 | 理由 |
|---|---|---|
| PREP法 | 部分採用 | 1スライド内の説明には有効だが、全体構成には不足 |
| SDS法 | 不採用 | ニュース・報告向き。提案型スライドには不向き |
| DITA | 不採用 | 技術文書（仕様書等）向き。スライドの構成法ではない |
| 空・雨・傘 | 不採用 | SCQとほぼ同等だが、Question（論点）の明示がない |

### スライドの視覚設計

ストーリー構成に加え、スライドの **視覚品質** を保証するために以下のフレームワークを採用している。

#### CRAP原則（Robin Williams, 1994）

| 原則 | aideでの適用 |
|---|---|
| **Contrast** | フォントサイズ階層で情報の優先度を視覚化。h3は太字、注釈は小さく薄色に |
| **Repetition** | 同じ種類の情報は同じパターンで統一（比較→2カラム、プロセス→フロー） |
| **Alignment** | Marpのgridレイアウト（columns, compare等）で構造的に整列 |
| **Proximity** | 関連情報をdiv/表/カードでグルーピング。無関係な情報はスライド分割 |

#### タイポグラフィック・スケール（モジュラースケール）

Robert Bringhurst の "The Elements of Typographic Style" に基づき、Major Third（1.250）比率でフォントサイズ階層を定義。
基準サイズ 20px から、見出し・本文・補足・注釈・キャプションの6段階を自動適用する。

```
h1: 39px → h2: 31px → h3: 25px → 本文: 20px → 補足: 17px → 注釈: 14px → キャプション: 12px
```

#### 情報密度ガード

George Miller の法則（7±2チャンク）と認知負荷理論に基づき、1スライドあたりの情報量に上限を設定。
箇条書き5項目以内、表6行以内、1行30文字以内。超過時はスライド分割を強制する。

| 原則 | 出自 | 制御対象 |
|---|---|---|
| **Miller's Law** | George Miller（1956） | 箇条書き・表の項目数上限 |
| **認知負荷理論** | John Sweller（1988） | 1スライドの総情報量 |
| **5-5-5ルール** | プレゼン業界の経験則 | テキスト密度の簡易チェック |

### コンテンツ品質

フォーマットとビジュアルに加え、**内容の深さ**を制御���るルールを設けている。

| ルール | 目的 |
|---|---|
| **So What?テスト** | 聞き手が「だから何？」と思うスライドを排�� |
| **数字テスト** | 2枚に1枚は具体的数値を含める |
| **固有名詞テスト** | 一般論ではなく固有の事実・事例を含める |
| **行動テスト** | 聞き手が判断・行動できる情報を含める |

AI生成時に情報が不足する場合、薄い内容で埋めるのではなく「ここに入れるべきデータは？」とユーザーに確認する。

詳細な構成ルールは `.aide/skills/aide-pm-slide/SKILL.md` のステップ5「ストーリー構成の設計」、
ビジュアルデザインルールは同ステップ7「資料の生成」内の「ビジュアルデザインルール」、
コンテンツ品質ルールは同ステップ7「��料の生成」内の「コンテンツ品質ルール」、
パーツテンプレートは `.aide/templates/export/slide-template.md` を参照。

---

## フォルダ構成（マルチエージェント対応）

aideはスキル正本を `.aide/skills/` に一元管理し、各AIツール用のラッパーを自動生成する。

```
project-root/
│
│ ─── フレームワーク本体（Single Source of Truth） ─────────
│
├── .aide/
│   ├── rules.md                       # 共通ルール
│   ├── skills/                        # ★ スキル正本（24個）
│   │   ├── aide-pm-brainstorm/
│   │   │   └── SKILL.md              #   ツール非依存のスキル定義
│   │   └── ...
│   ├── templates/                     # 成果物テンプレート
│   ├── scripts/
│   │   └── sync-skills.sh            # ラッパー一括生成スクリプト
│   └── README.md                      # このファイル
│
│ ─── エントリポイント ────────────────────────────────────
│
├── CLAUDE.md                          # Claude Code用 → @.aide/rules.md
├── AGENTS.md                          # Copilot / Codex用 → .aide/rules.md 参照
│
│ ─── AIツール別ラッパー（sync-skills.sh で自動生成） ─────
│
├── .claude/skills/                    # Claude Code用（@インポートで正本を参照）
│   └── aide-pm-brainstorm/
│       └── SKILL.md                   #   5行のラッパー
│
├── .github/                           # GitHub Copilot用
│   ├── copilot-instructions.md
│   ├── skills/                        #   エージェントスキル（Markdownリンクで参照）
│   │   └── aide-pm-brainstorm/
│   │       └── SKILL.md
│   └── prompts/                       #   スラッシュコマンド（/aide-pm-brainstorm）
│       └── aide-pm-brainstorm.prompt.md
│
└── .agents/skills/                    # Codex CLI用（ファイルパスで正本を参照）
    └── aide-pm-brainstorm/
        └── SKILL.md
```

### スキルの保守

スキル正本は `.aide/skills/` のみ編集する。ラッパーは直接編集しない。

**スキルの追加・変更時:**

```bash
# 1. 正本を追加・編集
#    .aide/skills/<skill-name>/SKILL.md

# 2. ラッパーを一括再生成
bash .aide/scripts/sync-skills.sh

# 3. 特定ツールのみ再生成も可能
bash .aide/scripts/sync-skills.sh claude    # Claude Code用のみ
bash .aide/scripts/sync-skills.sh copilot   # GitHub Copilot用のみ
bash .aide/scripts/sync-skills.sh codex     # Codex CLI用のみ
```

**スクリプトの動作:**

| 処理 | 出力先 |
|---|---|
| Claude Code用ラッパー生成 | `.claude/skills/<name>/SKILL.md` |
| Copilot エージェントスキル生成 | `.github/skills/<name>/SKILL.md` |
| Copilot スラッシュコマンド生成 | `.github/prompts/<name>.prompt.md` |
| Codex CLI用ラッパー生成 | `.agents/skills/<name>/SKILL.md` |
| 孤立ラッパー検出 | 正本が削除されたラッパーを警告表示 |

### ラッパーの仕組み

各ツールのラッパーはスキル正本を参照するだけの3-5行のファイル。

| ツール | 参照方法 | 例 |
|---|---|---|
| Claude Code | `@`インポート | `@../../.aide/skills/aide-pm-brainstorm/SKILL.md` |
| Copilot | Markdownリンク | `[スキル定義](../../.aide/skills/.../SKILL.md)` |
| Codex CLI | ファイルパス指示 | `正本: ../../.aide/skills/.../SKILL.md` |

### 各ツールでの使い方

| ツール | スキルの起動方法 |
|---|---|
| **Claude Code** | `/aide-pm-brainstorm` （スラッシュコマンド）or 自動起動 |
| **GitHub Copilot** | `/aide-pm-brainstorm` （プロンプトファイル）or エージェントが自動選択 |
| **Codex CLI** | `$aide-pm-brainstorm` or 自動選択 |

---

## 動作環境・制約

### 対応OS / ターミナル

| 環境 | 対応状況 | 備考 |
|---|---|---|
| **WSL2（Ubuntu等）** | 推奨 | 検証済み |
| **macOS** | 推奨 | ネイティブUnix環境 |
| **Linux** | 推奨 | ネイティブUnix環境 |
| **Git Bash（Windows）** | 対応 | 検証済み |
| **MSYS2（Windows）** | 未検証 | Git Bash同等の見込み |
| **PowerShell** | 非推奨 | コマンド構文が異なるため一部スキルが動作しない |
| **cmd.exe** | 非対応 | Unix系コマンドが使えない |

> **注意:** フォルダ名に日本語を含むため、ターミナルのロケール設定がUTF-8であることを確認してください。
> Git Bashの場合: `export LANG=ja_JP.UTF-8` を `.bashrc` に追加。

### 対応AIツール

| ツール | 対応状況 | スキル起動 | 備考 |
|---|---|---|---|
| **Claude Code** | フル対応 | `/aide-*` | `.claude/skills/` ラッパー経由 |
| **GitHub Copilot（VS Code）** | フル対応 | `/aide-*` or 自動 | `.github/prompts/` + `.github/skills/` ラッパー経由 |
| **OpenAI Codex CLI** | フル対応 | `$aide-*` or 自動 | `.agents/skills/` ラッパー経由 |

### 必須ツール

aide自体の動作に必要なツールは **Git のみ**。

| ツール | 用途 | インストール |
|---|---|---|
| **Git** | バージョン管理・ブランチ運用 | `apt install git` / `brew install git` |

> PM系（brainstorm, analyze, meeting, issues等）、開発系（code, review, testspec）は
> **外部ツール一切不要** でそのまま動作する。

### 推奨VS Code拡張

| 拡張機能 | 用途 | 必須/推奨 |
|---|---|---|
| **Marp for VS Code** | スライドmdのリアルタイムプレビュー＋手動修正 | 推奨（スライド作成時） |

Marp for VS Codeを使うと、AI生成したスライドmdをVS Codeで開いてリアルタイムプレビューしながら手動で修正できる。

**テーマ設定:** ワークスペースルートの `.vscode/settings.json` に以下を追加する：

```json
{
  "markdown.marp.themes": [
    "./[aideプロジェクトへの相対パス]/.aide/templates/export/marp-theme.css"
  ],
  "markdown.marp.enableHtml": true
}
```

パスはVS Codeで開いているフォルダ（ワークスペースルート）からの相対パス。`/aide-init` 実行時にこの設定が存在しなければ自動追加される。

### エクスポート時に必要なツール

成果物の変換・出力を行う場合のみ必要。未インストール時はスキル実行時にインストール手順が案内される。

| ツール | 用途 | 必須/任意 | インストール |
|---|---|---|---|
| **marked** | md → HTML変換 | 必須（ドキュメント出力時） | `npm install -g marked` |
| **marp-cli** | スライドmd → HTML/PPTX | 必須（スライド出力時） | `npm install -g @marp-team/marp-cli` |
| **ansi2html** | ターミナル出力 → HTML証跡 | 必須（テスト証跡・品質レポート時） | `pip install ansi2html` |
| **pandoc** | HTML → docx変換 | 任意（docx出力時） | `apt install pandoc` / `brew install pandoc` |
| **draw.io CLI** | .drawio.svg → PNG/PDF | 任意（図の単体変換時） | [draw.io Desktop](https://github.com/jgraph/drawio-desktop) |
| **Playwright** | HTML → PDF / スクリーンショット証跡 | 任意（ブラウザ印刷で代替可） | `npm install -g playwright` |

### インポート時に必要なツール（Officeファイル読み込み）

Office形式（.docx / .pptx / .xlsx）をMarkdownに変換して読み込む場合に必要。`/aide-init` 実行時に導入状況を確認し、未導入のものは自動インストールを案内する。

| ツール | 用途 | 必須/任意 | インストール |
|---|---|---|---|
| **pandoc** | Word(.docx) → MD変換（高精度） | 推奨 | `apt install pandoc` / `brew install pandoc` |
| **python-pptx** | PowerPoint(.pptx) → MD変換 | 必須（pptx読み込み時） | `pip install python-pptx` |
| **openpyxl** | Excel(.xlsx) → MD変換 | 必須（xlsx読み込み時） | `pip install openpyxl` |
| **python-docx** | Word(.docx) → MD変換（pandoc未導入時のfallback） | 任意 | `pip install python-docx` |

変換スクリプトは `.aide/templates/export/scripts/` に配置。詳細は `.aide/rules.md` の「Office ファイル読み込みルール」を参照。

### プロジェクト依存のツール（aide側の要件ではない）

以下は対象プロジェクトの技術スタックに応じて必要になるもの。aideフレームワークの要件ではなく、プロジェクト側の依存。

| カテゴリ | 例 | 備考 |
|---|---|---|
| テストフレームワーク | Jest, pytest, Go test 等 | `aide-dev-test` が検出して利用する |
| 静的解析 | ESLint, Pylint 等 | `aide-review-code` が検出して利用。未導入時はAI解析で代替 |
| 脆弱性スキャン | npm audit, pip-audit, trivy 等 | `aide-dev-migrate` が検出して利用。未導入時はAI解析で代替 |
| ランタイム | Node.js, Python, Go 等 | プロジェクトの技術スタックに依存 |
