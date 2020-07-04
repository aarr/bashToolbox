#!/bin/bash
# ========================================================
# 引数なし
# ネットワーク系コマンドサンプル
# ========================================================
# Socketプログラミング
echo -e '\n\n' 
# HTTPServer構築
echo '============= initial ============= '
echo -e '\n' 
echo '----------- start http server ----------- '
script_dir=$(cd $(dirname $0); pwd)
cmd="(python "$script_dir"/network_socket_echoserver.py) &"
echo '> '$cmd
eval ${cmd}
server_pid=$!
echo 'server pid:'$server_pid
sleep 3


# 終了処理
finally() {
  echo -e '\n\n' 
  echo '============= finally ============= '
  echo '----------- kill process ----------- '
  cmd="kill -9 "$server_pid
  echo '> '$cmd
  eval ${cmd}
}

echo '============= connect ============= '
echo -e '\n' 
echo '----------- nc ----------- '
# Ctrl+Cを捕捉して終了処理を実行
trap 'finally' SIGINT
cmd="nc 127.0.0.1 54321"
echo '> '$cmd
eval ${cmd}


