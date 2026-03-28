---
name: aide-ops-list
description: OPEN/IN_PROGRESSのタスク一覧を優先度順に表示する。運用保守の日次確認用
---

# aide-ops-list: タスク一覧表示

OPEN/IN_PROGRESS のタスクを優先度順に一覧表示する。

## 手順

### 1. tasks-タスク.md の読み込み

docs/00_pm-管理/tasks-タスク.md を読む。他のファイルは読まない。

### 2. 一覧の生成・表示

OPEN と IN_PROGRESS のタスクを優先度順に表示する：

```
## OPEN/IN_PROGRESS タスク一覧（YYYY-MM-DD時点）

### 対応中（IN_PROGRESS）: X件
| ID | タイトル | 優先度 | 担当 | 起票日 | 経過日数 |
|---|---|---|---|---|---|

### 未着手（OPEN）: X件
| ID | タイトル | 優先度 | 担当 | 起票日 | 経過日数 |
|---|---|---|---|---|---|

合計: X件（IN_PROGRESS: X件 / OPEN: X件）
```

### 3. 警告表示

以下の場合は警告を表示する：
- 高優先度の OPEN タスクが3日以上放置されている
- IN_PROGRESS が5件以上（並行しすぎ）
- 起票から14日以上経過した OPEN タスクがある

## 注意事項

- 表示のみ。ファイルの更新は行わない
- 詳細を見たい場合は /aide-ops-investigate を案内する
