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
cmd="(python "$script_dir"/network_socket_addserver.py) &"
echo '> '$cmd
eval ${cmd}
server_pid=$!
echo 'server pid:'$server_pid
sleep 3


echo '============= connect ============= '
echo -e '\n' 
echo '----------- request ----------- '
cmd="python "$script_dir"/network_socket_addclient.py"
echo '> '$cmd
eval ${cmd}


