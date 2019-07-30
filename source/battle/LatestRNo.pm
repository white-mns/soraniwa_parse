#===================================================================
#        最終取得結果番号取得パッケージ
#-------------------------------------------------------------------
#            (C) 2018 @white_mns
#===================================================================


# パッケージの使用宣言    ---------------#   
use strict;
use warnings;
require "./source/lib/Store_Data.pm";
require "./source/lib/Store_HashData.pm";
use ConstData;        #定数呼び出し
use source::lib::GetNode;


#------------------------------------------------------------------#
#    パッケージの定義
#------------------------------------------------------------------#     
package LatestRNo;

#-----------------------------------#
#    コンストラクタ
#-----------------------------------#
sub new {
  my $class = shift;
  
  bless {
        Datas => {},
  }, $class;
}

#-----------------------------------#
#    初期化
#-----------------------------------#
sub Init(){
    my $self = shift;
    ($self->{CommonDatas}) = @_;

    #初期化
    $self->{LatestRNo} = 1;
    $self->{Datas}{LatestRNo}  = StoreData->new();
    my $header_list = "";
   
    $header_list = [
                "latest_r_no",
    ];

    $self->{Datas}{LatestRNo}->Init($header_list);
    
    #出力ファイル設定
    $self->{Datas}{LatestRNo}->SetOutputName( "./output/battle/latest_r_no.csv" );

    $self->ReadLatestData();
    return;
}

#-----------------------------------#
#    最終データを読み込む
#-----------------------------------#
sub ReadLatestData(){
    my $self      = shift;
    
    my $file_name = "./output/battle/latest_r_no.csv";
    
    #既存データの読み込み
    my $content = &IO::FileRead ( $file_name );
    
    my @file_data = split(/\n/, $content);
    shift (@file_data);
    
    foreach my  $data_set(@file_data){
        my $latest_datas = []; 
        @$latest_datas   = split(ConstData::SPLIT, $data_set);

        $self->{LatestRNo} = $$latest_datas[0] + 1;

    }

    return;
}

#-----------------------------------#
#    データ入力
#------------------------------------
#    引数｜結果番号
#          ターン別参加者一覧ノード
#          タイトルデータノード
#-----------------------------------#
sub SetLatestRNo{
    my $self = shift;
    my $latest_r_no  = shift;
    
    $self->{LatestRNo} = $latest_r_no;
    
    $self->{Datas}{LatestRNo}->AddData(join(ConstData::SPLIT, ($self->{LatestRNo})));
    
    return;
}

#-----------------------------------#
#    データ取得
#------------------------------------
#    引数｜結果番号
#          ターン別参加者一覧ノード
#          タイトルデータノード
#-----------------------------------#
sub GetLatestRNo{
    my $self = shift;

    return $self->{LatestRNo};
}

#-----------------------------------#
#    出力
#------------------------------------
#    引数｜ファイルアドレス
#-----------------------------------#
sub Output(){
    my $self = shift;
    
    foreach my $object( values %{ $self->{Datas} } ) {
        $object->Output();
    }
    return;
}
1;
