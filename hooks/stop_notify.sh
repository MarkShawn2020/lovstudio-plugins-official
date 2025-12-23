#!/bin/bash
# Claude Code Stop Hook: Send notification to Lovcode FloatWindow
# Port 23567 is the Lovcode notification server

LOG="/tmp/stop_notify-debug.log"
LOVCODE_PORT=23567

echo "[DEBUG] ========== $(date) ==========" >> "$LOG"

# 读取输入并提取信息
input=$(cat)
echo "[DEBUG] input: $input" >> "$LOG"
transcript_path=$(echo "$input" | jq -r '.transcript_path' | sed "s|^~|$HOME|")
session_id=$(echo "$input" | jq -r '.session_id // empty')

[ ! -f "$transcript_path" ] && exit 0

# 从 transcript 提取上下文信息
first_record=$(head -20 "$transcript_path" | jq -s 'map(select(.cwd)) | first // empty' 2>/dev/null)
cwd=$(echo "$first_record" | jq -r '.cwd // empty')

# 提取项目名
project_name="${cwd##*/}"
[ -z "$project_name" ] && project_name="unknown"

# 通知标题
title="✓ ${project_name}"

# 获取当前 tmux 上下文
TMUX_SESSION=$(tmux display-message -p '#S' 2>/dev/null)
TMUX_WINDOW=$(tmux display-message -p '#I' 2>/dev/null)
TMUX_PANE_IDX=$(tmux display-message -p '#P' 2>/dev/null)
echo "[DEBUG] tmux: session=$TMUX_SESSION, window=$TMUX_WINDOW, pane=$TMUX_PANE_IDX" >> "$LOG"

# 播放提示音
afplay /System/Library/Sounds/Hero.aiff &

# 构建 JSON payload
payload=$(jq -n \
    --arg title "$title" \
    --arg project "$project_name" \
    --arg project_path "$cwd" \
    --arg session_id "$session_id" \
    --arg tmux_session "$TMUX_SESSION" \
    --arg tmux_window "$TMUX_WINDOW" \
    --arg tmux_pane "$TMUX_PANE_IDX" \
    '{
        title: $title,
        project: $project,
        project_path: $project_path,
        session_id: (if $session_id == "" then null else $session_id end),
        tmux_session: (if $tmux_session == "" then null else $tmux_session end),
        tmux_window: (if $tmux_window == "" then null else $tmux_window end),
        tmux_pane: (if $tmux_pane == "" then null else $tmux_pane end)
    }')

echo "[DEBUG] payload: $payload" >> "$LOG"

# 发送到 Lovcode 通知服务器
response=$(curl -s -X POST \
    -H "Content-Type: application/json" \
    -d "$payload" \
    "http://127.0.0.1:${LOVCODE_PORT}/notify" 2>&1)

echo "[DEBUG] response: $response" >> "$LOG"
echo "[DEBUG] 完成" >> "$LOG"
