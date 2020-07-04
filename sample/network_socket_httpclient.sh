#!/bin/bash
# 
# ========================================================
# 引数なし
# ネットワーク系コマンドサンプル
# ========================================================
# Socketプログラミング
echo -e '\n\n' 
cat <<EOS
TODO
EOS
# HTTPServer構築
echo '============= initial ============= '
echo '----------- deploy html ----------- '
SCRIPT_DIR=$(cd $(dirname $0); pwd)
HTML_DIR='/var/tmp/http-home'
# make directory
cmd="mkdir -p "$HTML_DIR
echo '> '$cmd
eval ${cmd}
# copy
cmd="cp "$SCRIPT_DIR'/index.html '$HTML_DIR
echo '> '$cmd
eval ${cmd}


echo -e '\n' 
echo '----------- start http server ----------- '
cmd="(python -m http.server -b 127.0.0.1 80) &"
echo '> '$cmd
eval ${cmd}
server_pid=$!
echo 'SERVER PID:'$server_pid
sleep 3




echo -e '\n\n' 
echo '============= connect ============= '
cmd="python "$SCRIPT_DIR"/network_socket.py"
echo '> '$cmd
eval ${cmd}




echo -e '\n\n' 
echo '============= finally ============= '
echo '----------- kill process ----------- '
cmd="kill -9 "$server_pid
echo '> '$cmd
eval ${cmd}


