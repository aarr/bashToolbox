#!/bin/bash
# store_master.txtに各商品のID、枝番、金額情報があり、sale.txtで売上情報がある。売上情報を商品ごとに集計して表示する
#
# 最初のawkで連想配列を利用a[]。ENDにて集計を行う
# <() にてもう１ファイルの操作を行い、joinにて結合するk
awk '{a[$3"-"$4]+=$5} END {for(i in a) print i,a[i]}' ./sale.txt | sort |  join -a 1 -e 0 -o 0 1.2 1.3 2.2 <(awk '{print $1"-"$2,$3,$4}' ./store_master.txt | sort) - | awk '{print $1,$2,$3,$4,$3*$4}' | sed s/-/" "/g | column -t

