#!/usr/bin/env Python3
"""Socketを利用したHTTPクライアント

本Scriptを実行する前にはHTTPサーバを起動する必要がある。
80ポートでHTTPサーバを起動
python -m http.server -b 127.0.0.1 80

※ network_socket_httpclient.shで本Scriptを呼び出している
  bash内にて上記コマンド実行
"""

import socket

def send_msg(sock, msg):
  """Socketに指定したバイト列を書き込む"""
  total_sent_len = 0
  total_msg_len = len(msg)

  while total_sent_len < total_msg_len:
    print('loop send_msg')
    sent_len = sock.send(msg[total_sent_len:])
    if sent_len == 0:
      raise RuntimeError('socket connection broken')
    total_sent_len += sent_len


def recv_msg(sock, chunk_len=1024):
  """Socketから接続が終わるまでバイト列を読み込む"""
  while True:
    print('loop recv_msg')
    received_chunk = sock.recv(chunk_len)
    if len(received_chunk) == 0:
      break
    yield received_chunk


def main():
  """メイン関数"""
  # connect
  client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
  client_socket.connect(('127.0.0.1', 80))
  # send
  request_text = 'GET / HTTP/1.0\r\n\r\n'
  request_bytes = request_text.encode('ASCII')
  send_msg(client_socket, request_bytes)
  # receive
  received_bytes = b''.join(recv_msg(client_socket))
  received_text = received_bytes.decode('ASCII')

  print(received_text)
  client_socket.close()


if __name__ == '__main__':
  main()
