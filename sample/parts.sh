#!/bin/bash

echo '============================================='
echo ' USED MEMORY TOP10 BY PROCESS'
echo '============================================='
set -v
# tr -s ' ' ' ' -> 第１引数の文字複数を、第２引数に置き換える
# sort -n:bunber, -r:reverse -k colNum:column number
column -t <(ps -aux | head -1 | tr -s ' ' ' ' | cut -d ' ' -f 2,3,4,6,11) <(ps -aux | tail -n +2 | tr -s ' ' ' ' | cut -d ' ' -f 2,3,4,6,11 | sort -n -r -k 4 | head -10)
set +v

echo -e '\n\n' 
echo '============================================='
echo ' CoProcess Sample'
echo '============================================='
set -v
# CoProcess
# コプロセスへのstdin/stdoutなどを取得可能
coproc MY {
  read line
  echo "$line, guest!"
  sleep 1
  echo "hello"
  sleep 1
}

echo ${MY[@]}
echo "hello" >&${MY[1]}
cat - <&${MY[0]}
wait

set +v
