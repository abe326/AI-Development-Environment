# AI駆動開発ベストプラクティス — aide（AI Development Environment）利用ガイド

> AIと伴走する開発ワークフロー。Claude Code / GitHub Copilot / Codex 共通。

## クイックスタート

```bash
# 1. プロジェクト初期化（最初に1回）
/aide-init dev       # 新規開発
/aide-init ops       # 運用保守
/aide-init dev+ops   # 両方

# 2. 要件を整理する / 問い合わせを受け付ける
/aide-pm-brainstorm  # dev: 要件定義から開始
/aide-ops-new        # ops: 問い合わせ受付から開始

# 3. あとはフェーズに沿って進める（下記参照）
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
| **実装** | 仕様に基づくコード作成、レビュー | `dev-code` → `dev-review` |
| **テスト** | テスト仕様書→実行→証跡→品質レポート | `dev-testspec` → `dev-test` → `dev-quality` |
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
/aide-dev-review          # コードレビュー（仕様準拠チェック）

/aide-dev-testspec        # 単体/結合テスト仕様書を作成
/aide-dev-code            # テストコードを実装
/aide-dev-test            # テスト実行 → 証跡収集 → レポート生成
/aide-dev-quality         # カバレッジ・静的解析・セキュリティレポート

/aide-pm-export           # テスト成果物をHTML/PDFに変換
```

---

### B. 運用保守（`/aide-init ops`）

問い合わせ・課題をタスクID（`T-XXX`）で並行管理する。

```bash
/aide-ops-new             # 問い合わせ受付 → タスク起票
/aide-ops-list            # OPENタスクの一覧確認（毎朝）
/aide-ops-investigate T-001  # 指定タスクの調査・原因分析
/aide-ops-fix T-001       # 修正対応
/aide-ops-close T-001     # 対応記録 + クローズ
/aide-ops-status          # 全タスクの状況サマリ（週次）
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
| `/aide-pm-issues` | 課題ステータスの棚卸し | 進捗確認・定例会前 |
| `/aide-pm-docaudit` | 成果物の整合性・網羅性チェック | フェーズ完了時・提出前 |
| `/aide-pm-retro` | 振り返り（KPT） | フェーズ完了時・問題発生後 |
| `/aide-dev-migrate` | 依存更新 + CVE脆弱性チェック | スプリント開始時・リリース前 |
| `/aide-dev-review` | コードレビュー | PR作成前 |

---

## コマンド一覧（早見表）

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
| `issues` | 課題ステータス確認 |
| `docaudit` | ドキュメント監査 |
| `retro` | 振り返り（KPT） |

### 開発系（aide-dev-*）

| コマンド | 一言説明 |
|---|---|
| `code` | 仕様に基づくコード作成 |
| `testspec` | 単体/結合テスト仕様書作成 |
| `test` | テスト実行 + 証跡収集 + レポート |
| `quality` | カバレッジ・静的解析・セキュリティ |
| `review` | コードレビュー |
| `migrate` | 依存更新 + CVEチェック |

### 運用保守系（aide-ops-*）

| コマンド | 一言説明 |
|---|---|
| `new` | 問い合わせ受付 + タスク起票 |
| `list` | OPENタスクの一覧 |
| `investigate` | タスクの調査 |
| `fix` | タスクの修正 |
| `close` | 対応記録 + クローズ |
| `status` | 全タスクサマリ |

---

## 基本ルール

1. **Human-in-the-Loop** — AIが提案、人間が判断。承認なしで実装に進まない
2. **仕様駆動** — 仕様が正。コードは仕様の実装、テストは仕様の検証
3. **フェーズ駆動** — 飛ばさず順番に。各フェーズで成果物をレビューしてから次へ
4. **成果物ベース** — 口頭合意だけで進めない。必ずファイルに残す

詳細は `.aide/rules.md` を参照。

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

| ツール | 対応状況 | 備考 |
|---|---|---|
| **Claude Code** | フル対応 | `/aide-*` コマンドで全スキルを実行 |
| **GitHub Copilot（VS Code）** | フル対応 | Agent Modeでスキルを参照 |
| **OpenAI Codex CLI** | 対応 | AGENTS.mdから `.aide/rules.md` を読み込み |

### 必須ツール

aide自体の動作に必要なツールは **Git のみ**。

| ツール | 用途 | インストール |
|---|---|---|
| **Git** | バージョン管理・ブランチ運用 | `apt install git` / `brew install git` |

> PM系（brainstorm, analyze, meeting, issues等）、開発系（code, review, testspec）は
> **外部ツール一切不要** でそのまま動作する。

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

### プロジェクト依存のツール（aide側の要件ではない）

以下は対象プロジェクトの技術スタックに応じて必要になるもの。aideフレームワークの要件ではなく、プロジェクト側の依存。

| カテゴリ | 例 | 備考 |
|---|---|---|
| テストフレームワーク | Jest, pytest, Go test 等 | `aide-dev-test` が検出して利用する |
| 静的解析 | ESLint, Pylint 等 | `aide-dev-quality` が検出して利用。未導入時はAI解析で代替 |
| 脆弱性スキャン | npm audit, pip-audit, trivy 等 | `aide-dev-migrate` が検出して利用。未導入時はAI解析で代替 |
| ランタイム | Node.js, Python, Go 等 | プロジェクトの技術スタックに依存 |
