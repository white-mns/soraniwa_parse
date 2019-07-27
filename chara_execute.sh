#!/bin/bash

CURENT=`pwd`	#実行ディレクトリの保存
cd `dirname $0`	#解析コードのあるディレクトリで作業をする

if [ -n "$1" ]; then
    if [ "`date +'%Y%m%d' -d $1 2> /dev/null`" = $1 ]; then
        DATE=`date +"%Y%m%d" -d $1`
    else
        DATE=`date +"%Y%m%d"`
    fi
else
    DATE=`date +"%Y%m%d"`
fi

perl ./GetCharaData.pl $DATE
perl ./UploadChara.pl $DATE

cd $CURENT  #元のディレクトリに戻る

#!/bin/bash

CURENT=`pwd`	#実行ディレクトリの保存
cd `dirname $0`	#解析コードのあるディレクトリで作業をする
