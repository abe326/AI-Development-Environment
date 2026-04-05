# CLAUDE.md — [プロジェクト名]

> **このファイルにはプロジェクト固有の設定のみを記載してください。**
> aide共通ルール（原則・コーディング規約・コマンド一覧等）は `.aide/rules.md` に記載されています。
> `[角括弧]` の部分をプロジェクト固有の情報に置き換えてください。

<!-- ================================================================== -->
<!-- 以下の行は .aide/rules.md を読み込むための設定です。               -->
<!-- この行は削除・変更しないでください。                                -->
@.aide/rules.md
<!-- ================================================================== -->

<!-- ここから下がプロジェクト固有の設定です。自由に編集してください。 -->

## プロジェクト概要

- プロジェクト名: [プロジェクト名]
- 目的: [プロジェクトの目的・背景]
- 技術スタック: [言語、フレームワーク、インフラ]
- 担当: [担当者]

## プロジェクト規模

<!-- aide-init時に設定。この値に応じてスキルの振る舞いが変わる -->
<!-- quick: 簡略フロー / standard: 通常フロー / enterprise: 監査付きフロー -->
enterprise

## 現在のフェーズ

Phase 0: 企画

### フェーズ完了履歴

| フェーズ | 完了日 | 品質ゲート | 備考 |
|---|---|---|---|
| — | — | — | — |

## ディレクトリ構成

```
docs-ドキュメント/
├── 00_pm-管理/                      # フェーズ横断の管理資料
│   ├── issues-課題.md
│   ├── schedule-スケジュール.md
│   ├── estimate-見積もり.md
│   └── slides-資料/
│       └── export/
├── 01_requirements-要件/
│   ├── artifacts-成果物/
│   │   └── 要件書.md ...
│   ├── meeting-notes-打合せ/
│   ├── brainstorms-検討履歴/
│   │   └── index.md
│   ├── reviews-レビュー/
│   ├── slides-資料/
│   │   └── export/
│   └── deliverables-成果物一覧.md
├── 02_design-設計/（同構成）
├── 03_plans-製造計画/（同構成）
├── 04_testing-テスト/
│   ├── artifacts-成果物/
│   ├── evidence-証跡/
│   ├── brainstorms-検討履歴/
│   └── reviews-レビュー/
└── 05_audit-監査/
    ├── audit-trail-監査証跡/
    ├── compliance-台帳/
    │   └── compliance-register.md
    ├── quality-metrics-品質メトリクス/
    │   └── metrics-history.md
    ├── traceability-トレーサビリティ/
    │   └── traceability-matrix.md
    └── reports-レポート/
src/
tests/
```

## フェーズ別AIの利用方針

| Phase | AIの役割 | 人間の役割 | 品質ゲート |
|---|---|---|---|
| 0 企画 | 要件整理、ユーザーストーリー生成 | 判断・承認 | — |
| 1 要件定義 | 要件書草案作成、業務フロー図生成 | レビュー・承認 | `/aide-review-doc` + `/aide-review-audit` |
| 2 設計 | 設計書草案作成、API仕様生成 | アーキテクチャ判断 | `/aide-review-doc` + `/aide-review-audit` |
| 3 製造計画 | 製造計画書作成、リスク分析 | 計画レビュー | `/aide-review-doc` |
| 4 実装 | コード生成、仕様準拠チェック | コードレビュー | `/aide-review-code` |
| 5 テスト | テスト仕様書作成、テスト実行 | テスト方針・品質判断 | `/aide-review-audit`（最終） |

## 成果物一覧

### 管理資料（フェーズ横断）

`docs/00_pm-管理/` で管理。フェーズを通じて常時更新する。

| 成果物 | ファイル | 状態 |
|---|---|---|
| 課題管理 | 00_pm-管理/issues-課題.md | 初期化済み |
| スケジュール | 00_pm-管理/schedule-スケジュール.md | 初期化済み |
| 見積もり | 00_pm-管理/estimate-見積もり.md | 初期化済み |
| コンプライアンス台帳 | 05_audit-監査/compliance-台帳/compliance-register.md | 初期化済み |
| トレーサビリティマトリクス | 05_audit-監査/traceability-トレーサビリティ/traceability-matrix.md | 初期化済み |
| 品質メトリクス履歴 | 05_audit-監査/quality-metrics-品質メトリクス/metrics-history.md | 初期化済み |

### フェーズ別成果物

各フェーズの成果物は `deliverables-成果物一覧.md` で定義されています。プロジェクトに合わせてカスタマイズしてください。

| フェーズ | 成果物一覧 |
|---|---|
| 要件定義 | docs/01_requirements/deliverables-成果物一覧.md |
| 設計 | docs/02_design/deliverables-成果物一覧.md |
| 製造計画 | docs/03_plans/deliverables-成果物一覧.md |
| テスト | docs/04_testing/deliverables-成果物一覧.md |
| 監査 | docs/05_audit/deliverables-成果物一覧.md |

成果物の提出用変換は `/aide-pm-export` で実行できます。

## アーキテクチャ

<!-- 主要な設計判断・技術選定の理由を記載 -->
[技術選定理由]

## プロジェクト固有のルール

<!-- ここにプロジェクト固有のコーディング規約、制約事項、非機能要件等を記載 -->

## 監査対応

- コンプライアンス台帳: docs/05_audit-監査/compliance-台帳/compliance-register.md
- トレーサビリティ: docs/05_audit-監査/traceability-トレーサビリティ/traceability-matrix.md
- 品質メトリクス: docs/05_audit-監査/quality-metrics-品質メトリクス/metrics-history.md
- 監査証跡: docs/05_audit-監査/audit-trail-監査証跡/（各スキル実行時に自動記録）
- 品質ゲート: 各フェーズ完了時に `/aide-review-audit` を実行
