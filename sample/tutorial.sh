#!/bin/bash
# Unixではファイル先頭行に#!（シェバン$）がある場合、その直後に記載されているコマンドを実行する
# 今回の定義は/bin/bashを実行する定義となる。bash tutorial.shとしなくても、tutorial.shだけの実行でbash実行となる。
# 
# ========================================================
# 引数は２つ指定
# 参考URL
# https://qiita.com/m-yamashita/items/889c116b92dc0bf4ea7d
# ========================================================
# ++++++++++++ エラー時制御 ++++++++++++
# set -e : エラーが発生した場合、処理中断 
# set -u : 未定義の変数がある場合、処理中断
# set -x : xtrace。変数の状態をデバック出力。実行時にbash -x tutorial.shと指定することも可能
# set -v : verbose。コマンドをデバック取得。実行時にbash -v tutorial.shと指定するも可能
# またbash -n tutorial.shとするとコマンドの実行はされず構文のみチェック可能（noexecオプション）
set -euxv
echo '=========  set ========='
echo "設定：エラー時、変数未定義時に処理中断。実行時引数が２つ必要。"

# ++++++++++++ 位置変数 ++++++++++++
# $1〜nまでコマンド、シェルの実行の引数が指定順に格納される
# $#は引数の数
echo;echo '=========  args ========='
echo "引数数："$#
# 3つ異常引数が設定されている場合にエラーを発生させる（set -eの確認）
if test $# -gt 2; then
  undefinedCommand
fi

echo "第一引数："$1
# 引数を１つシフトする。:$1だけど2つめの引数
shift
echo "第二引数："$1

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
echo;echo '=========  if ========='
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
echo;echo '=========  case ========='
case $ans in
  y* | Y* ) echo "answer is yes";;
  n* | N* ) echo "answer is no";;
  * ) echo "answer is not yes/no";;
esac


# ++++++++++++ 分岐（&& ||） ++++++++++++
# ifの代わりに利用することが可能
echo;echo '=========  && || ========='
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
echo;echo '========= while ========='
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
echo;echo '=========  for ========='
for name in *
do
  echo $name
done


# ++++++++++++ 展開 ++++++++++++
# {} 変数の展開／一連のコマンドカレントシェル実行／プレース展開
# どの文字までが変数なのか定義しなければならない場合に利用
echo;echo '----- Braces{}：変数の展開 -----'
echo "Braces{} Sample1："${var1}1


# 一覧のコマンドをカレント実行
# {}の前後にSpaceが必要。コマンドの最後を;を記載する必要あり。
echo;echo '----- Braces{}：カレントシェル実行 -----'
currentDirectory=$(pwd)
time -p { sleep 0.1; sleep 0.5; echo "Braces{} Sample2"; cd ../; }
# カレントシェルなので、コマンド内のcdが呼び出し元スクリプトに影響あり
pwd
cd $currentDirectory
echo


# プレース展開
echo;echo '----- Braces{}：プレース展開 -----'
# {n..m}はn〜mを寛解
echo Braces{} Sample3-1：
for arg in Sample{1..5}; do echo $arg; done;
echo Braces{} Sample3-2：
for arg in Sample{1..5..2}; do echo $arg; done;
echo Braces{} Sample3-3：
for arg in Sample{One,Two,Three}; do echo $arg; done;
# {a,b}はカンマ区切りされた内容を展開k
echo "Braces{} Sample3-4：mv" Sample3{,_bk}.txt
# パス展開
# []：括弧内に含まれる文字列に一致する
# ?：任意の位置文字に一致する
echo "Braces{} Sample3-5："
touch testfile_{1..10}.txt
ls testfile_[13].txt
ls testfile_??.txt
rm -rf testfile_{1..10}.txt
echo


# () subShellの実行
# 別プロセスで起動されるため、コマンド内のcdがk呼び出し元のスクリプトに何も影響を及ぼさない
echo;echo '----- Parentheses()：subShellの実行 -----'
echo "Parentheses() Sample1："
echo $(cd ../; pwd)
pwd
# コマンドの結果を別コマンドの引数として渡すことが可能 
echo;echo '----- Parentheses()：command実行＆別コマンド引数渡し -----'
echo "Parentheses() Sample2："
diff <(echo hogehoge) <(echo fugafuga) | cat  


# (()) 算術展開
echo;echo '----- DoubleParentheses(())：算術実行 -----'
echo "DoubleParentheses(())："$((1+10))


# [] testコマンドの略式
echo;echo '----- Bracket[]：testコマンドの略式 -----'
echo $(if [ 1 -eq 1 ]; then echo "Bracket[] Sample"; fi)


# [[]] SingleBracketの拡張
# &&, ||, 正規表現などが利用可能
echo;echo  '----- DoubleBracket[[]]：Singleの拡張版 -----'
echo $(if [[ 1 -eq 1 && abc == a* ]]; then echo "DoubleBracket[[]] Sample"; fi)


# ++++++++++++ 関数 ++++++++++++
# 関数名(){ コマンドの列挙 }
# 1行で記載する場合は、{,}の後、前にスペースが必要。またコマンド毎に;も必要
echo;echo  '----- 関数 -----'
echo  'defined function'
sampleFunc(){
  echo  'called function : '$1
  return 0;
}
echo 'call function'
sampleFunc 'sample function'


# ++++++++++++ その他 ++++++++++++
# ----- 時間 -----
#  unix時間へ変換。時間の範囲していなどで重宝する
#  date "+%s" 
echo;echo '=========  other ========='
echo '----- unix time -----'
echo $(date "+%s")


# ----- プロンプトメッセージ設定 -----
# PS1に設定する
# \n : 改行
# \u : ログイン名
# \h : ホスト名
# \w : カレントディレクトリ
# \$ : ルートの場合#、それ以外は#
# 下記が現状と同じ設定
echo '----- change prompt message -----'
PS1='\u@\h:\w\$ '


# ----- プロンプトメッセージ設定 -----
# login shell : /etc/profile, ~/.profile
#              -> 環境変数などを定義するのがよい
# other       : /etc/bashrc, ~/.bashrc
#              -> promptや関数の設定をするのがよい


# ++++++++++++ 終了ステータス ++++++++++++
# $?に格納される。0：正常終了、1：異常終了（返却される値はスクリプト側で設定は可能0〜255の範囲内）
echo;echo '=========  return ========='
echo "\$?返却値（255）を取得可能"
exit 255 

