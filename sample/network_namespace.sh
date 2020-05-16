#!/bin/bash
# 
# ========================================================
# 引数なし
# NetworkNamespaceサンプル
# ========================================================
# ++++++++++++++ 基本 IPコマンド ++++++++++++++
# ipアドレス表示
echo '=========== ip =========== '
# ++++++++++++++ address show ++++++++++++++
# loはループバックアドレス用の仮想的なネットワークインターフェース
cmd="ip address show"
echo '> '$cmd
eval ${cmd}

echo -e '\n\n' 
# ++++++++++++++ route show ++++++++++++++
# ルーティングテーブル表示
# defaultはその他のどの定義にも当てはまらない場合に適応されるルーティング
# 先頭は宛先、その後に続くのがネクストホップ（パケットを次に渡す相手）
cmd="ip route show"
echo '> '$cmd
eval ${cmd}


echo -e '\n\n' 
# ++++++++++++++ netns add ++++++++++++++
# NetworkNamespace追加
echo '=========== netns =========== '
# helloworldというNetworkNamespaceを作成する
cmd="ip netns add helloworld"
echo '> '$cmd
eval ${cmd}
# NetworkNamespaceの一覧表示
cmd="ip netns list"
echo '> '$cmd
eval ${cmd}

echo -e '\n' 
# ++++++++++++++ netns exec ++++++++++++++
# NetworkNamespaceの情報表示
# NetworkNamespaceの環境でシェルの起動
# シェルから抜けるまで、NetworkNamespace上でシェルの実行が可能
# ip netns exec NetworkNamespace bash
cmd="ip netns exec helloworld ip address show"
echo '> '$cmd
eval ${cmd}
cmd="ip netns exec helloworld ip route show"
echo '> '$cmd
eval ${cmd}


echo -e '\n' 
# ++++++++++++++ netns delete ++++++++++++++
# NetworkNamespaceの削除
cmd="ip netns delete helloworld"
echo '> '$cmd
eval ${cmd}




echo -e '\n\n' 
cat <<EOS
# +++++++++++++++++++++++++++++++++++++++++++++
# ++++++++++++++ routing ns to ns +++++++++++++
# +++++++++++++++++++++++++++++++++++++++++++++
    ns1             ns2
     |               |
 ns1-veth0 <---> ns2-veth0
 192.0.2.1       192.0.2.2
EOS
# NetworkNamespace同士を接続させる
echo '=========== routing ns to ns =========== '
echo '----------- netns add ----------- '
# NetworkNamespace作成
cmd="ip netns add ns1;\
ip netns add ns2;"
echo '> '$cmd
eval ${cmd}
# 作成したNetworkNamespaceを表示
cmd="ip netns show"
echo '> '$cmd
eval ${cmd}


echo -e '\n' 
# ++++++++++++++ link add ++++++++++++++
# ネットワークインターフェース作成
# veth(Virtual Ethernet Device)という仮想的なネットワークインターフェース
# を作成する
echo '----------- link add ----------- '
cmd="ip link add ns1-veth0 type veth peer name ns2-veth0"
echo '> '$cmd
eval ${cmd}
# 作成したネットワークインターフェースを確認
cmd="ip link show | grep veth"
echo '> '$cmd
eval ${cmd}


echo -e '\n' 
# ++++++++++++++ link set ++++++++++++++
# ネットワークインターフェースとNetrowkNamespaceをリンク
# 仮想的にLANケーブルで繋がった状態
echo '----------- link set ----------- '
cmd="ip link set ns1-veth0 netns ns1;\
ip link set ns2-veth0 netns ns2;" 
echo '> '$cmd
eval ${cmd}
# 各NetworkNamespaceでリンク状態を確認
cmd="ip netns exec ns1 ip link show | grep veth" 
echo '> '$cmd
eval ${cmd}
cmd="ip netns exec ns2 ip link show | grep veth" 
echo '> '$cmd
eval ${cmd}


echo -e '\n' 
# ++++++++++++++ address add ++++++++++++++
# ネットワークインターフェースにIPを設定
echo '----------- address add ----------- '
cmd="ip netns exec ns1 ip address add 192.0.2.1/24 dev ns1-veth0" 
echo '> '$cmd
eval ${cmd}
cmd="ip netns exec ns2 ip address add 192.0.2.2/24 dev ns2-veth0" 
echo '> '$cmd
eval ${cmd}
# IPアドレス確認
cmd="ip netns exec ns1 ip address show | grep veth" 
echo '> '$cmd
eval ${cmd}
cmd="ip netns exec ns2 ip address show | grep veth" 
echo '> '$cmd
eval ${cmd}


echo -e '\n' 
# ++++++++++++++ link set up ++++++++++++++
# ネットワークインターフェースを有効化
# デフォルト設定でstateがDOWNになっている
echo '----------- link set up ----------- '
cmd="ip netns exec ns1 ip link set ns1-veth0 up;\
ip netns exec ns2 ip link set ns2-veth0 up;" 
echo '> '$cmd
eval ${cmd}
# ネットワークインターフェースの状態確認
# stateがUPになっていることを確認
cmd="ip netns exec ns1 ip address show | grep veth" 
echo '> '$cmd
eval ${cmd}
cmd="ip netns exec ns2 ip address show | grep veth" 
echo '> '$cmd
eval ${cmd}


echo -e '\n' 
# ++++++++++++++ ping ++++++++++++++
# 疎通確認
# ns1 -> ns2 へping
echo '----------- ping ----------- '
cmd="ip netns exec ns1 ping -c 3 192.0.2.2" 
echo '> '$cmd
eval ${cmd}


echo -e '\n' 
# ++++++++++++++ 初期化 ++++++++++++++
# NetworkNamespaceを削除
echo '----------- nstns delete ----------- '
# 1行毎にdelete実行
cmd="ip netns list | cut -d ' ' -f 1 | xargs -L 1 ip netns delete" 
echo '> '$cmd
eval ${cmd}
cmd="ip netns show" 
echo '> '$cmd
eval ${cmd}




echo -e '\n\n' 
cat <<EOS
# ++++++++++++++++++++++++++++++++++++++++++++++++++
# ++++++++++++++ routing ns router ns ++++++++++++++
# ++++++++++++++++++++++++++++++++++++++++++++++++++

 ns1              router            ns2
  |                  |               |
 ns1-veth0 <---> gw-veth0            |
 192.0.2.1       192.0.2.254         |
                     |               |
                 gw-veth1 <----> ns2-veth0
                 198.51.100.254  198.51.100.1
EOS
# NetworkNamespace同士を接続させる
echo '=========== routing ns router ns =========== '
echo '----------- netns add ----------- '
# NetworkNamespace作成
cmd="ip netns add ns1;\
ip netns add ns2;\
ip netns add router;"
echo '> '$cmd
eval ${cmd}
# 作成したNetworkNamespaceを表示
cmd="ip netns show"
echo '> '$cmd
eval ${cmd}


echo -e '\n' 
# ++++++++++++++ link add ++++++++++++++
# ネットワークインターフェース作成
# veth(Virtual Ethernet Device)という仮想的なネットワークインターフェース
# を作成する
echo '----------- link add ----------- '
cmd="ip link add ns1-veth0 type veth peer name gw-veth0;\
ip link add ns2-veth0 type veth peer name gw-veth1"
echo '> '$cmd
eval ${cmd}
# 作成したネットワークインターフェースを確認
cmd="ip link show | grep veth"
echo '> '$cmd
eval ${cmd}


echo -e '\n' 
# ++++++++++++++ link set ++++++++++++++
# ネットワークインターフェースとNetrowkNamespaceをリンク
# 仮想的にLANケーブルで繋がった状態
# routerはネットワークインターフェースが２つ
echo '----------- link set ----------- '
cmd="ip link set ns1-veth0 netns ns1;\
ip link set ns2-veth0 netns ns2;\
ip link set gw-veth0 netns router;\
ip link set gw-veth1 netns router;" 
echo '> '$cmd
eval ${cmd}
# 各NetworkNamespaceでリンク状態を確認
cmd="ip netns exec ns1 ip link show | grep veth" 
echo '> '$cmd
eval ${cmd}
cmd="ip netns exec ns2 ip link show | grep veth" 
echo '> '$cmd
eval ${cmd}
cmd="ip netns exec router ip link show | grep veth" 
echo '> '$cmd
eval ${cmd}


echo -e '\n' 
# ++++++++++++++ address add ++++++++++++++
# ネットワークインターフェースにIPを設定
echo '----------- address add ----------- '
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

# IPアドレス確認
cmd="ip netns exec ns1 ip address show | grep veth" 
echo '> '$cmd
eval ${cmd}
cmd="ip netns exec ns2 ip address show | grep veth" 
echo '> '$cmd
eval ${cmd}
cmd="ip netns exec router ip address show | grep veth" 
echo '> '$cmd
eval ${cmd}


echo -e '\n' 
# ++++++++++++++ link set up ++++++++++++++
# ネットワークインターフェースを有効化
# デフォルト設定でstateがDOWNになっている
echo '----------- link set up ----------- '
cmd="ip netns exec ns1 ip link set ns1-veth0 up;\
ip netns exec ns2 ip link set ns2-veth0 up;\
ip netns exec router ip link set gw-veth0 up;\
ip netns exec router ip link set gw-veth1 up;" 
echo '> '$cmd
eval ${cmd}
# ネットワークインターフェースの状態確認
# stateがUPになっていることを確認
cmd="ip netns exec ns1 ip address show | grep veth" 
echo '> '$cmd
eval ${cmd}
cmd="ip netns exec ns2 ip address show | grep veth" 
echo '> '$cmd
eval ${cmd}
cmd="ip netns exec router ip address show | grep veth" 
echo '> '$cmd
eval ${cmd}


echo -e '\n' 
# ++++++++++++++ ping to router++++++++++++++
# routerまでの疎通確認
echo '----------- ping to router----------- '
# ns1 --> router
echo 'ns1 --> router'
cmd="ip netns exec ns1 ping -c 3 192.0.2.254" 
echo '> '$cmd
eval ${cmd}

# ns2 --> router
echo 'ns2 --> router'
cmd="ip netns exec ns2 ping -c 3 198.51.100.254" 
echo '> '$cmd
eval ${cmd}


echo -e '\n' 
# ++++++++++++++ routing add ++++++++++++++
# ルーティングテーブル追加
echo '----------- default route add ----------- '
# 既存route確認
echo 'route show'
cmd="ip netns exec ns1 ip route show" 
echo '> '$cmd
eval ${cmd}

cmd="ip netns exec ns2 ip route show" 
echo '> '$cmd
eval ${cmd}

# default route追加
echo 'ns1 default route add'
cmd="ip netns exec ns1 ip route add default via 192.0.2.254" 
echo '> '$cmd
eval ${cmd}

echo 'ns2 default route add'
cmd="ip netns exec ns2 ip route add default via 198.51.100.254" 
echo '> '$cmd
eval ${cmd}


echo -e '\n' 
# ++++++++++++++ ping ++++++++++++++
# 疎通確認
# 100% packet lossとなる場合、ルータとしての機能がOFFになっているので設定変更
# ip netns exec router sysctl net.ipv4.ip_forward=1
# net.ipv4.ip_forward=0の場合、エラーとなる
echo '----------- ping ----------- '
# ns1 --> ns2
echo 'ns1 --> ns2'
cmd="ip netns exec ns1 ping -c 3 198.51.100.1" 
echo '> '$cmd
eval ${cmd}


echo -e '\n' 
# ++++++++++++++ 初期化 ++++++++++++++
# NetworkNamespaceを削除
echo '----------- nstns delete ----------- '
# 1行毎にdelete実行
cmd="ip netns list | cut -d ' ' -f 1 | xargs -L 1 ip netns delete" 
echo '> '$cmd
eval ${cmd}
cmd="ip netns show" 
echo '> '$cmd
eval ${cmd}




echo -e '\n\n' 
cat <<EOS
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# ++++++++++++++ routing ns router router ns ++++++++++++++
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 ns1              router1          router2             ns2
  |                  |                |                 |
 ns1-veth0 <---> gw1-veth0            |                 |
 192.0.2.1       192.0.2.254          |                 |
                     |                |                 |
                gw1-veth1 <----> gw2-veth0             |
                 203.0.113.1      203.0.113.2           |
                                      |                 |
                                  gw2-veth1 <----> ns2-veth0
                                  198.51.100.254   198.51.100.1

EOS
# NetworkNamespace同士を接続させる
echo '=========== routing ns router router ns =========== '
echo '----------- netns add ----------- '
# NetworkNamespace作成
cmd="ip netns add ns1;\
ip netns add ns2;\
ip netns add router1;\
ip netns add router2;"
echo '> '$cmd
eval ${cmd}
# 作成したNetworkNamespaceを表示
cmd="ip netns show"
echo '> '$cmd
eval ${cmd}


echo -e '\n' 
# ++++++++++++++ link add ++++++++++++++
# ネットワークインターフェース作成
# veth(Virtual Ethernet Device)という仮想的なネットワークインターフェース
# を作成する
echo '----------- link add ----------- '
cmd="ip link add ns1-veth0 type veth peer name gw1-veth0;\
ip link add gw1-veth1 type veth peer name gw2-veth0;\
ip link add gw2-veth1 type veth peer name ns2-veth0"
echo '> '$cmd
eval ${cmd}
# 作成したネットワークインターフェースを確認
cmd="ip link show | grep veth"
echo '> '$cmd
eval ${cmd}


echo -e '\n' 
# ++++++++++++++ link set ++++++++++++++
# ネットワークインターフェースとNetrowkNamespaceをリンク
# 仮想的にLANケーブルで繋がった状態
# routerはネットワークインターフェースが２つ
echo '----------- link set ----------- '
cmd="ip link set ns1-veth0 netns ns1;\
ip link set ns2-veth0 netns ns2;\
ip link set gw1-veth0 netns router1;\
ip link set gw1-veth1 netns router1;\
ip link set gw2-veth0 netns router2;\
ip link set gw2-veth1 netns router2;"
echo '> '$cmd
eval ${cmd}
# 各NetworkNamespaceでリンク状態を確認
cmd="ip netns exec ns1 ip link show | grep veth" 
echo '> '$cmd
eval ${cmd}
cmd="ip netns exec ns2 ip link show | grep veth" 
echo '> '$cmd
eval ${cmd}
cmd="ip netns exec router1 ip link show | grep veth" 
echo '> '$cmd
eval ${cmd}
cmd="ip netns exec router2 ip link show | grep veth" 
echo '> '$cmd
eval ${cmd}


echo -e '\n' 
# ++++++++++++++ address add ++++++++++++++
# ネットワークインターフェースにIPを設定
echo '----------- address add ----------- '
cmd="ip netns exec ns1 ip address add 192.0.2.1/24 dev ns1-veth0" 
echo '> '$cmd
eval ${cmd}

cmd="ip netns exec router1 ip address add 192.0.2.254/24 dev gw1-veth0" 
echo '> '$cmd
eval ${cmd}
cmd="ip netns exec router1 ip address add 203.0.113.1/24 dev gw1-veth1" 
echo '> '$cmd
eval ${cmd}

cmd="ip netns exec router2 ip address add 203.0.113.2/24 dev gw2-veth0" 
echo '> '$cmd
eval ${cmd}
cmd="ip netns exec router2 ip address add 198.51.100.254/24 dev gw2-veth1" 
echo '> '$cmd
eval ${cmd}

cmd="ip netns exec ns2 ip address add 198.51.100.1/24 dev ns2-veth0" 
echo '> '$cmd
eval ${cmd}

# IPアドレス確認
cmd="ip netns exec ns1 ip address show | grep veth" 
echo '> '$cmd
eval ${cmd}
cmd="ip netns exec ns2 ip address show | grep veth" 
echo '> '$cmd
eval ${cmd}
cmd="ip netns exec router1 ip address show | grep veth" 
echo '> '$cmd
eval ${cmd}
cmd="ip netns exec router2 ip address show | grep veth" 
echo '> '$cmd
eval ${cmd}


echo -e '\n' 
# ++++++++++++++ link set up ++++++++++++++
# ネットワークインターフェースを有効化
# デフォルト設定でstateがDOWNになっている
echo '----------- link set up ----------- '
cmd="ip netns exec ns1 ip link set ns1-veth0 up;\
ip netns exec ns2 ip link set ns2-veth0 up;\
ip netns exec router1 ip link set gw1-veth0 up;\
ip netns exec router1 ip link set gw1-veth1 up;\
ip netns exec router2 ip link set gw2-veth0 up;\
ip netns exec router2 ip link set gw2-veth1 up;"
echo '> '$cmd
eval ${cmd}
# ネットワークインターフェースの状態確認
# stateがUPになっていることを確認
cmd="ip netns exec ns1 ip address show | grep veth" 
echo '> '$cmd
eval ${cmd}
cmd="ip netns exec ns2 ip address show | grep veth" 
echo '> '$cmd
eval ${cmd}
cmd="ip netns exec router1 ip address show | grep veth" 
echo '> '$cmd
eval ${cmd}
cmd="ip netns exec router2 ip address show | grep veth" 
echo '> '$cmd
eval ${cmd}


echo -e '\n' 
# ++++++++++++++ routing add ++++++++++++++
# ルーティングテーブル追加
echo '----------- route add ----------- '
# default route追加
echo 'ns1 default route add'
cmd="ip netns exec ns1 ip route add default via 192.0.2.254" 
echo '> '$cmd
eval ${cmd}

echo 'ns2 default route add'
cmd="ip netns exec ns2 ip route add default via 198.51.100.254" 
echo '> '$cmd
eval ${cmd}

# router既存route確認
echo 'route show'
cmd="ip netns exec router1 ip route show" 
echo '> '$cmd
eval ${cmd}

cmd="ip netns exec router2 ip route show" 
echo '> '$cmd
eval ${cmd}

# routerにroutingを追加
# 今回はサブネット指定でルーティングを追加しているが、他のネットワークが
# なければdefault定義を追加でも問題ない
echo 'router1 route add'
cmd="ip netns exec router1 ip route add 198.51.100.0/24 via 203.0.113.2" 
echo '> '$cmd
eval ${cmd}

echo 'router2 route add'
cmd="ip netns exec router2 ip route add 192.0.2.0/24 via 203.0.113.1" 
echo '> '$cmd
eval ${cmd}


echo -e '\n' 
# ++++++++++++++ ping ++++++++++++++
# 疎通確認
# 100% packet lossとなる場合、ルータとしての機能がOFFになっているので設定変更
# ip netns exec router sysctl net.ipv4.ip_forward=1
# net.ipv4.ip_forward=0の場合、エラーとなる
echo '----------- ping ----------- '
# ns1 --> ns2
echo 'ns1 --> ns2'
cmd="ip netns exec ns1 ping -c 3 198.51.100.1" 
echo '> '$cmd
eval ${cmd}


echo -e '\n' 
# ++++++++++++++ 初期化 ++++++++++++++
# NetworkNamespaceを削除
echo '----------- nstns delete ----------- '
# 1行毎にdelete実行
cmd="ip netns list | cut -d ' ' -f 1 | xargs -L 1 ip netns delete" 
echo '> '$cmd
eval ${cmd}
cmd="ip netns show" 
echo '> '$cmd
eval ${cmd}




echo -e '\n\n' 
cat <<EOS
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# ++++++++++++++++++ routing with bridge ++++++++++++++++++
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                      bridge
                         |
     ----------------------------------------
     |                   |                   |
 ns01-br0 <----      ns02-br0 <----       ns03-br0 <----
              |                   |                     |
              |                   |                     |
    ns1       |         ns2       |          ns3        |
     |        |          |        |           |         |
 ns1-veth0 <---      ns2-veth0 <---       ns3-veth0 <---
 192.0.2.1           192.0.2.2           192.0.2.3
 00:00:5E:00:53:01   00:00:5E:00:53:02   00:00:5E:00:53:03
EOS
#
echo '=========== routing with bridge =========== '
echo '----------- netns add ----------- '
# NetworkNamespace作成
cmd="ip netns add ns1;\
ip netns add ns2;\
ip netns add ns3;"
echo '> '$cmd
eval ${cmd}
# 作成したNetworkNamespaceを表示
cmd="ip netns show"
echo '> '$cmd
eval ${cmd}


echo -e '\n' 
# ++++++++++++++ link add ++++++++++++++
# ネットワークインターフェース／ブリッジ作成
# veth(Virtual Ethernet Device)、bridgeという仮想的な
# ネットワークインターフェースを作成する
echo '----------- link add ----------- '
cmd="ip link add ns1-veth0 type veth peer name ns1-br0;\
ip link add ns2-veth0 type veth peer name ns2-br0;\
ip link add ns3-veth0 type veth peer name ns3-br0"
echo '> '$cmd
eval ${cmd}
# 作成したネットワークインターフェースを確認
cmd="ip link show | grep veth"
echo '> '$cmd
eval ${cmd}


echo -e '\n' 
# ++++++++++++++ link set ++++++++++++++
# ネットワークインターフェースとNetrowkNamespaceをリンク
# 仮想的にLANケーブルで繋がった状態
echo '----------- link set ----------- '
cmd="ip link set ns1-veth0 netns ns1;\
ip link set ns2-veth0 netns ns2;\
ip link set ns3-veth0 netns ns3;" 
echo '> '$cmd
eval ${cmd}
# 各NetworkNamespaceでリンク状態を確認
cmd="ip netns exec ns1 ip link show | grep veth" 
echo '> '$cmd
eval ${cmd}
cmd="ip netns exec ns2 ip link show | grep veth" 
echo '> '$cmd
eval ${cmd}
cmd="ip netns exec ns3 ip link show | grep veth" 
echo '> '$cmd
eval ${cmd}


echo -e '\n' 
# ++++++++++++++ ip address add ++++++++++++++
# ネットワークインターフェースにIPを設定
echo '----------- address add ----------- '
cmd="ip netns exec ns1 ip address add 192.0.2.1/24 dev ns1-veth0;\
ip netns exec ns2 ip address add 192.0.2.2/24 dev ns2-veth0;\
ip netns exec ns3 ip address add 192.0.2.3/24 dev ns3-veth0;" 
echo '> '$cmd
eval ${cmd}

# ++++++++++++++ mac address add ++++++++++++++
# ネットワークインターフェースにMACアドレスを設定
echo '----------- mac address setting ----------- '
cmd="ip netns exec ns1 ip link set dev ns1-veth0 address 00:00:5E:00:53:01;\
ip netns exec ns2 ip link set dev ns2-veth0 address 00:00:5E:00:53:02;\
ip netns exec ns3 ip link set dev ns3-veth0 address 00:00:5E:00:53:03;" 
echo '> '$cmd
eval ${cmd}

# IP/MACアドレス確認
cmd="ip netns exec ns1 ip address show | grep -e veth -e link/ether" 
echo '> '$cmd
eval ${cmd}
cmd="ip netns exec ns2 ip address show | grep -e veth -e link/ether" 
echo '> '$cmd
eval ${cmd}
cmd="ip netns exec ns3 ip address show | grep -e veth -e link/ether" 
echo '> '$cmd
eval ${cmd}


echo -e '\n' 
# ++++++++++++++ link set up ++++++++++++++
# ネットワークインターフェースを有効化
# デフォルト設定でstateがDOWNになっている
echo '----------- link set up ----------- '
cmd="ip netns exec ns1 ip link set ns1-veth0 up;\
ip netns exec ns2 ip link set ns2-veth0 up;\
ip netns exec ns3 ip link set ns3-veth0 up;" 
echo '> '$cmd
eval ${cmd}

# ネットワークインターフェースの状態確認
# stateがUPになっていることを確認
cmd="ip netns exec ns1 ip address show | grep veth" 
echo '> '$cmd
eval ${cmd}
cmd="ip netns exec ns2 ip address show | grep veth" 
echo '> '$cmd
eval ${cmd}
cmd="ip netns exec ns3 ip address show | grep veth" 
echo '> '$cmd
eval ${cmd}


echo -e '\n' 
# ++++++++++++++ link add ++++++++++++++
# ネットワークインターフェースを有効化
# デフォルト設定でstateがDOWNになっている
echo '----------- link add (bridge) ----------- '
cmd="ip link add dev br0 type bridge"
echo '> '$cmd
eval ${cmd}
# ブリッジインターフェースの状態確認
cmd="ip link show | grep br0" 
echo '> '$cmd
eval ${cmd}


echo -e '\n' 
# ++++++++++++++ link set up ++++++++++++++
# ブリッジのネットワークインターフェースを有効化
# デフォルト設定でstateがDOWNになっている
echo '----------- bridge set up ----------- '
cmd="ip link set br0 up" 
echo '> '$cmd
eval ${cmd}
# ブリッジインターフェースの状態確認
# stateがUPになっていることを確認
cmd="ip address show | grep br0:" 
echo '> '$cmd
eval ${cmd}


echo -e '\n' 
# ++++++++++++++ link set ++++++++++++++
# bridgeにネットワークインターフェースの設定
echo '----------- link set (bridge) ----------- '
cmd="ip link set dev ns1-br0 master br0;\
ip link set dev ns2-br0 master br0;\
ip link set dev ns3-br0 master br0; " 
echo '> '$cmd
eval ${cmd}
echo '----------- link set up (bridge) ----------- '
cmd="ip link set ns1-br0 up;\
ip link set ns2-br0 up;\
ip link set ns3-br0 up; " 
echo '> '$cmd
eval ${cmd}
# ブリッジインターフェースの状態確認
cmd="ip link show | grep ns.-br0" 
echo '> '$cmd
eval ${cmd}


echo -e '\n' 
# ++++++++++++++ ping ++++++++++++++
# 疎通確認
echo '----------- ping (ns1 -> ns2) ----------- '
cmd="ip netns exec ns1 ping -c 1 192.0.2.2" 
echo '> '$cmd
eval ${cmd}
echo '----------- ping (ns1 -> ns3) ----------- '
cmd="ip netns exec ns1 ping -c 1 192.0.2.3" 
echo '> '$cmd
eval ${cmd}
echo '----------- ping (ns2 -> ns1) ----------- '
cmd="ip netns exec ns2 ping -c 1 192.0.2.1" 
echo '> '$cmd
eval ${cmd}
echo '----------- ping (ns2 -> ns1) ----------- '
cmd="ip netns exec ns2 ping -c 1 192.0.2.3" 
echo '> '$cmd
eval ${cmd}
echo '----------- ping (ns3 -> ns1) ----------- '
cmd="ip netns exec ns3 ping -c 1 192.0.2.1" 
echo '> '$cmd
eval ${cmd}
echo '----------- ping (ns3 -> ns2) ----------- '
cmd="ip netns exec ns3 ping -c 1 192.0.2.2" 
echo '> '$cmd
eval ${cmd}





echo -e '\n' 
# ++++++++++++++ 初期化 ++++++++++++++
# NetworkNamespaceを削除
echo '----------- nstns delete ----------- '
# 1行毎にdelete実行
cmd="ip netns list | cut -d ' ' -f 1 | xargs -L 1 ip netns delete" 
echo '> '$cmd
#eval ${cmd}
cmd="ip netns show" 
echo '> '$cmd
eval ${cmd}


