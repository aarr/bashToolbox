#!/bin/bash
# 
# ========================================================
# 引数なし
# トランスポート層のサンプル
# ========================================================
echo -e '\n\n' 
cat <<EOS
# +++++++++++++++++++++++++++++++++
# ++++++++++++++ UDP ++++++++++++++
# +++++++++++++++++++++++++++++++++
EOS
# ++++++++++++++ server&client start ++++++++++++++
echo '============= nc ============= '
echo '----------- server start ----------- '
cmd="(nc -ulnv 127.0.0.1 54321) &"
echo '> '$cmd
eval ${cmd}
server_pid=$!
echo 'SERVER PID:'$server_pid

echo -e '\n' 
echo '----------- tcpdump ----------- '
cmd="(tcpdump -i lo -tnlA 'udp and port 54321') &"
echo '> '$cmd
eval ${cmd}
tcpdump_pid=$!
echo 'TCPDUMP PID:'$tcpdump_pid
sleep 1

echo -e '\n' 
echo '----------- client start ----------- '
echo '入力してください。入力を停止して、3秒後に停止します。'
cmd="nc -u -w 3 127.0.0.1 54321"
echo '> '$cmd
eval ${cmd}
sleep 1

echo -e '\n' 
# ++++++++++++++ close ++++++++++++++
echo '============= background process kill ============= '
cmd="kill -9 "$tcpdump_pid
echo '> '$cmd
eval ${cmd}
cmd="kill -9 "$server_pid
echo '> '$cmd
eval ${cmd}


echo -e '\n\n' 
cat <<EOS
# +++++++++++++++++++++++++++++++++
# ++++++++++++++ TCP ++++++++++++++
# +++++++++++++++++++++++++++++++++
EOS
# ++++++++++++++ server&client start ++++++++++++++
echo '============= nc ============= '
echo '----------- server start ----------- '
# kオプションを追加、clientからの接続が切れても停止しない
cmd="(nc -lknv 127.0.0.1 54321) &"
echo '> '$cmd
eval ${cmd}
server_pid=$!
echo 'SERVER PID:'$server_pid

echo -e '\n' 
echo '----------- tcpdump ----------- '
cmd="(tcpdump -i lo -tnlA 'tcp and port 54321') &"
echo '> '$cmd
eval ${cmd}
tcpdump_pid=$!
echo 'TCPDUMP PID:'$tcpdump_pid
sleep 1

echo -e '\n' 
echo '----------- client start ----------- '
# 最初に接続した際に３つのセグメントのやり取りを行う。
# これをスリーハンドシェイクという
cat <<EOS
 three way handshake
   clitnt            server
     |                 |
     |------ SYN ----->| Flags[S]
     |<--- SYN/ACK ----| Flags[S.]
     |------ ACK ----->| Flags[. ] Connected!
     |                 |
     |                 |
Send |------ PSH ----->| Flags[P ]
     |<----- ACK ------| Flags[. ]
     |                 |
EOS
echo '入力してください。入力を停止して、3秒後に停止します。'
cmd="nc -w 3 127.0.0.1 54321"
echo '> '$cmd
eval ${cmd}
sleep 1

echo -e '\n' 
# ++++++++++++++ close ++++++++++++++
echo '============= background process kill ============= '
cmd="kill -9 "$tcpdump_pid
echo '> '$cmd
eval ${cmd}
cmd="kill -9 "$server_pid
echo '> '$cmd
eval ${cmd}

