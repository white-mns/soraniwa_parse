#===================================================================
#        新規獲得アイテム情報取得パッケージ
#-------------------------------------------------------------------
#            (C) 2019 @white_mns
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
package NewDrop;

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
sub Init{
    my $self = shift;
    ($self->{CommonDatas}) = @_;
    
    #初期化
    $self->{Datas}{NewDrop} = StoreData->new();
    $self->{Datas}{AllDrop} = StoreData->new();
    my $header_list = "";
   
    $header_list = [
                "ap_no",
                "drop_id",
    ];

    $self->{Datas}{NewDrop}->Init($header_list);
    $self->{Datas}{AllDrop}->Init($header_list);
    
    #出力ファイル設定
    $self->{Datas}{NewDrop}->SetOutputName( "./output/new/drop.csv" );
    $self->{Datas}{AllDrop}->SetOutputName( "./output/new/all_drop.csv" );
    
    $self->ReadLastNewData();

    return;
}

#-----------------------------------#
#    既存データを読み込む
#-----------------------------------#
sub ReadLastNewData(){
    my $self      = shift;
    
    my $file_name = "./output/new/all_drop.csv" ;
    
    #既存データの読み込み
    my $content = &IO::FileRead ( $file_name );
    
    my @file_data = split(/\n/, $content);
    shift (@file_data);
    
    foreach my  $data_set(@file_data){
        my $new_drop_datas = []; 
        @$new_drop_datas   = split(ConstData::SPLIT, $data_set);
        my $ap_no = $$new_drop_datas[0];
        my $drop_id = $$new_drop_datas[1];
        if(!exists($self->{AllDrop}{$drop_id})){
            $self->{AllDrop}{$drop_id} = [$ap_no, $drop_id];
        }
    }

    return;
}

#-----------------------------------#
#    新規獲得アイテムの判定と記録
#------------------------------------
#    引数｜アイテム名
#-----------------------------------#
sub RecordNewDropData{
    my $self    = shift;
    my $ap_no = shift;
    my $drop_id = shift;

    if (exists($self->{AllDrop}{$drop_id})) {return;}

    $self->{Datas}{NewDrop}->AddData(join(ConstData::SPLIT, ($ap_no, $drop_id) ));

    $self->{AllDrop}{$drop_id} = [$ap_no, $drop_id];

    return;
}
#-----------------------------------#
#    出力
#------------------------------------
#    引数｜
#-----------------------------------#
sub Output{
    my $self = shift;

    # 新出データ判定用の既出情報の書き出し
    foreach my $id (sort{$a cmp $b} keys %{ $self->{AllDrop} } ) {
        $self->{Datas}{AllDrop}->AddData(join(ConstData::SPLIT, @{ $self->{AllDrop}{$id} }));
    }
    
    foreach my $object( values %{ $self->{Datas} } ) {
        $object->Output();
    }
    return;
}
1;
