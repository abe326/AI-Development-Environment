# aide — AI Development Environment

> **仕様を共通言語として、AIと人間がフェーズを踏んで合意形成しながら進める開発フレームワーク**

仕様駆動開発（SDD）ベースのAI伴走ツール。
打合せからリリースまで、全工程をAIと伴走する。プロジェクト規模に応じた3モード対応。

| | |
|---|---|
| **開発手法** | 仕様駆動開発（SDD） + Spec-Anchored（仕様双方向同期） |
| **対応AIツール** | Claude Code / GitHub Copilot / Codex |
| **プロジェクト規模** | Quick（プロトタイプ） / Standard（通常） / Enterprise（監査付き） |
| **対象業務** | PM業務 / 新規開発 / 運用保守 |
| **対象ユーザー** | エンジニア・PM（非エンジニアでも利用可能な設計） |

---

## aideとは

AIに任せきりにしない。人間が判断し、仕様を正として段階的に進める。

aideは **24個のスラッシュコマンド + 自動実行機能** で構成されたワークフローフレームワーク。
`/aide-init` でプロジェクトを初期化し、フェーズに沿ってコマンドを実行するだけで、仕様書・設計書・テスト仕様書・コード・報告資料まで一貫して管理できる。

```
/aide-init         → プロジェクト初期化（規模選択: quick / standard / enterprise）
/aide-pm-*         → PM・管理（議事録・ブレスト・見積・資料作成・プロトタイプ...）
/aide-dev-*        → 開発（コード作成・テスト・品質レポート...）
/aide-review-*     → レビュー（コード・ドキュメント・監査...）
/aide-ops-*        → 運用保守（受付・調査・修正・クローズ...）
```

---

## 基本原則

| 原則 | 説明 |
|---|---|
| **Human-in-the-Loop** | AIは提案・生成を担い、人間が判断・承認する |
| **仕様駆動開発（SDD）** | 仕様が唯一の正。コードは仕様の実装、テストは仕様の検証 |
| **Spec-Anchored** | 実装→仕様の逆方向も同期。コード変更時に仕様更新を提案 |
| **フェーズ駆動** | フェーズ順に成果物を確定してから次へ。フェーズ内はイテレーティブ |
| **成果物ベース** | 口頭の合意だけで進めない。各ステップで具体的な成果物を出力 |
| **思考履歴の保全** | ブレストや検討の過程は日付付きファイルで残す |

---

## プロジェクト規模

`/aide-init` 時に規模を選択する。規模に応じてフォルダ構成・ワークフロー・品質ゲートが変わる。

| 規模 | 用途 | 特徴 |
|---|---|---|
| **quick** | プロトタイプ・PoC・内部ツール | フェーズ統合、プロトタイプ→仕様逆生成フロー |
| **standard** | 通常の開発プロジェクト（デフォルト） | フェーズ駆動の標準フロー |
| **enterprise** | コンプライアンス要件あり | 監査証跡・品質ゲート・トレーサビリティ追加 |

---

## クイックスタート

```bash
# 1. プロジェクト初期化（最初に1回）
/aide-init dev                    # 新規開発（standard）
/aide-init dev quick              # プロトタイプ向け
/aide-init dev enterprise         # 監査対応付き
/aide-init ops                    # 運用保守

# 2. フェーズに沿って進める
/aide-pm-brainstorm               # standard/enterprise: 要件定義から
/aide-pm-prototype                # quick: プロトタイプから
/aide-ops-new                     # 運用保守: 問い合わせ受付から
```

詳しい使い方は [.aide/README.md](.aide/README.md) を参照。

---

## ワークフロー概要

### Quick（プロトタイプ）

```
プロトタイプ → 仕様逆生成 → コード整理 → テスト
```

| ステップ | 使うコマンド |
|---|---|
| プロトタイプ | `pm-prototype` → 動作確認 → イテレーション |
| 仕様確定 | `pm-reverse-spec` → `pm-brainstorm`（深掘り） |
| コード整理 | `dev-code` → `review-code` |
| テスト | `dev-testspec` → `dev-test` |

### Standard（新規開発）

```
要件定義 → 設計 → 計画 → 実装 → テスト → リリース
```

| フェーズ | 使うコマンド |
|---|---|
| 要件定義 | `meeting` → `brainstorm` → `diagram` → `analyze` |
| 設計 | `brainstorm` → `diagram` → `analyze` |
| 計画 | `plan` → `estimate` |
| 実装 | `dev-code`（Spec-Anchored: 仕様同期チェック付き） |
| テスト | `dev-testspec` → `dev-test` → `review-code` |
| リリース | `review-doc` → `export` → `slide` |

### Enterprise（監査付き）

Standardと同じフロー + 各フェーズ完了時に `review-audit` で品質ゲートを確認。

### 運用保守

タスクID（`T-XXX`）で並行管理。

```
受付(new) → 調査(investigate) → 修正(fix) → 完了(close)
```

---

## コマンド一覧（24個）

### 共通（2個）

| コマンド | 目的 |
|---|---|
| `/aide-init` | プロジェクト初期化（規模選択: quick / standard / enterprise） |
| `/aide-router` | 状況に応じたコマンドを提案 |

### PM・管理系（11個）

| コマンド | 目的 |
|---|---|
| `/aide-pm-meeting` | 議事録作成 + 課題起票 |
| `/aide-pm-brainstorm` | ブレスト → 成果物を作成・更新 |
| `/aide-pm-analyze` | 対話で分析（ファイル更新なし） |
| `/aide-pm-diagram` | draw.io互換SVG図を生成 |
| `/aide-pm-plan` | 製造計画書作成 |
| `/aide-pm-estimate` | 見積もり作成（通常/概算） |
| `/aide-pm-slide` | 資料作成（スライド/見積書/スケジュール/ディスカッション） |
| `/aide-pm-export` | 成果物をHTML/PDF/docxに変換 |
| `/aide-pm-prototype` | ラフ要件からプロトタイプ生成（Quick向け） |
| `/aide-pm-reverse-spec` | プロトタイプから仕様書を逆生成 |
| `/aide-pm-retro` | 振り返り（KPT） |

### レビュー系（3個）

| コマンド | 目的 |
|---|---|
| `/aide-review-code` | コードレビュー（仕様準拠・品質・セキュリティ・カバレッジ・静的解析）。`--scope` で絞り込み可 |
| `/aide-review-doc` | ドキュメントレビュー（成果物の整合性・網羅性・トレーサビリティ監査） |
| `/aide-review-audit` | 監査レビュー（品質ゲート・コンプライアンス・監査証跡）。Enterprise専用 |

### 開発系（4個）

| コマンド | 目的 |
|---|---|
| `/aide-dev-code` | 仕様に基づくコード作成/修正（Spec-Anchored: 仕様同期チェック付き） |
| `/aide-dev-testspec` | 単体/結合テスト仕様書作成 |
| `/aide-dev-test` | テスト実行 + 証跡収集 + レポート |
| `/aide-dev-migrate` | 依存更新 + CVE脆弱性チェック |

### 運用保守系（4個）

| コマンド | 目的 |
|---|---|
| `/aide-ops-new` | 問い合わせ受付 + タスク起票 |
| `/aide-ops-investigate` | タスクの調査・原因分析 |
| `/aide-ops-fix` | タスクの修正対応 |
| `/aide-ops-close` | 対応記録 + クローズ |

### 自動実行（セッション開始時）

| 機能 | 対象 | 内容 |
|---|---|---|
| タスク状況表示 | ops プロジェクト | タスク一覧 + 滞留警告 + サマリ + アクション提案 |
| 課題状況表示 | dev プロジェクト | 課題サマリ + 停滞警告 + アクション提案 |

---

## プロジェクト構成

```
.aide/                          ← aide共通フレームワーク（Single Source of Truth）
├── rules.md                    ← 共通ルール（マスター）
├── skills/                     ← スキル正本（24個）
├── templates/                  ← 成果物・エクスポート用テンプレート
├── scripts/sync-skills.sh      ← ラッパー一括生成
└── README.md                   ← 利用ガイド
.claude/skills/                 ← Claude Code用ラッパー（自動生成）
.agents/skills/                 ← Codex CLI用ラッパー（自動生成）
.github/skills/                 ← GitHub Copilot用ラッパー（自動生成）
CLAUDE.md                       ← プロジェクト固有設定（/aide-initで生成）
```

`/aide-init` を実行すると、規模に応じたフォルダ構成が生成される:

### Quick

```
docs-ドキュメント/
├── 00_pm-管理/                ← 課題管理
├── specs-仕様/                ← 要件・設計を統合
└── testing-テスト/            ← テスト仕様・証跡
```

### Standard

```
docs-ドキュメント/
├── 00_pm-管理/                ← 課題・スケジュール・見積
├── 01_requirements-要件/      ← 要件書・議事録・ブレスト
├── 02_design-設計/            ← 設計書
├── 03_plans-製造計画/         ← 製造計画書
└── 04_testing-テスト/         ← テスト仕様書・証跡
```

### Enterprise（Standard + 監査）

```
docs-ドキュメント/
├── ... (Standardと同じ)
└── 05_audit-監査/             ← 監査証跡・コンプライアンス台帳・品質メトリクス
```

---

## 動作環境

### 対応AIツール

| ツール | 対応状況 |
|---|---|
| **Claude Code** | フル対応 — `/aide-*` コマンドで全スキルを実行 |
| **GitHub Copilot** | フル対応 — Agent Modeでスキルを参照 |
| **OpenAI Codex CLI** | 対応 — AGENTS.md経由でルールを読み込み |

### 動作要件

- **必須**: Git のみ
- **推奨OS**: WSL2 / macOS / Linux（Git Bash対応、PowerShell非推奨）
- **エクスポート時**: marked, marp-cli, pandoc 等（未導入時はスキル実行時に案内）

---

## ライセンス

MIT
