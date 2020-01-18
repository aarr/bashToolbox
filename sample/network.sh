#!/bin/bash
# 
# ========================================================
# 引数なし
# ネットワーク系コマンドサンプル
# ========================================================
# ++++++++++++++ traceroute ++++++++++++++
# TTLを1から開始し、0になったらICMP時間釣果エラーとする
# その場合、TTLを1加算して再度実行する。これを繰り返すことで
# 経由するルータを1つづつ特定していく。
# 対象に到達した際にはICMPエコー応答メッセージ（タイプ0）が返されるので到達した事を認識できる。
# これは行きの経路の確認。帰りの経路を確認する場合は、--backオプションの指定が必要
# 通常UDP（-U : PORT 53）を利用するが、その場合利用されるポートが定まらないため想定どおりの挙動とならない事がある。
# その場合、-T（TCP SYN : PORT 80）オプションか、-I（ICMPエコー要求メッセージ）を利用する
echo '=========== traceroute =========== '
echo '> traceroute -T yahoo.co.jp'
traceroute -T yahoo.co.jp


echo -e '\n\n' 
# ++++++++++++++ nslookup ++++++++++++++
# 対話形式で利用が可能
# 対話形式で実行時オプションを変更するのはsetコマンドを利用する
# 
# Non-authoritative anser:
# 権威サーバ以外のキャッシュサーバから情報を取得した場合に表示される
# dig, whoisなどで権威サーバを特定し、そこから情報を取得すると表示されなくなる
# 
# xxx canonical name = yyy
# CNAME登録がある場合（同じIPに対して別名称が登録されている）に表示される
echo '=========== nslookup =========== '
echo '> nslookup www.yahoo.co.jp'
nslookup www.yahoo.co.jp


echo -e '\n\n' 
# ++++++++++++++ dig ++++++++++++++
# nslookupと同様だが、さらに詳細情報を取得できる。
# NAMEサーバに登録されている内容比較的そのまま表示する
# 同様のコマンドでhostが存在する。digをシンプルにしたものがhost。
echo '=========== dig =========== '
echo ' レコード種類'
echo ' SOA   : ゾーン（ドメイン）情報'
echo ' NS    : ドメインのDNSサーバ'
echo ' A     : ホスト名に対するIPアドレス'
echo ' PTR   : IPアドレスに対するホスト名'
echo ' CNAME : ホスト名のエイリアス（別名）'
echo ' MX    : ドメインのメールサーバ'
echo ' TXT   : テキスト情報を表示'
echo '> dig google.com   # レコードタイプ指定なしはAレコードを取得'
dig google.com

echo -e '\n\n' 
# レコードタイプを指定して検索も可能
echo '> dig google.com ns   # NSレコード指定'
dig google.com ns

echo -e '\n\n' 
# 全レコード取得
echo '> dig google.com any   # 全レコード取得'
dig google.com any

echo -e '\n\n' 
# DNSサーバ指定
echo '> dig @ns1.google.com. google.com any   # DNS指定'
dig @ns1.google.com. google.com any

echo -e '\n\n' 
# rootサーバからの検索
echo '> dig +trace google.com any   # rootサーバから検索'
dig +trace google.com


echo -e '\n\n' 
# ++++++++++++++ host ++++++++++++++
# digコマンドの簡略版
# IP一覧などを取得する際にdigよりも利用しやすい
echo '=========== host =========== '
echo '> host -t a yahoo.co.jp   # レコードタイプを指定して実行'
host -t a yahoo.co.jp

echo -e '\n\n' 
echo '> host -t a yahoo.co.jp | cut -d " " -f 4   # 対象サーバのIP一覧を取得'
host -t a yahoo.co.jp | cut -d " " -f 4


echo -e '\n\n' 
# ++++++++++++++ whois ++++++++++++++
# 登録されているサーバ情報を確認する
# ドメイン名、組織名、住所、組織種別、登録担当者情報、技術連絡担当者情報、ネームサーバ情報などが確認可能
echo '=========== whois =========== '
echo '> whois yahoo.co.jp'
whois yahoo.co.jp


echo -e '\n\n' 
# ++++++++++++++ nmap ++++++++++++++
# ポートスキャン機能
# オプションの種類が非常に多い
# ・ホスト発見
# ・スキャンタイプ
# ・ポート指定と順序
# ・サービスとバージョン検出
# ・OS検出
# ・タイミング、パフォーマンス
# ・FW、IDSの回避
# ・出力
# ・ターゲット指定
echo '=========== nmap =========== '
echo '--- ホスト発見 --- '
echo ' -sL   : リストスキャン。DNSの情報を利用'
echo ' -sP   : Pingスイープ。ICMPエコー要求、80ポートTCPパケット'
echo ' -PS   : TCP SYN Ping'
echo ' -PA   : TPC ACK ping'
echo ' -PU   : UDP Ping'
echo ' -Pn   : ホスト発見オプションはスキップ'
echo '> nmap -sP google.com'
nmap -sP google.com

echo -e '\n\n' 
echo '--- スキャンタイプ --- '
echo ' -sS   : TCP SYNスキャン。最もよく利用される。FWの妨害もない。TPCコネクション確率なし。匿名性が高い'
echo ' -sT   : TCP connect()スキャン。コネクション確率要求。相手側のログ（/var/log/secure）に残る可能性大'
echo ' -sU   : UDPスキャン。TCPより時間は掛かる。'
echo ' -sN,sF,sX   : TCPコントロールフラグのうち３つ（SYN, RST, ACK）の値を特定の状態にしてスキャン'
echo ' -sA   : TCP ACKスキャン。ポートのopen状態をスキャン判別しない。FWのルール、statefull、ポートfillteringを調査'
echo '> nmap -sS google.com'
nmap -sS google.com

