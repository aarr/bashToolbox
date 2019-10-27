#!/bin/bash

# ++++++++++++ 位置変数 ++++++++++++
# $1〜nまでコマンド、シェルの実行の引数が指定順に格納される
echo '=========  args ========='
echo "第一引数："$1
echo "第二引数："$2

# >変数
# 変数名は大文字、小文字を区別する
# 変数への設定は=で行う、左右にスペースを含めてはならない
# $変数 or ${変数}:明示的に指定。hoge=123; echo ${hoge}1とすれば、1231となる
var1=123
ans=Yes

# ++++++++++++ 分岐（if） ++++++++++++
# if condition
# then
#   process1
# else
#   process2
# fi
# 条件式はコマンドの終了ステータスによって判断される。0ならtrue、それ以外でfalse。
# 条件部でよく利用されるのは、testコマンド。
# test arg -eq 1
# -> [ $arg -eq 1 ] と書き換えることも可能。式の前後にスペースを入れる必要あり。
# 数値系： eq : equal, ne : not equal, lt : less than, gt : greater than
# 文字列系： = : equal, != : not equal, -z : 0 more charactor, -n : 1 more charactor
# ファイル系： -f : file, -d : directory, -s : file and size is not equal 0
echo '=========  if ========='
if test $var1 -eq 1
then
  echo "var1 equal 1"
# []で式を記載
elif [ $var1 -eq 12 ]
then
  echo "var1 equal 12"
# 条件式１行
elif [ ${var1}1 -eq 1231 ]; then
  echo "var1 equal 123"
else
  echo "var1 is not 1, 12, 123"
fi

# ++++++++++++ 分岐（case） ++++++++++++
# case val in
#   pattern1 ) process1;;
#   pattern2 ) process2;;
# esac
# 特徴としてpattern記載時に、シェルによるパターン（glob）が利用できる（if文では利用できない）
# 正規表現のようなもの
echo '=========  case ========='
case $ans in
  y* | Y* ) echo "answer is yes";;
  n* | N* ) echo "answer is no";;
  * ) echo "answer is not yes/no";;
esac


# ++++++++++++ 分岐（&& ||） ++++++++++++
# ifの代わりに利用することが可能
echo '=========  && || ========='
test $var1 -eq 1 && echo "&& -> not display"
test $var1 -eq 123 && echo "&& -> display"
test $var1 -eq 1 || echo "|| -> display"
test $var1 -eq 123 || echo "|| -> not sample"

# ++++++++++++ 繰り返し（while） ++++++++++++
# while condition
# do
#   process
# done
# 条件部はif文と同じ
# continue, breakが利用可能
echo '========= while ========='
echo "while sample" | while read line
do
  echo $line
done


# ++++++++++++ 繰り返し（for） ++++++++++++
# for arg in list
# do
#   process
# done
# * : all file and directory in current directory. list部でfor文などで利用可能
echo '=========  for ========='
for name in *
do
  echo $name
done

# ++++++++++++ その他 ++++++++++++
# 時間
#  unix時間へ変換。時間の範囲していなどで重宝する
#  date "+%s" 
echo '=========  other ========='
echo '>unix time'
echo $(date "+%s")

# ++++++++++++ 終了ステータス ++++++++++++
# $?に格納される。0：正常終了、1：異常終了（返却される値はスクリプト側で設定は可能0〜255の範囲内）
echo '=========  return ========='
echo "$?返却値（255）を取得可能"
return 255 




