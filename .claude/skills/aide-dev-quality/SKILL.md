---
name: aide-dev-quality
description: カバレッジレポート・静的解析レポート・セキュリティテスト結果の3種類の品質レポートを生成する。OSSツールまたはAIプロンプト解析で実行する
---

# aide-dev-quality: 品質レポート生成

ソースコードに対してカバレッジ測定・静的解析・セキュリティスキャンを実行し、提出用レポートを生成する。

## 品質チェックの実行方式

技術スタック選定で決定されたツールを使う。ツールが未選定・未導入の場合は **AIプロンプト解析** をフォールバックとして使用する。

| カテゴリ | OSSツール例 | AIプロンプト解析 |
|---|---|---|
| カバレッジ | istanbul, coverage.py, JaCoCo | 不可（ツール必須） |
| 静的解析 | ESLint, Pylint, SonarQube | AIがソースコードを読んで品質チェック |
| セキュリティ | OWASP ZAP, Trivy, npm audit | AIがOWASP Top 10観点でコードレビュー |

## 手順

### 1. 事前読み込み

1. `docs/00_pm-管理/技術スタック選定.md` の「テスト・品質ツール」セクションを読む
2. 対象のソースコード（`src/` 配下）を読む
3. 既存の設定ファイル（`.eslintrc`, `jest.config`, `sonar-project.properties` 等）を確認
4. `docs/02_design/artifacts-成果物/設計書.md` のセキュリティ要件を確認

他の履歴ファイルは読まない。

### 2. 実行対象の確認

ユーザーに以下を確認する（引数で指定されている場合はスキップ）：

- **対象レポート**: `coverage`（カバレッジ） / `static`（静的解析） / `security`（セキュリティ） / `all`（全部）
- **対象範囲**: 全体 / 特定機能

### 3. サブエージェントによる並列実行

#### Sub-A: カバレッジレポート生成

**OSSツール実行の場合:**

```bash
# 例: Jest + istanbul
npx jest --coverage --coverageReporters=json-summary --coverageReporters=text 2>&1 | tee /tmp/coverage-output.log

# 例: pytest + coverage
pytest --cov=src --cov-report=json --cov-report=term 2>&1 | tee /tmp/coverage-output.log
```

- ツールの出力（JSON/テキスト）を解析してレポートmdに変換
- コマンドログも `ansi2html` でHTML化して証跡として保存

**レポート出力:**

出力先: `docs/04_testing-テスト/artifacts-成果物/カバレッジレポート.md`

```markdown
# カバレッジレポート

## 基本情報
- 実行日: YYYY-MM-DD
- ツール: {ツール名}
- 対象: src/ 配下全体
- カバレッジ基準: C0（命令網羅） / C1（分岐網羅）

## サマリ

| メトリクス | カバレッジ | 基準 | 判定 |
|---|---|---|---|
| Statements (C0) | XX.X% | 80% | ✅ / ❌ |
| Branches (C1) | XX.X% | 70% | ✅ / ❌ |
| Functions | XX.X% | 80% | ✅ / ❌ |
| Lines | XX.X% | 80% | ✅ / ❌ |

## ファイル別カバレッジ

| ファイル | Statements | Branches | Functions | Lines |
|---|---|---|---|---|
| src/auth/login.ts | 95.0% | 88.0% | 100% | 95.0% |
| src/auth/session.ts | 72.0% | 60.0% | 80.0% | 72.0% |

## カバレッジ不足の箇所

| ファイル | 未カバー行 | 理由/コメント |
|---|---|---|
| src/auth/session.ts | L45-52 | エラーハンドリング分岐 |

## 改善提案
- [カバレッジ向上のための具体的な提案]
```

#### Sub-B: 静的解析レポート生成

**OSSツール実行の場合:**

```bash
# 例: ESLint
npx eslint src/ --format json -o /tmp/eslint-output.json 2>&1 | tee /tmp/eslint-output.log

# 例: Pylint
pylint src/ --output-format=json > /tmp/pylint-output.json 2>&1
```

**AIプロンプト解析の場合:**

OSSツールが未導入の場合、AIが以下の観点でソースコードを直接分析する：

1. **コード品質**: 命名規則、関数の長さ、複雑度、重複コード
2. **パターン違反**: デッドコード、未使用import、型安全性
3. **保守性**: 依存関係の複雑さ、テスタビリティ
4. **ドキュメント**: 公開APIのドキュメント有無

**レポート出力:**

出力先: `docs/04_testing-テスト/artifacts-成果物/静的解析レポート.md`

```markdown
# 静的解析レポート

## 基本情報
- 実行日: YYYY-MM-DD
- ツール: {ツール名 or AIプロンプト解析}
- 対象: src/ 配下全体
- ルールセット: {ESLint recommended 等}

## サマリ

| 重大度 | 件数 | 基準 | 判定 |
|---|---|---|---|
| Error (重大) | X | 0件 | ✅ / ❌ |
| Warning (警告) | X | 10件以下 | ✅ / ❌ |
| Info (情報) | X | — | — |

## 指摘一覧

| # | 重大度 | ファイル | 行 | ルール | 内容 |
|---|---|---|---|---|---|
| 1 | Error | src/auth/login.ts | 45 | no-unused-vars | 未使用変数 `tempToken` |
| 2 | Warning | src/task/crud.ts | 120 | complexity | 循環的複雑度が15（基準: 10以下） |

## カテゴリ別集計

| カテゴリ | Error | Warning | Info |
|---|---|---|---|
| コード品質 | X | X | X |
| パターン違反 | X | X | X |
| 保守性 | X | X | X |

## 改善提案
- [優先度の高い指摘への具体的な改善提案]
```

#### Sub-C: セキュリティテスト結果生成

**OSSツール実行の場合:**

```bash
# 例: npm audit
npm audit --json > /tmp/npm-audit.json 2>&1

# 例: Trivy
trivy fs --format json -o /tmp/trivy-output.json src/

# 例: OWASP ZAP（API スキャン）
zap-cli quick-scan --self-contained http://localhost:3000 -o /tmp/zap-output.json
```

**AIプロンプト解析の場合:**

OSSツールが未導入の場合、AIが以下のOWASP Top 10観点でソースコードをレビューする：

1. **A01: アクセス制御の不備** — 認可チェックの漏れ、IDOR
2. **A02: 暗号化の失敗** — 平文保存、弱いアルゴリズム
3. **A03: インジェクション** — SQL/OS/LDAP インジェクション、XSS
4. **A04: 安全でない設計** — ビジネスロジックの脆弱性
5. **A05: セキュリティの設定ミス** — デフォルト設定、不要な機能
6. **A06: 脆弱なコンポーネント** — 既知の脆弱性を持つ依存ライブラリ
7. **A07: 識別と認証の失敗** — セッション管理、パスワードポリシー
8. **A08: ソフトウェアとデータの整合性の不備** — 信頼できないソースからのデータ
9. **A09: セキュリティログとモニタリングの不備** — ログ不足、改ざん検知
10. **A10: SSRF（サーバーサイドリクエストフォージェリ）** — 外部URL取得の制限

**レポート出力:**

出力先: `docs/04_testing-テスト/artifacts-成果物/セキュリティテスト結果.md`

```markdown
# セキュリティテスト結果

## 基本情報
- 実行日: YYYY-MM-DD
- ツール: {ツール名 or AIプロンプト解析（OWASP Top 10）}
- 対象: src/ 配下全体 + 依存ライブラリ
- チェック基準: OWASP Top 10 (2021)

## サマリ

| 重大度 | 件数 | 基準 | 判定 |
|---|---|---|---|
| Critical | X | 0件 | ✅ / ❌ |
| High | X | 0件 | ✅ / ❌ |
| Medium | X | — | — |
| Low | X | — | — |

## OWASP Top 10 チェック結果

| # | カテゴリ | 判定 | 指摘件数 | 備考 |
|---|---|---|---|---|
| A01 | アクセス制御の不備 | ✅ / ❌ | X | — |
| A02 | 暗号化の失敗 | ✅ / ❌ | X | — |
| A03 | インジェクション | ✅ / ❌ | X | — |
| A04 | 安全でない設計 | ✅ / ❌ | X | — |
| A05 | セキュリティの設定ミス | ✅ / ❌ | X | — |
| A06 | 脆弱なコンポーネント | ✅ / ❌ | X | — |
| A07 | 識別と認証の失敗 | ✅ / ❌ | X | — |
| A08 | データ整合性の不備 | ✅ / ❌ | X | — |
| A09 | ログとモニタリングの不備 | ✅ / ❌ | X | — |
| A10 | SSRF | ✅ / ❌ | X | — |

## 脆弱性一覧

| # | 重大度 | カテゴリ | ファイル | 行 | 内容 | 推奨対応 |
|---|---|---|---|---|---|---|
| 1 | High | A03 | src/api/users.ts | 35 | SQLインジェクションの可能性 | パラメータバインドを使用 |
| 2 | Medium | A02 | src/auth/password.ts | 12 | MD5ハッシュの使用 | bcrypt/argon2に変更 |

## 依存ライブラリの脆弱性（npm audit / Trivy）

| パッケージ | バージョン | 重大度 | CVE | 修正バージョン |
|---|---|---|---|---|
| lodash | 4.17.20 | High | CVE-XXXX-XXXX | 4.17.21 |

## 改善提案
- [優先度順の具体的な改善提案]
```

### 4. 証跡の保存

品質ツールの実行ログもHTML化して証跡として保存する：

```
docs/04_testing-テスト/evidence-証跡/
└── quality-品質/
    ├── coverage-YYYYMMDD.html     ← カバレッジ実行ログ
    ├── static-analysis-YYYYMMDD.html  ← 静的解析実行ログ
    └── security-scan-YYYYMMDD.html    ← セキュリティスキャン実行ログ
```

### 5. deliverables-成果物一覧.md の更新

`docs/04_testing-テスト/deliverables-成果物一覧.md` の対応する成果物の状態を更新する。

### 6. 課題の起票

Critical/High の指摘がある場合：
1. `docs/00_pm-管理/issues-課題.md` に課題として起票
2. ユーザーに報告し、対応方針を確認

## 技術スタック選定.md への記載ガイド

`docs/00_pm-管理/技術スタック選定.md` に以下のセクションを追加しておくこと（`/aide-pm-brainstorm` で技術スタック検討時に決定）：

```markdown
## テスト・品質ツール

| カテゴリ | ツール | バージョン | 備考 |
|---|---|---|---|
| テストフレームワーク | Jest | ^29.0 | 単体テスト・結合テスト |
| E2Eテスト | Playwright | ^1.40 | 画面テスト・スクリーンショット取得 |
| カバレッジ | istanbul (c8) | ^8.0 | C0/C1カバレッジ測定 |
| 静的解析 | ESLint | ^8.0 | + AI プロンプト解析（補完） |
| セキュリティ | npm audit + AI | — | 依存ライブラリ + OWASP Top 10レビュー |
| ログ変換 | ansi2html | ^1.9 | テスト実行ログのHTML化 |
```

## 前提条件

| ツール | 用途 | 必須/任意 |
|---|---|---|
| ansi2html | 実行ログのHTML化 | 必須 |
| カバレッジツール | カバレッジ測定 | カバレッジレポート時必須 |
| 静的解析ツール | 静的解析 | 任意（AIプロンプトで代替可） |
| セキュリティスキャナ | 脆弱性スキャン | 任意（AIプロンプトで代替可） |

未インストールの場合はインストール手順を案内するか、AIプロンプト解析にフォールバックする。

## 注意事項

- カバレッジはツール実行が必須（AIプロンプトでは代替不可）
- 静的解析・セキュリティはAIプロンプトで代替可能だが、ツール実行の方が網羅的
- AIプロンプト解析を使用した場合、レポートに「AIプロンプト解析」と明記する
- セキュリティ指摘はCritical/Highを優先的に対応する
