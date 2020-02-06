#!/bin/bash

echo '============================================='
echo ' USED MEMORY TOP10 BY PROCESS'
echo '============================================='
set -v
# tr -s ' ' ' ' -> 第１引数の文字複数を、第２引数に置き換える
# sort -n:bunber, -r:reverse -k colNum:column number
column -t <(ps -aux | head -1 | tr -s ' ' ' ' | cut -d ' ' -f 2,3,4,6,11) <(ps -aux | tail -n +2 | tr -s ' ' ' ' | cut -d ' ' -f 2,3,4,6,11 | sort -n -r -k 4 | head -10)
set +v

