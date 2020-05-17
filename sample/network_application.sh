#!/bin/bash
# 
# ========================================================
# 引数なし
# アプリケーション層のサンプル
# ========================================================
echo -e '\n\n' 
cat <<EOS
# ++++++++++++++++++++++++++++++++++
# ++++++++++++++ HTTP ++++++++++++++
# ++++++++++++++++++++++++++++++++++
EOS
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
echo '============= start http server ============= '
# pyenv install 3.8.2
# pyenv global 3.8.2
cmd="(python -m http.server -b 127.0.0.1 80) &"
echo '> '$cmd
eval ${cmd}
server_pid=$!
echo 'SERVER PID:'$server_pid
sleep 3


echo -e '\n' 
echo '============= http get ============= '
echo '----------- nc ----------- '
cmd="echo -en 'GET / HTTP/1.0\r\n\r\n' | nc 127.0.0.1 80"
echo '> '$cmd
eval ${cmd}

echo -e '\n' 
echo '----------- curl ----------- '
cmd="curl -X GET -D - http://127.0.0.1/"
echo '> '$cmd
eval ${cmd}


echo -e '\n' 
echo '============= finally ============= '
echo '----------- kill process http server ----------- '
cmd="kill -9 "$server_pid
echo '> '$cmd
eval ${cmd}
sleep 1 

echo -e '\n' 
echo '----------- remove directory ----------- '
cmd="rm -rf "$HTML_DIR
echo '> '$cmd
eval ${cmd}




echo -e '\n\n' 
cat <<EOS
# +++++++++++++++++++++++++++++++++
# ++++++++++++++ DNS ++++++++++++++
# +++++++++++++++++++++++++++++++++
EOS
# ドメイン名の解決方法
# /etc/hosts          DOMAIN:IPの紐づけファイル
# DNS                 PORT:53を利用する
#   /etc/resolv.conf  ネームサーバ/フォワーダの定義
echo '----------- hosts ----------- '
cmd="grep 127.0.0.1 /etc/hosts"
echo '> '$cmd
eval ${cmd}

echo -e '\n' 
echo '----------- DNS ----------- '
# DNS通信のデフォルトポート:53
# 512byteを超える場合、TCPが利用される
cmd="(tcpdump -tnl -i any 'udp and port 53') &"
echo '> '$cmd
eval ${cmd}
tcpdump_pid=$!
echo 'TCPDUMP PID:'$tcpdump_pid
sleep 1


echo -e '\n' 
cmd="dig +short @8.8.8.8 example.org A"
echo '> '$cmd
eval ${cmd}


echo -e '\n' 
echo '----------- resolv.conf ----------- '
cmd="grep nameserver /etc/resolv.conf"
echo '> '$cmd
eval ${cmd}

echo -e '\n' 
# サービス情報表示
# リゾルバの一部として動作するデーモンが表示される
cmd="ss -tulnp | grep ':53 '"
echo '> '$cmd
eval ${cmd}




echo -e '\n' 
echo '============= finally ============= '
echo '----------- kill process ----------- '
cmd="kill -9 "$tcpdump_pid
echo '> '$cmd
eval ${cmd}

