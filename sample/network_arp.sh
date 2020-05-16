#!/bin/bash
# 
# ========================================================
# 引数なし
# ネットワーク系コマンドサンプル
# ========================================================
# MACアドレス確認
# パケットキャプチャにより、MACアドレス変換を確認する
echo '=========== arp 1 =========== '
# ++++++++++++++ arp 1 ++++++++++++++
#    ns1               ns2
#     |                 |
# ns1-veth0 <------> ns2-veth0
# 192.0.2.1          192.0.2.2
# 00:00:5E:00:53:01  00:00:5E:00:53:02
# 
# NetworkNamespaceを作成し、pingが通るまでを実施
echo '----------- init ----------- '
cmd="ip netns add ns1;\
ip netns add ns2;"
echo '> '$cmd
eval ${cmd}

cmd="ip link add ns1-veth0 type veth peer name ns2-veth0"
echo '> '$cmd
eval ${cmd}

cmd="ip link set ns1-veth0 netns ns1;\
ip link set ns2-veth0 netns ns2;" 
echo '> '$cmd
eval ${cmd}

cmd="ip netns exec ns1 ip address add 192.0.2.1/24 dev ns1-veth0" 
echo '> '$cmd
eval ${cmd}

cmd="ip netns exec ns2 ip address add 192.0.2.2/24 dev ns2-veth0" 
echo '> '$cmd
eval ${cmd}

cmd="ip netns exec ns1 ip link set ns1-veth0 up;\
ip netns exec ns2 ip link set ns2-veth0 up;" 
echo '> '$cmd
eval ${cmd}


echo -e '\n' 
# MACアドレス指定
echo '----------- mac address setting ----------- '
cmd="ip netns exec ns1 ip link set dev ns1-veth0 address 00:00:5E:00:53:01;\
ip netns exec ns2 ip link set dev ns2-veth0 address 00:00:5E:00:53:02;" 
echo '> '$cmd
eval ${cmd}


echo -e '\n' 
# ping
echo '----------- ping ----------- '
cmd="ip netns exec ns1 ping -c 3 192.0.2.2" 
echo '> '$cmd
eval ${cmd}


echo -e '\n' 
# MACアドレスのキャッシュ確認
echo '----------- neigh ----------- '
cmd="ip netns exec ns1 ip neigh" 
echo '> '$cmd
eval ${cmd}


echo -e '\n' 
# TCPDUMP
# 別ターミナルでtcpdumpを行いながら、pingを実行
# 
# MACアドレスキャッシュクリア
# ip netns exec ns1 ip neigh flush all
# tcpdump
# ip netns exec ns1 tcpdump -tnel -i ns1-veth0 icmp or arp
echo '----------- tcpdump ----------- '
cmd="ip netns exec ns1 ip neigh flush all" 
echo '> '$cmd
cmd="ip netns exec ns1 tcpdump -tnel -i ns1-veth0 icmp or arp" 
echo '> '$cmd
# 実行した結果を貼り付け
cat <<EOS
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on ns1-veth0, link-type EN10MB (Ethernet), capture size 262144 bytes
00:00:5e:00:53:01 > ff:ff:ff:ff:ff:ff, ethertype ARP (0x0806), length 42: Request who-has 192.0.2.2 tell 192.0.2.1, length 28
00:00:5e:00:53:02 > 00:00:5e:00:53:01, ethertype ARP (0x0806), length 42: Reply 192.0.2.2 is-at 00:00:5e:00:53:02, length 28
00:00:5e:00:53:01 > 00:00:5e:00:53:02, ethertype IPv4 (0x0800), length 98: 192.0.2.1 > 192.0.2.2: ICMP echo request, id 18258, seq 1, length 64
00:00:5e:00:53:02 > 00:00:5e:00:53:01, ethertype IPv4 (0x0800), length 98: 192.0.2.2 > 192.0.2.1: ICMP echo reply, id 18258, seq 1, length 64
00:00:5e:00:53:01 > 00:00:5e:00:53:02, ethertype IPv4 (0x0800), length 98: 192.0.2.1 > 192.0.2.2: ICMP echo request, id 18258, seq 2, length 64
00:00:5e:00:53:02 > 00:00:5e:00:53:01, ethertype IPv4 (0x0800), length 98: 192.0.2.2 > 192.0.2.1: ICMP echo reply, id 18258, seq 2, length 64
00:00:5e:00:53:01 > 00:00:5e:00:53:02, ethertype IPv4 (0x0800), length 98: 192.0.2.1 > 192.0.2.2: ICMP echo request, id 18258, seq 3, length 64
00:00:5e:00:53:02 > 00:00:5e:00:53:01, ethertype IPv4 (0x0800), length 98: 192.0.2.2 > 192.0.2.1: ICMP echo reply, id 18258, seq 3, length 64
00:00:5e:00:53:02 > 00:00:5e:00:53:01, ethertype ARP (0x0806), length 42: Request who-has 192.0.2.1 tell 192.0.2.2, length 28
00:00:5e:00:53:01 > 00:00:5e:00:53:02, ethertype ARP (0x0806), length 42: Reply 192.0.2.1 is-at 00:00:5e:00:53:01, length 28


ARPでMACアドレス確認の際に、宛先がff:ff:ff:ff:ff:ffとなっている
これはブロードキャストアドレスと呼ばれる特殊なMACアドレス
-> 同じセグメントに存在するホストにpingをうった結果だったため、
   パケットの詰替えは行われていない。
EOS


echo -e '\n' 
echo '----------- nstns delete ----------- '
# 1行毎にdelete実行
cmd="ip netns list | cut -d ' ' -f 1 | xargs -L 1 ip netns delete" 
echo '> '$cmd
eval ${cmd}
cmd="ip netns show" 
echo '> '$cmd
eval ${cmd}




echo -e '\n\n' 
echo '=========== arp 2  =========== '
# ++++++++++++++ arp 2 ++++++++++++++
# ns1 <---> router <---> ns2
# NetworkNamespaceを作成し、pingが通るまでを実施
echo '----------- init ----------- '
cmd="ip netns add ns1;\
ip netns add ns2;\
ip netns add router;"
echo '> '$cmd
eval ${cmd}

cmd="ip link add ns1-veth0 type veth peer name gw-veth0;\
ip link add ns2-veth0 type veth peer name gw-veth1"
echo '> '$cmd
eval ${cmd}

cmd="ip link set ns1-veth0 netns ns1;\
ip link set ns2-veth0 netns ns2;\
ip link set gw-veth0 netns router;\
ip link set gw-veth1 netns router;" 
echo '> '$cmd
eval ${cmd}

cmd="ip netns exec ns1 ip address add 192.0.2.1/24 dev ns1-veth0" 
echo '> '$cmd
eval ${cmd}
cmd="ip netns exec router ip address add 192.0.2.254/24 dev gw-veth0" 
echo '> '$cmd
eval ${cmd}
cmd="ip netns exec ns2 ip address add 198.51.100.1/24 dev ns2-veth0" 
echo '> '$cmd
eval ${cmd}
cmd="ip netns exec router ip address add 198.51.100.254/24 dev gw-veth1" 
echo '> '$cmd
eval ${cmd}

cmd="ip netns exec ns1 ip link set ns1-veth0 up;\
ip netns exec ns2 ip link set ns2-veth0 up;\
ip netns exec router ip link set gw-veth0 up;\
ip netns exec router ip link set gw-veth1 up;" 
echo '> '$cmd
eval ${cmd}

echo 'ns1 default route add'
cmd="ip netns exec ns1 ip route add default via 192.0.2.254" 
echo '> '$cmd
eval ${cmd}
echo 'ns2 default route add'
cmd="ip netns exec ns2 ip route add default via 198.51.100.254" 
echo '> '$cmd
eval ${cmd}



echo -e '\n' 
# MACアドレス指定
echo '----------- mac address setting ----------- '
cmd="ip netns exec ns1 ip link set dev ns1-veth0 address 00:00:5E:00:53:11;\
ip netns exec router ip link set dev gw-veth0 address 00:00:5E:00:53:12;\
ip netns exec router ip link set dev gw-veth1 address 00:00:5E:00:53:21;\
ip netns exec ns2 ip link set dev ns2-veth0 address 00:00:5E:00:53:22;" 
echo '> '$cmd
eval ${cmd}


echo -e '\n' 
# ping
echo '----------- ping ----------- '
cmd="ip netns exec ns1 ping -c 3 198.51.100.1" 
echo '> '$cmd
eval ${cmd}


echo -e '\n' 
# MACアドレスのキャッシュ確認
echo '----------- neigh ----------- '
cmd="ip netns exec ns1 ip neigh" 
echo '> '$cmd
eval ${cmd}


echo -e '\n' 
# TCPDUMP
# 別ターミナルでtcpdumpを行いながら、pingを実行
# 
# MACアドレスキャッシュクリア
# ip netns exec ns1 ip neigh flush all
# tcpdump
# ip netns exec ns1 tcpdump -tnel -i ns1-veth0 icmp or arp
echo '----------- tcpdump ----------- '
cmd="ip netns exec ns1 ip neigh flush all" 
echo '> '$cmd
cmd="ip netns exec router tcpdump -tnel -i gw-veth0 icmp or arp" 
echo '> '$cmd
# 実行した結果を貼り付け
cat <<EOS
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on gw-veth0, link-type EN10MB (Ethernet), capture size 262144 bytes
00:00:5e:00:53:11 > ff:ff:ff:ff:ff:ff, ethertype ARP (0x0806), length 42: Request who-has 192.0.2.254 tell 192.0.2.1, length 28
00:00:5e:00:53:12 > 00:00:5e:00:53:11, ethertype ARP (0x0806), length 42: Reply 192.0.2.254 is-at 00:00:5e:00:53:12, length 28
00:00:5e:00:53:11 > 00:00:5e:00:53:12, ethertype IPv4 (0x0800), length 98: 192.0.2.1 > 198.51.100.1: ICMP echo request, id 24823, seq 1, length 64
00:00:5e:00:53:12 > 00:00:5e:00:53:11, ethertype IPv4 (0x0800), length 98: 198.51.100.1 > 192.0.2.1: ICMP echo reply, id 24823, seq 1, length 64
00:00:5e:00:53:11 > 00:00:5e:00:53:12, ethertype IPv4 (0x0800), length 98: 192.0.2.1 > 198.51.100.1: ICMP echo request, id 24823, seq 2, length 64
00:00:5e:00:53:12 > 00:00:5e:00:53:11, ethertype IPv4 (0x0800), length 98: 198.51.100.1 > 192.0.2.1: ICMP echo reply, id 24823, seq 2, length 64
00:00:5e:00:53:11 > 00:00:5e:00:53:12, ethertype IPv4 (0x0800), length 98: 192.0.2.1 > 198.51.100.1: ICMP echo request, id 24823, seq 3, length 64
00:00:5e:00:53:12 > 00:00:5e:00:53:11, ethertype IPv4 (0x0800), length 98: 198.51.100.1 > 192.0.2.1: ICMP echo reply, id 24823, seq 3, length 64
00:00:5e:00:53:12 > 00:00:5e:00:53:11, ethertype ARP (0x0806), length 42: Request who-has 192.0.2.1 tell 192.0.2.254, length 28
00:00:5e:00:53:11 > 00:00:5e:00:53:12, ethertype ARP (0x0806), length 42: Reply 192.0.2.1 is-at 00:00:5e:00:53:11, length 28

ns1のルーティングテーブル上、異なるセグメントへのアクセスのため、default定義に従い192.0.2.254へ送信する。
ここでMACアドレスがわからないので、ARPにより確認 --> 00:00:5e:00:53:12だとわかる

EOS

cmd="ip netns exec router tcpdump -tnel -i gw-veth2 icmp or arp" 
echo '> '$cmd
cat <<EOS
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on gw-veth1, link-type EN10MB (Ethernet), capture size 262144 bytes
00:00:5e:00:53:21 > ff:ff:ff:ff:ff:ff, ethertype ARP (0x0806), length 42: Request who-has 198.51.100.1 tell 198.51.100.254, length 28
00:00:5e:00:53:22 > 00:00:5e:00:53:21, ethertype ARP (0x0806), length 42: Reply 198.51.100.1 is-at 00:00:5e:00:53:22, length 28
00:00:5e:00:53:21 > 00:00:5e:00:53:22, ethertype IPv4 (0x0800), length 98: 192.0.2.1 > 198.51.100.1: ICMP echo request, id 24823, seq 1, length 64
00:00:5e:00:53:22 > 00:00:5e:00:53:21, ethertype IPv4 (0x0800), length 98: 198.51.100.1 > 192.0.2.1: ICMP echo reply, id 24823, seq 1, length 64
00:00:5e:00:53:21 > 00:00:5e:00:53:22, ethertype IPv4 (0x0800), length 98: 192.0.2.1 > 198.51.100.1: ICMP echo request, id 24823, seq 2, length 64
00:00:5e:00:53:22 > 00:00:5e:00:53:21, ethertype IPv4 (0x0800), length 98: 198.51.100.1 > 192.0.2.1: ICMP echo reply, id 24823, seq 2, length 64
00:00:5e:00:53:21 > 00:00:5e:00:53:22, ethertype IPv4 (0x0800), length 98: 192.0.2.1 > 198.51.100.1: ICMP echo request, id 24823, seq 3, length 64
00:00:5e:00:53:22 > 00:00:5e:00:53:21, ethertype IPv4 (0x0800), length 98: 198.51.100.1 > 192.0.2.1: ICMP echo reply, id 24823, seq 3, length 64
00:00:5e:00:53:22 > 00:00:5e:00:53:21, ethertype ARP (0x0806), length 42: Request who-has 198.51.100.254 tell 198.51.100.1, length 28
00:00:5e:00:53:21 > 00:00:5e:00:53:22, ethertype ARP (0x0806), length 42: Reply 198.51.100.254 is-at 00:00:5e:00:53:21, length 28

次に
routerもルーティングテーブルから利用するネットワークインターフェースを特定する。
それが決まれば、そこからARPによりMACアドレスを確認 --> 00:00:5e:00:53:22だとわかる
EOS


echo -e '\n' 
echo '----------- nstns delete ----------- '
# 1行毎にdelete実行
cmd="ip netns list | cut -d ' ' -f 1 | xargs -L 1 ip netns delete" 
echo '> '$cmd
eval ${cmd}
cmd="ip netns show" 
echo '> '$cmd
eval ${cmd}




