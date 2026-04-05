---
name: aide-review-code
description: コードレビューを実施する。実装完了後のレビュー時に使う。仕様準拠・品質・セキュリティ・カバレッジ・静的解析を一括チェック。--scopeで絞り込み可能
---

# aide-review-code: コードレビュー

仕様準拠・コード品質・セキュリティ・カバレッジ・静的解析の観点でコードレビューを実施する。

## 手順

### 1. 対象コードと仕様書の特定

ユーザーに以下を確認する（引数で指定されている場合はスキップ）：

- **レビュー対象のコード**（ファイルパス、PR、差分など）
- **対応する機能名**
- **スコープ**（省略時: all）
  - `all` — 全観点（仕様準拠 + 品質 + セキュリティ + カバレッジ + 静的解析）
  - `spec` — 仕様準拠チェックのみ
  - `quality` — コード品質 + 静的解析
  - `security` — セキュリティチェック + 脆弱性スキャン
  - `coverage` — カバレッジ測定のみ

以下を読み込む：
- 対象のソースコード
- 対応する設計書（docs/02_design/artifacts-成果物/設計書-{機能名}.md）
- 対応する製造計画書（docs/03_plans/artifacts-成果物/製造計画書-{機能名}.md、存在する場合）
- docs/01_requirements/artifacts-成果物/要件書.md（要件書）
- docs/00_pm-管理/技術スタック選定.md の「テスト・品質ツール」セクション（品質ツール確認用）
- 既存の設定ファイル（.eslintrc, jest.config 等）

他の履歴ファイルは読まない。

### 2. サブエージェントによる並列レビュー

スコープに応じて該当するサブエージェントのみ実行する。`all` の場合は全て並列実行。

#### Sub-A: 仕様準拠チェック（scope: all, spec）

- コードが設計書通りに実装されているか
- 設計書に記載された要件がすべて実装されているか
- 設計書にない機能が追加されていないか
- 仕様との差異があれば指摘

#### Sub-B: コード品質 + 静的解析チェック（scope: all, quality）

**AIレビュー:**
- 可読性（命名、構造、コメント）
- 保守性（結合度、凝集度、DRY原則）
- 設計パターンの適切な使用
- エラーハンドリング
- パフォーマンス上の懸念

**OSSツール実行**（ESLint, Pylint 等が導入済みの場合）:

```bash
# 例: ESLint
npx eslint src/ --format json -o /tmp/eslint-output.json 2>&1 | tee /tmp/eslint-output.log

# 例: Pylint
pylint src/ --output-format=json > /tmp/pylint-output.json 2>&1
```

ツール未導入の場合はAIが以下の観点で直接分析する：
1. コード品質: 命名規則、関数の長さ、複雑度、重複コード
2. パターン違反: デッドコード、未使用import、型安全性
3. 保守性: 依存関係の複雑さ、テスタビリティ
4. ドキュメント: 公開APIのドキュメント有無

#### Sub-C: セキュリティチェック（scope: all, security）

**AIレビュー（OWASP Top 10）:**
- A01: アクセス制御の不備 — 認可チェックの漏れ、IDOR
- A02: 暗号化の失敗 — 平文保存、弱いアルゴリズム
- A03: インジェクション — SQL/OS/LDAP インジェクション、XSS
- A04: 安全でない設計 — ビジネスロジックの脆弱性
- A05: セキュリティの設定ミス — デフォルト設定、不要な機能
- A06: 脆弱なコンポーネント — 既知の脆弱性を持つ依存ライブラリ
- A07: 識別と認証の失敗 — セッション管理、パスワードポリシー
- A08: ソフトウェアとデータの整合性の不備 — 信頼できないソースからのデータ
- A09: セキュリティログとモニタリングの不備 — ログ不足、改ざん検知
- A10: SSRF — 外部URL取得の制限

**OSSツール実行**（npm audit, Trivy 等が導入済みの場合）:

```bash
# 例: npm audit
npm audit --json > /tmp/npm-audit.json 2>&1

# 例: Trivy
trivy fs --format json -o /tmp/trivy-output.json src/
```

#### Sub-D: カバレッジ測定（scope: all, coverage）

**注意: カバレッジはツール実行が必須（AIプロンプトでは代替不可）。**

```bash
# 例: Jest + istanbul
npx jest --coverage --coverageReporters=json-summary --coverageReporters=text 2>&1 | tee /tmp/coverage-output.log

# 例: pytest + coverage
pytest --cov=src --cov-report=json --cov-report=term 2>&1 | tee /tmp/coverage-output.log
```

ツール未導入の場合はスキップし、その旨をレポートに記載する。

### 3. レビュー結果の統合

指摘事項を統合し、以下の形式で報告する：

```markdown
## レビュー結果: [対象ファイル/機能名]

### Critical（修正必須）
- [ ] [指摘内容]（仕様準拠/品質/セキュリティ）

### Important（修正推奨）
- [ ] [指摘内容]（仕様準拠/品質/セキュリティ）

### Minor（改善提案）
- [ ] [指摘内容]（仕様準拠/品質/セキュリティ）

### Good Points（良い点）
- [コードの良い部分も記載]

### 仕様カバレッジ
- カバー済み: [設計書の該当項目]
- 未実装: [設計書の該当項目]

### 品質メトリクス（ツール実行時）

#### カバレッジ
| メトリクス | カバレッジ | 基準 | 判定 |
|---|---|---|---|
| Statements (C0) | XX.X% | 80% | ✅ / ❌ |
| Branches (C1) | XX.X% | 70% | ✅ / ❌ |
| Functions | XX.X% | 80% | ✅ / ❌ |
| Lines | XX.X% | 80% | ✅ / ❌ |

#### 静的解析サマリ
| 重大度 | 件数 |
|---|---|
| Error | X |
| Warning | X |

#### セキュリティサマリ（OWASP Top 10）
| # | カテゴリ | 判定 | 指摘件数 |
|---|---|---|---|
| A01 | アクセス制御の不備 | ✅ / ❌ | X |
| ... | ... | ... | ... |
```

### 4. レビュー結果・品質レポートの保存

#### レビュー結果

レビュー対象の成果物が属するフェーズの reviews/ フォルダに保存：

| レビュー対象 | 保存先 |
|---|---|
| 要件書のレビュー | docs/01_requirements/reviews/YYYYMMDD-[対象名].md |
| 設計書のレビュー | docs/02_design/reviews/YYYYMMDD-[対象名].md |
| 製造計画書のレビュー | docs/03_plans/reviews/YYYYMMDD-[対象名].md |
| コードレビュー | docs/02_design/reviews/YYYYMMDD-[対象名].md |

reviews/ フォルダが存在しない場合は作成する。

#### 品質レポート（ツール実行時のみ）

scope に coverage, quality, security が含まれツール実行した場合、以下にもレポートを出力する：

| レポート | 出力先 |
|---|---|
| カバレッジレポート | docs/04_testing/artifacts-成果物/カバレッジレポート.md |
| 静的解析レポート | docs/04_testing/artifacts-成果物/静的解析レポート.md |
| セキュリティテスト結果 | docs/04_testing/artifacts-成果物/セキュリティテスト結果.md |

#### 証跡

ツール実行ログを `ansi2html` でHTML化して保存：

```
docs/04_testing-テスト/evidence-証跡/quality-品質/
├── coverage-YYYYMMDD.html
├── static-analysis-YYYYMMDD.html
└── security-scan-YYYYMMDD.html
```

### 5. deliverables-成果物一覧.md の更新

品質レポートを出力した場合、`docs/04_testing-テスト/deliverables-成果物一覧.md` の対応する成果物の状態を更新する。

### 6. 課題への起票

Critical または Important の指摘がある場合、ユーザーの確認を得て docs/00_pm-管理/issues-課題.md に課題として起票する。レビュー結果ファイルへのリンクを検討履歴に記載する。

### 7. 品質メトリクスの記録（Enterprise モードのみ）

CLAUDE.md の「プロジェクト規模」が `enterprise` の場合、レビュー結果から以下のメトリクスを docs/05_audit-監査/quality-metrics-品質メトリクス/metrics-history.md に追記する:

| 日付 | カバレッジ(C0) | カバレッジ(C1) | 静的解析(Error) | 静的解析(Warning) | セキュリティ(Critical) | 備考 |
|---|---|---|---|---|---|---|
| YYYY-MM-DD | XX% | XX% | X | X | X | [レビュー対象の概要] |

### 8. 監査証跡の記録（Enterprise モードのみ）

CLAUDE.md の「プロジェクト規模」が `enterprise` の場合、以下を実行する:

1. 本スキルの実行内容を監査証跡として記録する
2. 保存先: docs/05_audit-監査/audit-trail-監査証跡/YYYYMMDD-HHMMSS-aide-review-code.md

#### 監査証跡フォーマット

```markdown
# 監査証跡: aide-review-code 実行記録

## 実行情報
| 項目 | 内容 |
|---|---|
| 実行日時 | YYYY-MM-DD HH:MM |
| スキル | aide-review-code |
| 実行者 | [CLAUDE.mdの担当者] |
| 対象 | [対象ファイル/機能名] |

## 入力（参照した仕様）
- [参照ファイル一覧]

## 実行結果
- [作成/変更されたファイル一覧]
- [品質チェック結果（該当する場合）]

## 承認記録
- ユーザー承認: [Yes/No]
- 承認内容: [承認した内容の要約]
```

`enterprise` でない場合はスキップする。

## 注意事項

- レビューは設計書を正として行う（「動いているから良い」ではない）
- 良い点も積極的にコメントする
- 修正の提案には具体的なコード例を示す
- カバレッジはツール実行が必須（AIプロンプトでは代替不可）
- 静的解析・セキュリティはAIプロンプトで代替可能だが、ツール実行の方が網羅的
- AIプロンプト解析を使用した場合、レポートに「AIプロンプト解析」と明記する
