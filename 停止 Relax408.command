#!/bin/zsh

set -u

local_dir="$(cd "$(dirname "$0")" && pwd)"
pid_file="$local_dir/.relax408.pid"

if [[ ! -f "$pid_file" ]]; then
  /usr/bin/osascript -e 'display notification "Relax 408 本地服务当前没有运行" with title "Relax 408"'
  exit 0
fi

server_pid="$(/bin/cat "$pid_file" 2>/dev/null)"
command_line="$(/bin/ps -p "$server_pid" -o command= 2>/dev/null)"

if [[ "$command_line" == *"Relax408Server"* ]]; then
  /bin/kill "$server_pid" 2>/dev/null
  /usr/bin/osascript -e 'display notification "本地服务已停止" with title "Relax 408"'
else
  /usr/bin/osascript -e 'display notification "未找到正在运行的 Relax 408 服务" with title "Relax 408"'
fi

/bin/rm -f "$pid_file"

