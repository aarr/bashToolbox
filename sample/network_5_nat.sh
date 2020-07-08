#!/bin/bash
# 
# ========================================================
# 引数なし
# NATのサンプル
# ========================================================
# NAT(Network Address Translation)
# 厳密にはNAPT(Network Address Port Translation)
# いくつか種類が存在する。最も利用機械が高いのは２種類
# Source NAT
# Destination NAT
#
# > Source NAT
# NATはルータが実施する
# 送信元ばプライベートアドレスで、送信先がグローバルアドレスの場合
# ルータ自身のインターフェースに付与されているグローバルアドレスに
# パケットのヘッダを書き換える。
# 戻りのときには、ルータのグローバルアドレスからローカルアドレスに
# 再び書き換える
# 実際にはAddress/Portの変換だけでなく、チェックサムなど整合性が
# とれたリクエスト内容にするための書き換えを行ってくれている。
#
# Client1               Router 
# address   port(any)   address       port(auto)
# 192.0.2.1 50000 ----- 203.0.113.254 50100 <=====> Global Address
# 
# Client2
# 192.0.2.2 50000 ----- 203.0.113.254 50101 <=====> Global Address

echo -e '\n\n' 
cat <<EOS
# ++++++++++++++++++++++++++++++++++
# ++++++++++ Source NAT ++++++++++++
# ++++++++++++++++++++++++++++++++++

 lan              router            wan 
  |                  |               |
 lan-veth0 <---> gw-veth0            |
 192.0.2.1       192.0.2.254         |
                     |               |
                 gw-veth1 <----> wan-veth0
                 203.0.113.254   203.0.113.1

EOS
echo '============= initial ============= '
echo '----------- add Network Namespace ----------- '
cmd="ip netns add lan;\
ip netns add router;\
ip netns add wan;"
echo '> '$cmd
eval ${cmd}

echo -e '\n' 
echo '----------- add link ----------- '
cmd="ip link add lan-veth0 type veth peer name gw-veth0;\
ip link add wan-veth0 type veth peer name gw-veth1;"
echo '> '$cmd
eval ${cmd}

echo -e '\n' 
echo '----------- set link ----------- '
cmd="ip link set lan-veth0 netns lan;\
ip link set gw-veth0 netns router;\
ip link set gw-veth1 netns router;\
ip link set wan-veth0 netns wan;"
echo '> '$cmd
eval ${cmd}

echo -e '\n' 
echo '----------- set link up ----------- '
cmd="ip netns exec lan ip link set lan-veth0 up;\
ip netns exec router ip link set gw-veth0 up;\
ip netns exec router ip link set gw-veth1 up;\
ip netns exec wan ip link set wan-veth0 up;"
echo '> '$cmd
eval ${cmd}

echo -e '\n' 
echo '----------- add address ----------- '
# router
cmd="ip netns exec router ip address add 192.0.2.254/24 dev gw-veth0;\
ip netns exec router ip address add 203.0.113.254/24 dev gw-veth1;\
ip netns exec router sysctl net.ipv4.ip_forward=1;"
echo '> '$cmd
eval ${cmd}
# lan
cmd="ip netns exec lan ip address add 192.0.2.1/24 dev lan-veth0;\
ip netns exec lan ip route add default via 192.0.2.254;"
echo '> '$cmd
eval ${cmd}
# wan
cmd="ip netns exec wan ip address add 203.0.113.1/24 dev wan-veth0;\
ip netns exec wan ip route add default via 203.0.113.254;"
echo '> '$cmd
eval ${cmd}

echo '============= nat ============= '
echo '----------- confirm nat rule ----------- '
# NAT設定にはiptablesを利用する
# iptablesとはパケットフィルタリング、NATを実装したもの
# iptablesの機能はいくつかのテーブルという概念で別れている。
# 今回指定するテーブルはnat(-t nat)
# Chainの後ろのPREROUTING/INPUTは処理を適用するタイミング
cmd="ip netns exec router iptables -t nat -L;"
echo '> '$cmd
eval ${cmd}

echo '----------- add nat rule ----------- '
# -A：処理を追加するタイミング（PREROUTING, INPUT, POSTROUTING）
# -s：処理対象となるIPアドレス範囲
# -o：出力先のネットワークインターフェース
# -j：どのように処理するかのルールを指定
cmd="ip netns exec router iptables -t nat
 -A POSTROUTING\
 -s 192.0.2.0/24\
 -o gw-veth1\
 -j MASQUERADE;" #MASQUERADE:LinuxにおけるSourceNATの実装のこと
echo '> '$cmd
eval ${cmd}

echo '----------- confirm nat rule ----------- '
# POSTROUTINGにルールが１つ追加されている
cmd="ip netns exec router iptables -t nat -L;"
echo '> '$cmd
eval ${cmd}


echo -e '\n' 
echo '----------- tcpdump lan ----------- '
cmd="(ip netns exec lan tcpdump -tnl -i lan-veth0 icmp;) &"
echo '> '$cmd
eval ${cmd}
tcpdump_lan_pid=$!
echo 'TCPDUMP LAN PID:'$tcpdump_lan_pid

echo -e '\n' 
echo '----------- tcpdump wan ----------- '
echo <<EOS
WANのTCPDUMP結果にお行ける、パケットのヘッダーに書かれているIPアドレス
が変わっていることを確認（192.0.113.254）に変わっている。
NAT変換がなければIPアドレスの書き換えが行われることはない。
EOS
cmd="(ip netns exec wan tcpdump -tnl -i wan-veth0 icmp;) &"
echo '> '$cmd
eval ${cmd}
tcpdump_wan_pid=$!
echo 'TCPDUMP WAN PID:'$tcpdump_wan_pid

echo -e '\n'
echo '----------- ping lan to wan ----------- '
cmd="ip netns exec lan ping -c 3 203.0.113.1;"
echo '> '$cmd
eval ${cmd}


echo -e '\n' 
echo '============= finally ============= '
echo '----------- kill process ----------- '
cmd="kill -9 "$tcpdump_lan_pid"; kill -9 "$tcpdump_wan_pid
echo '> '$cmd
eval ${cmd}




echo -e '\n\n' 
# > Destination NAT
# WAN（Internet）からLAN（Intranet）にアクセルする為のポート開放
#
# Client1                 Router 
# address                 address        port        address    port
# Global Address  <=====> 203.0.113.254  54321 ----- 192.0.2.1  8888 
cat <<EOS
# ++++++++++++++++++++++++++++++++++
# ++++++++ Destination NAT +++++++++
# ++++++++++++++++++++++++++++++++++
Source NATの環境を再利用
 lan              router            wan 
  |                  |               |
 lan-veth0 <---> gw-veth0            |
 192.0.2.1       192.0.2.254         |
 (8888:tcp server)   |               |
                     |               |
                 gw-veth1 <----> wan-veth0
                 203.0.113.254   203.0.113.1
                 (54321:public port)

EOS
echo '============= initial ============= '
echo '----------- add nat rule ----------- '
cmd="ip netns exec router iptables -t nat
 -A PREROUTING \
 -p tcp \
 --dport 54321 \
 -d 203.0.113.254 \
 -j DNAT \
 --to-destination 192.0.2.1:8888"
echo '> '$cmd
eval ${cmd}

echo -e '\n' 
echo '----------- confirm nat rule ----------- '
# 今回指定するテーブルはnat(-t nat)
cmd="ip netns exec router iptables -t nat -L"
echo '> '$cmd
eval ${cmd}


echo -e '\n' 
echo '----------- add tcp server ----------- '
cmd="(ip netns exec lan nc -lvn 8888) &"
echo '> '$cmd
eval ${cmd}




echo -e '\n\n' 
echo '============= test ============= '
echo '----------- tcpdump wan ----------- '
cmd="(ip netns exec wan tcpdump -tnl -i wan-veth0 'tcp and port 54321';) &"
echo '> '$cmd
eval ${cmd}
tcpdump_lan_pid2=$!
echo 'TCPDUMP PID:'$tcpdump_lan_pid2
sleep 1


echo -e '\n' 
echo '----------- tcpdump wan ----------- '
cmd="(ip netns exec lan tcpdump -tnl -i lan-veth0 'tcp and port 8888';) &"
echo '> '$cmd
eval ${cmd}
tcpdump_wan_pid2=$!
echo 'TCPDUMP PID:'$tcpdump_wan_pid2
sleep 1


echo -e '\n' 
echo '----------- access to server ----------- '
cmd="(ip netns exec wan telnet 203.0.113.254 54321;) &"
echo '> '$cmd
eval ${cmd}
echo -e '\n' 
sleep 1


echo -e '\n\n' 
echo '============= finally ============= '
echo '----------- kill process ----------- '
cmd="kill -9 "$tcpdump_lan_pid2";\
kill -9 "$tcpdump_wan_pid2
echo '> '$cmd
eval ${cmd}

echo '----------- delete Network Namespace  ----------- '
cmd="ip -all netns delete;"
echo '> '$cmd
eval ${cmd}
cmd="ip netns show;"
echo '> '$cmd
eval ${cmd}

