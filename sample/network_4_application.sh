#!/bin/bash
# 
# ========================================================
# 引数なし
# アプリケーション層のサンプル
# ========================================================
# HTTP通信確認
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




# DHS通信確認
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




# DHCP通信確認
echo -e '\n\n' 
cat <<EOS
# +++++++++++++++++++++++++++++++++
# +++++++++++++ DHCP ++++++++++++++
# +++++++++++++++++++++++++++++++++
EOS
echo '============= initial ============= '
echo '----------- add netns ----------- '
cmd="ip netns add server;\
ip netns add client;"
echo '> '$cmd
eval ${cmd}

echo '----------- add link ----------- '
cmd="ip link add s-veth0 type veth peer name c-veth0"
echo '> '$cmd
eval ${cmd}

echo '----------- link up ----------- '
cmd="ip  link set s-veth0 netns server;\
ip link set c-veth0 netns client;"
echo '> '$cmd
eval ${cmd}

echo '----------- link up ----------- '
cmd="ip netns exec server ip link set s-veth0 up;\
ip netns exec client ip link set c-veth0 up;"
echo '> '$cmd
eval ${cmd}

echo '----------- set address ----------- '
# ServerのみIPアドレスを設定
cmd="ip netns exec server ip address add 192.0.2.254/24 dev s-veth0"
echo '> '$cmd
eval ${cmd}


echo -e '\n' 
echo '============= DHCP Server & Client ============= '
echo '----------- dhcp server ----------- '
# ServerにDNSの設定
# DHCPサーバの起動(192.0.2.100〜192.0.2.200の範囲でIPアドレス割当を行う）
cmd="(ip netns exec server dnsmasq --dhcp-range=192.0.2.100,192.0.2.200,255.255.255.0 --interface=s-veth0 --no-daemon) &"
echo '> '$cmd
eval ${cmd}
dhcp_server_pid=$!
echo 'DHCP SERVER PID:'$dhcp_server_pid

echo -e '\n' 
echo '----------- dhcp client ----------- '
# DHCPクライアント実行
cmd="ip netns exec client dhclient c-veth0"
echo '> '$cmd
eval ${cmd}

echo -e '\n' 
echo '----------- get ip address ----------- '
cmd="ip netns exec client ip address show | grep 'inet '"
echo '> '$cmd
eval ${cmd}

echo -e '\n' 
echo '----------- get routing table ----------- '
# DHCPを利用すると、IPアドレス、ルーティングテーブルを自動で設定可能
# DNSのネームサーバ、時刻同期のNTPサーバも設定が可能
cmd="ip netns exec client ip route show"
echo '> '$cmd
eval ${cmd}


echo -e '\n' 
echo '============= finally ============= '
echo '----------- kill process ----------- '
cmd='kill -9 '$dhcp_server_pid
echo '> '$cmd
eval ${cmd}

echo '----------- delete netns ----------- '
cmd='ip -all netns delete'
echo '> '$cmd
eval ${cmd}

cmd='ip netns show'
echo '> '$cmd
eval ${cmd}



