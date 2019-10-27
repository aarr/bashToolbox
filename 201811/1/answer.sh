#!/bin/bash
# 生徒一覧に対して、テストの結果一覧を紐付けて表示
# 
# join
# -a 1 : 1ファイル目を善行表示
# -e 0 : フィールドが存在しない場合、0を表示。
# -o 0 1.2 2.2 : 表示する列を指定。結合キー、１ファイル目の２項目目、２ファイル目の２項目目
cat scores.txt| awk '{$1=sprintf("%03d", $1); print}' | sort | join -a 1 -e 0 -o 0 1.2 2.2 students.txt - | column -t
