#!/usr/bin/env bash
# 只把 ~/.claude/settings.json 的 tui 設回 "default"（其餘 key 完整保留）。
#
# 為什麼需要：CCC 在 nvim :terminal 內，若 tui=fullscreen 會用 alternate screen，
# 加上 Ink 全畫面重繪會洗掉 scrollback，往上捲看不到舊對話（見 Shiou-Ju/nvim#86）。
# `/tui fullscreen` 會持久化到 ~/.claude/settings.json 造成全域回歸；此 script 一鍵復原。
#
# 用法：bash scripts/set-claude-tui-default.sh
set -euo pipefail

f="${HOME}/.claude/settings.json"

command -v jq >/dev/null 2>&1 || { echo "需要 jq（brew install jq）"; exit 1; }
[ -f "$f" ] || { echo "找不到 $f"; exit 1; }

tmp="$(mktemp)"
jq '.tui = "default"' "$f" > "$tmp" && mv "$tmp" "$f"
echo "已將 tui 設為 default：$f"
