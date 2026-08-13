#!/bin/zsh

set -u

local_dir="$(cd "$(dirname "$0")" && pwd)"
server="$local_dir/Relax408Server"
site="$local_dir/站点"
pid_file="$local_dir/.relax408.pid"
url="http://127.0.0.1:4080/"
health_url="${url}.relax408-health"

clear
echo "Relax 408 本地版"
echo "================="

if /usr/bin/curl --noproxy '*' -fsS "$health_url" 2>/dev/null | /usr/bin/grep -q "RELAX408_LOCAL_OK"; then
  echo "本地版已经在运行，正在打开浏览器……"
  /usr/bin/open "$url"
  exit 0
fi

if [[ ! -x "$server" || ! -f "$site/index.html" ]]; then
  echo "启动失败：本地版文件不完整，请重新解压完整压缩包。"
  echo
  read "reply?按回车键关闭窗口。"
  exit 1
fi

"$server" "$site" 4080 &
server_pid=$!
echo "$server_pid" > "$pid_file"

stop_server() {
  if /bin/kill -0 "$server_pid" 2>/dev/null; then
    /bin/kill "$server_pid" 2>/dev/null
  fi
  /bin/rm -f "$pid_file"
}
trap stop_server EXIT INT TERM HUP

ready=0
for attempt in {1..50}; do
  if /usr/bin/curl --noproxy '*' -fsS "$health_url" 2>/dev/null | /usr/bin/grep -q "RELAX408_LOCAL_OK"; then
    ready=1
    break
  fi
  /bin/sleep 0.1
done

if [[ "$ready" -ne 1 ]]; then
  echo "启动失败：端口 4080 可能被其他程序占用。"
  echo "请关闭占用程序后重试。"
  echo
  read "reply?按回车键关闭窗口。"
  exit 1
fi

echo "启动成功，正在打开浏览器：$url"
echo
echo "请保持此窗口开启。关闭窗口即停止 Relax 408 本地服务。"
echo "所有学习记录保存在当前浏览器本机，不会上传到网络。"
/usr/bin/open "$url"

wait "$server_pid"

