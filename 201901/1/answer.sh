#!/bin/bash
# 2019年10月以降で、名称が*始まり以外の項目は消費税が10%、それ以外は1.08として家計簿の合計を算出する

# 回答１
cat kakeibo.txt | awk 'BEGIN{sum = 0} {if($1 >= 20191001 && $2 ~ /^[^\*].*/) sum = sum + $3 * 1.1; else sum = sum + $3*1.08;} END{print sum}'

# 回答２
# num-utilsのinstallが必要（numsum）
# cat kakeibo.txt | awk '{if($1 >= 20191001 && $2 ~ /^[^\*].*/) print $3 * 1.1; else print $3*1.08;}' | numsum

