---
name: aide-pm-export
description: 成果物をHTML中間形式経由で提出用形式に変換する。成果物の提出・納品時に使う
---

# aide-pm-export: 成果物エクスポート

deliverables-成果物一覧.md を参照し、現時点の成果物を提出用形式に一括変換する。フェーズ完了を待たず、いつでも実行可能。

**基本フロー: md → HTML → PDF / docx / pptx**

HTMLを中間形式として必ず生成し、そこから各種形式に変換する（HTML-First）。

## 資料の種類（5種類）

| # | 種類 | 用途 | テンプレート |
|---|---|---|---|
| 1 | スライド | プレゼン・説明・ヒアリング | slide-template.md + marp-theme.css |
| 2 | ドキュメント | 要件書・設計書等の提出用 | document-template.html + document-style.css |
| 3 | 見積書 | 工数・金額の一覧表 | estimate-template.html + document-style.css |
| 4 | スケジュール表 | ガントチャート | schedule-template.html + document-style.css |
| 5 | ディスカッション資料 | 課題説明・打合せ検討用 | discussion-template.html + document-style.css |

## テンプレートファイル

| ファイル | 用途 |
|---|---|
| `.aide/templates/export/document-template.html` | 提出用ドキュメントテンプレート |
| `.aide/templates/export/estimate-template.html` | 見積書テンプレート |
| `.aide/templates/export/schedule-template.html` | スケジュール表（ガントチャート）テンプレート |
| `.aide/templates/export/discussion-template.html` | ディスカッション資料テンプレート |
| `.aide/templates/export/document-style.css` | ドキュメント共通CSS |
| `.aide/templates/export/marp-theme.css` | スライド用CSS |
| `.aide/templates/export/slide-template.md` | スライド構成テンプレート |

## 手順

### 1. 対象フェーズの確認

ユーザーに以下を確認する（引数で指定されている場合はスキップ）：
- エクスポート対象のフェーズ（要件定義 / 設計 / 製造計画 / テスト / 全フェーズ）

### 2. deliverables-成果物一覧.md の読み込み

対象フェーズの deliverables-成果物一覧.md を読み、エクスポート対象を特定する：
- 「対象外」の成果物はスキップ
- エクスポート形式が「—」の成果物はスキップ
- 状態が「未作成」の成果物は警告を表示してスキップ

### 3. エクスポート対象の一覧表示

変換前に対象一覧をユーザーに提示し、確認を得る：

```
📦 エクスポート対象（要件定義フェーズ）

| # | 成果物 | 元ファイル | 出力形式 | 状態 |
|---|---|---|---|---|
| 1 | 要件書（全体） | artifacts-成果物/要件書.md | html → docx | ✅ 作成済み |
| 2 | 要件書（タスク管理） | artifacts-成果物/要件書-タスク管理.md | html → docx | ✅ 作成済み |
| 3 | ユースケース図 | artifacts-成果物/ユースケース図.drawio.svg | png | ⚠️ 未作成（スキップ） |

出力先: docs/01_requirements/slides-資料/export/
実行してよろしいですか？
```

### 4. ドキュメントのエクスポート

要件書・設計書・製造計画書等のmdドキュメントを変換する。

1. deliverables-成果物一覧.md を読み込み、エクスポート対象を特定
2. artifacts-成果物/ 内の対象mdファイルを `marked` でHTMLに変換
3. .drawio.svg ファイルがあればSVGをインラインで埋め込み（ズーム機能付き）
4. `.aide/templates/export/document-template.html` のプレースホルダを埋めてHTML出力
5. 出力先: 対象フェーズフォルダ内の `slides-資料/export/` ディレクトリ
6. PDF/docxが必要な場合はHTMLからさらに変換（ブラウザ印刷 or pandoc）

#### プレースホルダ一覧（document-template.html）

| プレースホルダ | 内容 |
|---|---|
| `{{PROJECT_NAME}}` | プロジェクト名 |
| `{{DOCUMENT_TITLE}}` | 文書タイトル（要件書、設計書等） |
| `{{DATE}}` | 作成日 |
| `{{VERSION}}` | バージョン |
| `{{STATUS}}` | ステータス |
| `{{CSS}}` | CSSの内容（document-style.css から読み込み） |
| `{{TOC}}` | 目次HTML |
| `{{CONTENT}}` | 本文HTML（marked で変換したmd） |
| `{{FIGURES}}` | 図のモーダルHTML |
| `{{FOOTER_TEXT}}` | フッターテキスト |

#### SVG図のインライン埋め込み

mdファイル内で参照されている `.drawio.svg` ファイルを検出し、以下の形式でインラインに埋め込む：

```html
<div class="figure-container" data-modal="modal-図のID">
  <!-- SVGの内容をここにインライン埋め込み -->
  <svg ...>...</svg>
  <div class="figure-caption">図1: ユースケース図</div>
</div>
```

モーダル（ズーム表示用）は `{{FIGURES}}` プレースホルダに埋め込む：

```html
<div class="modal-overlay" id="modal-図のID">
  <span class="modal-close">&times;</span>
  <div class="modal-content">
    <!-- 拡大表示用のSVGをここにインライン埋め込み -->
    <svg ...>...</svg>
  </div>
</div>
```

### 5. 見積書のエクスポート

docs/00_pm-管理/estimate-見積もり.md からHTML見積書を生成する。

1. estimate-見積もり.md を `marked` でHTMLに変換
2. `.aide/templates/export/estimate-template.html` のプレースホルダを埋める
3. サマリカード（合計工数・合計金額・精度レベル）を自動生成
4. 出力先: `docs/00_pm-管理/slides-資料/export/見積書.html`

#### 見積書固有のプレースホルダ

| プレースホルダ | 内容 |
|---|---|
| `{{ACCURACY}}` | 見積もり精度（±50% / ±30% / ±15%） |

### 6. スケジュール表のエクスポート

docs/00_pm-管理/schedule-スケジュール.md からHTMLガントチャートを生成する。

1. schedule-スケジュール.md を読み込む
2. マイルストーン一覧とタスク一覧を解析
3. CSS GridベースのガントチャートをHTML生成
4. `.aide/templates/export/schedule-template.html` のプレースホルダを埋める
5. 出力先: `docs/00_pm-管理/slides-資料/export/スケジュール.html`

#### ガントチャートの生成ルール
- 横軸: 週単位（期間に応じて月単位に切り替え）
- 縦軸: タスク一覧（依存関係があれば順序反映）
- バーの色: フェーズごとに色分け（requirements=青, design=紫, plans=黄, implementation=緑, test=赤, release=灰）
- マイルストーン: ◆マークで表示

#### スケジュール固有のプレースホルダ

| プレースホルダ | 内容 |
|---|---|
| `{{PERIOD}}` | プロジェクト期間（例: 2026年4月〜6月） |

### 7. ディスカッション資料のエクスポート

ユーザーが指定した内容・論点からディスカッション用HTMLを生成する。

1. ユーザーから以下を確認する：
   - 議論テーマ（1つまたは複数）
   - 各テーマの論点・選択肢（あれば）
   - 参加者
   - 関連する既存資料（issues.md, brainstormsのファイル等）
2. 関連資料を読み込んでコンテキストを把握
3. 各テーマごとに「トピックカード」形式でHTMLを生成：
   - 背景・コンテキスト
   - 論点（質問形式）
   - 選択肢（あれば比較カード形式で）
   - 決定欄（打合せ中に記入するための空欄）
4. `.aide/templates/export/discussion-template.html` のプレースホルダを埋める
5. 出力先: 各フェーズの `slides-資料/export/YYYYMMDD-テーマ-discussion.html`
   - PM関連 → `docs/00_pm-管理/slides-資料/export/`
   - 要件関連 → `docs/01_requirements/slides-資料/export/`
   - 設計関連 → `docs/02_design/slides-資料/export/`
   - 製造計画関連 → `docs/03_plans/slides-資料/export/`

#### ディスカッション資料の構成要素

| 要素 | CSSクラス | 用途 |
|---|---|---|
| トピックカード | `.topic-card` | テーマごとのまとまり |
| 背景ボックス | `.context-box` | 背景・経緯の説明 |
| 選択肢カード | `.options` + `.option-card` | 複数案の比較（推奨ありなら `.recommended`） |
| 質問ボックス | `.question-box` | 議論してほしい論点 |
| 決定欄 | `.decision-box` | 打合せ中の記入スペース |
| アジェンダ | `.agenda` | 打合せの進行表 |

#### ディスカッション固有のプレースホルダ

| プレースホルダ | 内容 |
|---|---|
| `{{PARTICIPANTS}}` | 参加者 |

### 8. スライドのエクスポート

Marp形式のスライドmdを変換する。

1. Marp md を `marp --html --theme-set aide-corporate.css` でHTML変換
2. .drawio.svg はimgタグで参照（スライドと同じフォルダに配置）
3. pptxが必要な場合は `marp --pptx` で変換

### 6. 変換コマンド一覧

| 変換 | コマンド | 備考 |
|---|---|---|
| md → html（ドキュメント） | `marked` + `document-template.html` | 必ず最初にHTMLを生成 |
| md → html（スライド） | `marp --html --theme-set aide-corporate.css` | Marp形式のみ |
| html → pdf | ブラウザ印刷（Ctrl+P） or `playwright` | HTMLから変換 |
| html → docx | `pandoc {input}.html -o {output}.docx` | HTMLから変換 |
| md → pptx（スライド） | `marp --pptx --theme-set aide-corporate.css` | Marp直接変換 |
| drawio.svg → png | `drawio -x -f png -o {output}.png {input}.drawio.svg` | 図の単体変換 |
| drawio.svg → pdf | `drawio -x -f pdf --crop -o {output}.pdf {input}.drawio.svg` | 図の単体変換 |

### 7. 変換結果の報告

変換結果を一覧で報告する：

```
📦 エクスポート完了

| # | 成果物 | 出力ファイル | 結果 |
|---|---|---|---|
| 1 | 要件書（全体） | export/要件書.html | ✅ 成功 |
| 2 | 要件書（全体） | export/要件書.docx | ✅ 成功（HTMLから変換） |

```

### 8. deliverables-成果物一覧.md の状態更新

エクスポート成功した成果物の「状態」列を更新する：
- 「作成済み」→ 変更なし
- エクスポート日時を備考として追記してもよい

## フォルダ構成

```
docs/01_requirements/
├── artifacts-成果物/           ← 元ファイル（md）
│   ├── 要件書.md
│   ├── 要件書-タスク管理.md
│   └── ユースケース図.drawio.svg
├── deliverables-成果物一覧.md  ← 成果物一覧
└── slides-資料/                ← スライド・エクスポート
    ├── aide-corporate.css       ← テーマCSS
    ├── YYYYMMDD-テーマ.md       ← スライドmd
    └── export/                  ← エクスポート先
        ├── 要件書.html          ← 中間形式（必ず生成）
        ├── 要件書.docx          ← 最終形式（必要に応じて）
        └── 要件書-タスク管理.html
```

## 前提条件

以下のツールがインストールされている必要がある：
- **marked**: md → HTML 変換（必須）
- **pandoc**: HTML → docx 変換（docxが必要な場合）
- **marp-cli**: Marp形式md → html / pptx 変換（スライドのみ）
- **drawio CLI**: drawio.svg → png / pdf 変換（図の単体変換）
- **playwright**（オプション）: HTML → PDF 自動変換

ツールが未インストールの場合、該当する変換をスキップし、インストール手順を案内する。
PDFはブラウザ印刷（Ctrl+P）でも生成可能なため、playwright は必須ではない。

## 注意事項

- エクスポートは成果物の「スナップショット」であり、元のmdが更新されたら再実行が必要
- export/ フォルダはgitignoreに追加することを推奨（バイナリファイルのため）
- フェーズ完了を待たず、レビュー提出用にいつでも実行可能
- HTMLは中間形式として必ず生成する。直接 md → docx/pdf への変換は行わない
