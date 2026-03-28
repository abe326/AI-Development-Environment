---
name: aide-pm-slide
description: 資料を作成する。スライド・見積書・スケジュール・ディスカッション資料の4種類に対応。テンプレートのCSS・構成を使用する
---

# aide-pm-slide: 資料作成

4種類の資料を作成する。利用者の指示内容から適切な種類を自動判定し、テンプレートを使って生成する。

## 対応する資料の種類

| # | 種類 | 形式 | テンプレート | 用途 |
|---|---|---|---|---|
| 1 | **スライド** | Marp md → HTML | slide-template.md + marp-theme.css | プレゼン・説明・ヒアリング |
| 2 | **見積書** | HTML | estimate-template.html + document-style.css | 工数・金額の一覧表 |
| 3 | **スケジュール** | HTML | schedule-template.html + document-style.css | ガントチャート |
| 4 | **ディスカッション資料** | HTML | discussion-template.html + document-style.css | 課題説明・打合せ検討用 |

## 手順

### 1. 資料の種類の判定

ユーザーの指示から資料の種類を自動判定する。判定できない場合は質問形式で確認する。

#### 自動判定のルール

| ユーザーの指示に含まれるキーワード | 判定結果 |
|---|---|
| プレゼン、説明、報告、紹介、提案、ヒアリング、スライド | → スライド |
| 見積、工数、コスト、金額、予算 | → 見積書 |
| スケジュール、ガント、タイムライン、計画、日程、マイルストーン | → スケジュール |
| 検討、議論、ディスカッション、課題、論点、打合せ用、会議用 | → ディスカッション資料 |

#### 判定できない場合の質問

> どのような資料を作成しますか？
>
> 1. **スライド** — プレゼン・説明・ヒアリング用（Marp形式）
> 2. **見積書** — 工数・金額の一覧表
> 3. **スケジュール** — ガントチャート・マイルストーン
> 4. **ディスカッション資料** — 課題の論点整理・打合せ検討用

### 2. テンプレートの読み込み

種類に応じたテンプレートを読み込む：

| 種類 | 読み込むテンプレート |
|---|---|
| スライド | `.aide/templates/export/slide-template.md`, `.aide/templates/export/marp-theme.css`, `.aide/templates/export/metadata.yaml` |
| 見積書 | `.aide/templates/export/estimate-template.html`, `.aide/templates/export/document-style.css` |
| スケジュール | `.aide/templates/export/schedule-template.html`, `.aide/templates/export/document-style.css` |
| ディスカッション | `.aide/templates/export/discussion-template.html`, `.aide/templates/export/document-style.css` |

### 3. コンテキスト収集

種類に応じて必要な情報を収集する。

**全種類共通:**
- CLAUDE.md（プロジェクト概要）
- docs/00_pm-管理/issues-課題.md（OPEN課題）

**スライド:**
- ユーザーがテーマを指定 → その指示に従う
- 指定なし → 最新の成果物（要件書・設計書・製造計画書）に基づく

**見積書:**
- docs/00_pm-管理/estimate-見積もり.md（存在する場合）
- 各フェーズの deliverables-成果物一覧.md（成果物の量から工数を参照）
- 要件書・設計書（スコープの確認）

**スケジュール:**
- docs/00_pm-管理/schedule-スケジュール.md（存在する場合）
- issues-課題.md（残課題の影響）

**ディスカッション資料:**
- ユーザーが指定した論点・テーマ
- 関連するbrainstormsファイル
- issues-課題.md（関連する未決事項）

### 4. 対象読者の確認（スライドのみ）

スライドの場合、対象読者が不明であれば確認する：
- 技術者向け（詳細な技術情報を含む）
- 非技術者向け（ビジネス価値・概要中心）
- 経営層向け（コスト・スケジュール・リスク中心）

### 5. フェーズの判定と出力先の決定

資料の内容からフェーズを判定し、出力先を決定する。

| 内容 | フェーズ | 出力先 |
|---|---|---|
| プロジェクト横断・見積・スケジュール | PM | `docs/00_pm-管理/slides-資料/` |
| 要件に関する資料 | 要件定義 | `docs/01_requirements/slides-資料/` |
| 設計に関する資料 | 設計 | `docs/02_design/slides-資料/` |
| 製造計画に関する資料 | 製造計画 | `docs/03_plans/slides-資料/` |

### 6. 資料の生成

#### スライドの場合

Marp形式mdを生成する。

ファイル名: `YYYYMMDD-テーマ.md`

フロントマター:
```yaml
---
marp: true
theme: aide-corporate
paginate: true
footer: "YYYY-MM-DD | [会社名/部署名]"
---
```

**重要: theme は必ず `aide-corporate` を指定する。header は使用しない。**

スライド構成はslide-template.mdの29パターンから適切なものを選んで使用する。

スライド作成ルール:
1. **1スライド1メッセージ**: 詰め込みすぎない
2. **h2 = スライドタイトル**: 固定位置に表示される
3. **箇条書き中心**: 長文は避ける
4. **図の活用**: .drawio.svg があれば参照
5. **Marpディレクティブ活用**: `<!-- _class: lead/section/summary -->` を使い分ける
6. **スライド枚数**: 10-20枚

#### 見積書の場合

HTMLを直接生成する。estimate-template.htmlのプレースホルダを埋める。

ファイル名: `YYYYMMDD-見積書.html`（slides-資料/export/ に直接出力）

構成:
- 表紙（プロジェクト名・日付・精度レベル）
- サマリカード（合計工数・期間・チーム人数）
- フェーズ別工数テーブル（小計・合計付き）
- 前提条件・不確定要素

#### スケジュールの場合

HTMLを直接生成する。schedule-template.htmlのプレースホルダを埋める。

ファイル名: `YYYYMMDD-スケジュール.html`（slides-資料/export/ に直接出力）

構成:
- 表紙（プロジェクト名・期間）
- マイルストーンカード
- ガントチャート（ラベル固定+日付横スクロール）
- 凡例
- タスク一覧テーブル

#### ディスカッション資料の場合

HTMLを直接生成する。discussion-template.htmlのプレースホルダを埋める。

ファイル名: `YYYYMMDD-テーマ-discussion.html`（slides-資料/export/ に直接出力）

構成:
- 表紙（テーマ・日付・参加者）
- アジェンダ（時間配分付き）
- トピックカード（テーマ毎に）：
  - 背景ボックス（.context-box）
  - 選択肢カード（.options + .option-card、推奨ありなら .recommended）
  - 質問ボックス（.question-box）
  - 決定欄（.decision-box）
- まとめ・次のアクションテーブル

### 7. テーマCSSの配置（スライドのみ）

スライドの場合、出力先フォルダにテーマCSSをコピーする：
- コピー元: `.aide/templates/export/marp-theme.css`
- コピー先: 各フェーズの `slides-資料/aide-corporate.css`

既に存在する場合はコピーしない。

### 8. HTML変換の案内（スライドのみ）

スライドはmdで出力されるため、HTML変換コマンドを案内する：

```bash
marp --html --theme-set [フェーズ]/slides-資料/aide-corporate.css \
  -o [フェーズ]/slides-資料/export/YYYYMMDD-テーマ.html \
  [フェーズ]/slides-資料/YYYYMMDD-テーマ.md
```

見積書・スケジュール・ディスカッション資料はHTMLで直接生成するため変換不要。

または `/aide-pm-export` でまとめて変換可能。
