#!/bin/bash
LOG="/tmp/question_notify-debug.log"
echo "[DEBUG] ========== $(date) ==========" >> "$LOG"

# 读取输入并提取信息
input=$(cat)
echo "[DEBUG] input: $input" >> "$LOG"

tool_name=$(echo "$input" | jq -r '.tool_name // empty')
cwd=$(echo "$input" | jq -r '.cwd // empty')
session_id=$(echo "$input" | jq -r '.session_id // empty')

# 提取项目名
project_name="${cwd##*/}"
[ -z "$project_name" ] && project_name="unknown"

# 通知内容
title="❓ ${project_name}"
short_session="${session_id:0:8}"
timestamp=$(date "+%H:%M:%S")

# 获取当前 tmux 上下文
TMUX_SESSION=$(tmux display-message -p '#S' 2>/dev/null)
TMUX_WINDOW=$(tmux display-message -p '#I' 2>/dev/null)
TMUX_WINDOW_NAME=$(tmux display-message -p '#W' 2>/dev/null)
TMUX_PANE_IDX=$(tmux display-message -p '#P' 2>/dev/null)
echo "[DEBUG] tmux: session=$TMUX_SESSION, window=$TMUX_WINDOW, window_name=$TMUX_WINDOW_NAME, pane=$TMUX_PANE_IDX" >> "$LOG"

# 构建通知描述
if [ -n "$TMUX_SESSION" ]; then
    notification_body="${timestamp} | ${TMUX_WINDOW_NAME} | ${TMUX_SESSION} | ${TMUX_PANE_IDX}"
else
    notification_body="${timestamp} | ${short_session}"
fi

# Lovnotifier 发送脚本路径
LOVNOTIFIER_SEND="$HOME/Applications/Lovnotifier.app/Contents/MacOS/lovnotifier-send"

# 发送通知
echo "[DEBUG] 发送问卷通知..." >> "$LOG"
afplay /System/Library/Sounds/Funk.aiff &

if [ -f "$LOVNOTIFIER_SEND" ]; then
    if [ -n "$TMUX_SESSION" ]; then
        bash "$LOVNOTIFIER_SEND" \
            -title "$title" \
            -message "$notification_body" \
            -group "${project_name}_question_${short_session}" \
            -session "$TMUX_SESSION" \
            -window "$TMUX_WINDOW" \
            -pane "$TMUX_PANE_IDX"
    else
        bash "$LOVNOTIFIER_SEND" \
            -title "$title" \
            -message "$notification_body" \
            -group "${project_name}_question_${short_session}"
    fi
    echo "[DEBUG] lovnotifier-send 已调用" >> "$LOG"
else
    echo "[DEBUG] lovnotifier-send 不存在，跳过通知" >> "$LOG"
fi

echo "[DEBUG] 完成" >> "$LOG"
