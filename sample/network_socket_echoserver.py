#!/usr/bin/env Python3
"""Socketを利用したEchoサーバ

本Scriptを実行してから、ncコマンドでサーバに接続し動作確認を行う

nc 127.0.0.1 54321
Hello, World!
"""

import socket


def send_msg(sock, msg):
  """Socketに指定したバイト列を書き込む関数"""
  total_sent_len = 0
  total_msg_len = len(msg)

  while total_sent_len < total_msg_len:
      sent_len = sock.send(msg[total_sent_len:])
      if sent_len == 0:
        raise RuntimeError('socket connection broken')
      total_sent_len += sent_len


def recv_msg(sock, chunk_len=1024):
  """Socketから接続が終わるまでバイト列を読み込むジェネレータ関数"""
  try:
    while True:
      received_chunk = sock.recv(chunk_len)
      if len(received_chunk) == 0:
        break
      yield received_chunk
  except KeyboardInterrupt as error:
    print('finished...')


def main():
  """スクリプトとして実行されたときに呼び出されるメイン関数"""
  # IPv4/TCPで通信するソケットを用意する
  server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
  # Address already in use の回避
  server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, True)
  server_socket.bind(('127.0.0.1', 54321))
  server_socket.listen()
  print('starting server ...')

  client_socket, (client_address, client_port) = server_socket.accept()
  print(f'accepted from {client_address}:{client_port}')
  for received_msg in recv_msg(client_socket):
    send_msg(client_socket, received_msg)
    print(f'echo: {received_msg}')

  client_socket.close()
  server_socket.close()


if __name__ == '__main__':
  main()

