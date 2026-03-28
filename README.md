# aide — AI Development Environment

> **仕様を共通言語として、AIと人間がフェーズを踏んで合意形成しながら進める開発フレームワーク**

エンタープライズ向け・仕様駆動開発（SDD）ベースのAI伴走ツール。
打合せからリリースまで、全工程をAIと伴走する。

| | |
|---|---|
| **開発手法** | 仕様駆動開発（Specification-Driven Development） |
| **対応AIツール** | Claude Code / GitHub Copilot / Codex |
| **対象業務** | PM業務 / 新規開発（大規模） / 運用保守（小規模） |
| **対象ユーザー** | エンジニア・PM（非エンジニアでも利用可能な設計） |

---

## aideとは

AIに任せきりにしない。人間が判断し、仕様を正として段階的に進める。

aideは **24個のスラッシュコマンド** で構成されたワークフローフレームワーク。
`/aide-init` でプロジェクトを初期化し、フェーズに沿ってコマンドを実行するだけで、仕様書・設計書・テスト仕様書・コード・報告資料まで一貫して管理できる。

```
/aide-init         → プロジェクト初期化
/aide-pm-*         → PM・管理（議事録・ブレスト・見積・資料作成...）
/aide-dev-*        → 開発（コード作成・レビュー・テスト・品質レポート...）
/aide-ops-*        → 運用保守（受付・調査・修正・クローズ...）
```

---

## 5つの基本原則

| 原則 | 説明 |
|---|---|
| **Human-in-the-Loop** | AIは提案・生成を担い、人間が判断・承認する |
| **仕様駆動開発（SDD）** | 仕様が唯一の正。コードは仕様の実装、テストは仕様の検証 |
| **フェーズ駆動** | フェーズ順に成果物を確定してから次へ。フェーズ内はイテレーティブ |
| **成果物ベース** | 口頭の合意だけで進めない。各ステップで具体的な成果物を出力 |
| **思考履歴の保全** | ブレストや検討の過程は日付付きファイルで残す |

---

## クイックスタート

```bash
# 1. プロジェクト初期化（最初に1回）
/aide-init dev       # 新規開発
/aide-init ops       # 運用保守
/aide-init dev+ops   # 両方

# 2. フェーズに沿って進める
/aide-pm-brainstorm  # 新規開発: 要件定義から
/aide-ops-new        # 運用保守: 問い合わせ受付から
```

詳しい使い方は [.aide/README.md](.aide/README.md) を参照。

---

## ワークフロー概要

### 新規開発（大規模）

```
要件定義 → 設計 → 計画 → 実装 → テスト → リリース
```

| フェーズ | 使うコマンド |
|---|---|
| 要件定義 | `meeting` → `brainstorm` → `diagram` → `analyze` |
| 設計 | `brainstorm` → `diagram` → `analyze` |
| 計画 | `plan` → `estimate` |
| 実装 | `dev-code` → `dev-review` |
| テスト | `dev-testspec` → `dev-test` → `dev-quality` |
| リリース | `export` → `slide` |

### 運用保守（小規模）

タスクID（`T-XXX`）で並行管理。

```
受付(new) → 調査(investigate) → 修正(fix) → 完了(close)
```

---

## コマンド一覧

### 共通（1個）

| コマンド | 目的 |
|---|---|
| `/aide-init` | プロジェクト初期化 |

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
| `/aide-pm-issues` | 課題ステータス確認 |
| `/aide-pm-docaudit` | ドキュメント監査 |
| `/aide-pm-retro` | 振り返り（KPT） |

### 開発系（6個）

| コマンド | 目的 |
|---|---|
| `/aide-dev-code` | 仕様に基づくコード作成/修正 |
| `/aide-dev-testspec` | 単体/結合テスト仕様書作成 |
| `/aide-dev-test` | テスト実行 + 証跡収集 + レポート |
| `/aide-dev-quality` | カバレッジ・静的解析・セキュリティレポート |
| `/aide-dev-review` | コードレビュー（仕様準拠チェック） |
| `/aide-dev-migrate` | 依存更新 + CVE脆弱性チェック |

### 運用保守系（6個）

| コマンド | 目的 |
|---|---|
| `/aide-ops-new` | 問い合わせ受付 + タスク起票 |
| `/aide-ops-list` | OPENタスク一覧 |
| `/aide-ops-investigate` | タスクの調査・原因分析 |
| `/aide-ops-fix` | タスクの修正対応 |
| `/aide-ops-close` | 対応記録 + クローズ |
| `/aide-ops-status` | 全タスクの対応状況サマリ |

---

## プロジェクト構成

```
.aide/                          ← aide共通フレームワーク
├── rules.md                    ← 共通ルール（マスター）
├── templates/                  ← 成果物・エクスポート用テンプレート
└── README.md                   ← 利用ガイド
.claude/skills/                 ← Claude Code用スキル定義（24個）
.github/copilot-instructions.md ← GitHub Copilot用設定
AGENTS.md                       ← エージェント共通行動規範（Codex等）
CLAUDE.md                       ← プロジェクト固有設定（/aide-initで生成）
```

`/aide-init` を実行すると、対象プロジェクトに以下が生成される:

```
docs(ドキュメント)/
├── 00_pm(管理)/               ← 課題・スケジュール・見積
├── 01_requirements(要件)/     ← 要件書・議事録・ブレスト
├── 02_design(設計)/           ← 設計書
├── 03_plans(製造計画)/        ← 製造計画書
├── 04_testing(テスト)/        ← テスト仕様書・証跡
└── 05_release(リリース)/      ← リリースノート
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
