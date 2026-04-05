#!/usr/bin/env bash
#
# sync-skills.sh
# .aide/skills/ の正本から各AIツール用のラッパーを一括生成する
#
# 使い方:
#   bash .aide/scripts/sync-skills.sh          # 全ツール向けに生成
#   bash .aide/scripts/sync-skills.sh claude    # Claude Code用のみ
#   bash .aide/scripts/sync-skills.sh copilot   # GitHub Copilot用のみ
#   bash .aide/scripts/sync-skills.sh codex     # Codex CLI用のみ
#
# スキル追加時:
#   1. .aide/skills/<skill-name>/SKILL.md を作成
#   2. このスクリプトを実行
#

set -euo pipefail

# プロジェクトルートを検出（.aide/ の親）
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
AIDE_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(dirname "$AIDE_DIR")"

SKILLS_SRC="$AIDE_DIR/skills"
TARGET="${1:-all}"

# 色付き出力（非対応ターミナルでは無視）
green() { printf '\033[32m%s\033[0m\n' "$1"; }
yellow() { printf '\033[33m%s\033[0m\n' "$1"; }
dim() { printf '\033[2m%s\033[0m\n' "$1"; }

# SKILL.md からフロントマターを抽出
extract_field() {
    local file="$1" field="$2"
    sed -n '/^---$/,/^---$/p' "$file" | grep "^${field}:" | sed "s/^${field}: *//"
}

# スキル一覧を取得
get_skills() {
    find "$SKILLS_SRC" -mindepth 1 -maxdepth 1 -type d | sort | while read -r dir; do
        if [ -f "$dir/SKILL.md" ]; then
            basename "$dir"
        fi
    done
}

# ─── Claude Code用ラッパー生成 ─────────────────────────────
generate_claude() {
    local dest="$PROJECT_ROOT/.claude/skills"
    mkdir -p "$dest"

    local count=0
    while IFS= read -r skill; do
        local name description
        name=$(extract_field "$SKILLS_SRC/$skill/SKILL.md" "name")
        description=$(extract_field "$SKILLS_SRC/$skill/SKILL.md" "description")
        [ -z "$name" ] && name="$skill"
        [ -z "$description" ] && description=""

        mkdir -p "$dest/$skill"
        cat > "$dest/$skill/SKILL.md" <<WRAPPER
---
name: ${name}
description: ${description}
---

@../../.aide/skills/${skill}/SKILL.md
WRAPPER
        count=$((count + 1))
    done < <(get_skills)

    green "  Claude Code: ${count} スキルラッパーを生成 → .claude/skills/"
}

# ─── GitHub Copilot用ラッパー生成 ──────────────────────────
generate_copilot() {
    local skills_dest="$PROJECT_ROOT/.github/skills"
    local prompts_dest="$PROJECT_ROOT/.github/prompts"
    mkdir -p "$skills_dest" "$prompts_dest"

    local count=0
    while IFS= read -r skill; do
        local name description
        name=$(extract_field "$SKILLS_SRC/$skill/SKILL.md" "name")
        description=$(extract_field "$SKILLS_SRC/$skill/SKILL.md" "description")
        [ -z "$name" ] && name="$skill"
        [ -z "$description" ] && description=""

        # .github/skills/ （エージェントスキル）
        mkdir -p "$skills_dest/$skill"
        cat > "$skills_dest/$skill/SKILL.md" <<WRAPPER
---
name: ${name}
description: ${description}
---

以下のスキル定義に従って実行してください：

[${name} スキル定義](../../.aide/skills/${skill}/SKILL.md)
WRAPPER

        # .github/prompts/ （スラッシュコマンド）
        cat > "$prompts_dest/${skill}.prompt.md" <<WRAPPER
---
description: "${description}"
agent: agent
---

以下のスキル定義に従って実行してください：

[${name} スキル定義](../.aide/skills/${skill}/SKILL.md)
WRAPPER
        count=$((count + 1))
    done < <(get_skills)

    green "  Copilot:     ${count} スキルラッパーを生成 → .github/skills/, .github/prompts/"
}

# ─── Codex CLI用ラッパー生成 ───────────────────────────────
generate_codex() {
    local dest="$PROJECT_ROOT/.agents/skills"
    mkdir -p "$dest"

    local count=0
    while IFS= read -r skill; do
        local name description
        name=$(extract_field "$SKILLS_SRC/$skill/SKILL.md" "name")
        description=$(extract_field "$SKILLS_SRC/$skill/SKILL.md" "description")
        [ -z "$name" ] && name="$skill"
        [ -z "$description" ] && description=""

        mkdir -p "$dest/$skill"
        cat > "$dest/$skill/SKILL.md" <<WRAPPER
---
name: ${name}
description: ${description}
---

以下のスキル定義に従って実行してください。
正本: ../../.aide/skills/${skill}/SKILL.md
WRAPPER
        count=$((count + 1))
    done < <(get_skills)

    green "  Codex CLI:   ${count} スキルラッパーを生成 → .agents/skills/"
}

# ─── 不要ラッパーの検出 ────────────────────────────────────
check_orphans() {
    local found=0

    for dir in "$PROJECT_ROOT/.claude/skills" "$PROJECT_ROOT/.github/skills" "$PROJECT_ROOT/.agents/skills"; do
        [ -d "$dir" ] || continue
        find "$dir" -mindepth 1 -maxdepth 1 -type d | while read -r wrapper_dir; do
            local skill_name
            skill_name=$(basename "$wrapper_dir")
            if [ ! -d "$SKILLS_SRC/$skill_name" ]; then
                yellow "  孤立ラッパー検出: $wrapper_dir （正本が存在しない）"
                found=1
            fi
        done
    done

    for prompt_file in "$PROJECT_ROOT/.github/prompts"/aide-*.prompt.md; do
        [ -f "$prompt_file" ] || continue
        local skill_name
        skill_name=$(basename "$prompt_file" .prompt.md)
        if [ ! -d "$SKILLS_SRC/$skill_name" ]; then
            yellow "  孤立プロンプト検出: $prompt_file （正本が存在しない）"
            found=1
        fi
    done

    if [ "$found" -eq 0 ]; then
        dim "  孤立ラッパーなし"
    fi
}

# ─── メイン ────────────────────────────────────────────────
echo ""
echo "aide sync-skills"
echo "================"
echo "正本: .aide/skills/ ($(get_skills | wc -l) スキル)"
echo ""

case "$TARGET" in
    claude)
        generate_claude
        ;;
    copilot)
        generate_copilot
        ;;
    codex)
        generate_codex
        ;;
    all)
        generate_claude
        generate_copilot
        generate_codex
        ;;
    *)
        echo "使い方: $0 [all|claude|copilot|codex]"
        exit 1
        ;;
esac

echo ""
echo "孤立チェック:"
check_orphans
echo ""
green "完了"
