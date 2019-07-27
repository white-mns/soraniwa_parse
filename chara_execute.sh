#!/bin/bash

CURENT=`pwd`	#実行ディレクトリの保存
cd `dirname $0`	#解析コードのあるディレクトリで作業をする

if [ "`date +'%Y%m%d' -d $1 2> /dev/null`" == $1 ]; then
    DATE=`date +"%Y%m%d" -d $1`
else
    DATE=`date +"%Y%m%d"`
fi

echo $DATE

perl ./GetCharaData.pl $DATE
perl ./UploadParentChara.pl $DATE

cd $CURENT  #元のディレクトリに戻る

#!/bin/bash

CURENT=`pwd`	#実行ディレクトリの保存
cd `dirname $0`	#解析コードのあるディレクトリで作業をする
