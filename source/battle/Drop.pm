#===================================================================
#        ドロップ情報取得パッケージ
#-------------------------------------------------------------------
#            (C) 2018 @white_mns
#===================================================================


# パッケージの使用宣言    ---------------#   
use strict;
use warnings;
require "./source/lib/Store_Data.pm";
require "./source/lib/Store_HashData.pm";
require "./source/new/NewDrop.pm";
use ConstData;        #定数呼び出し
use source::lib::GetNode;

#------------------------------------------------------------------#
#    パッケージの定義
#------------------------------------------------------------------#     
package Drop;

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
    $self->{Datas}{Data}  = StoreData->new();
    $self->{Datas}{New}   = NewDrop->new();
    my $header_list = "";
   
    $header_list = [
                "ap_no",
                "drop_id",
    ];

    $self->{Datas}{Data}->Init($header_list);
    $self->{Datas}{New}->Init($self->{CommonDatas});
    
    #出力ファイル設定
    $self->{Datas}{Data}->SetOutputName( "./output/battle/drop.csv" );
    return;
}

#-----------------------------------#
#    データ取得
#------------------------------------
#    引数｜結果番号,ターン別参加者一覧ノード
#-----------------------------------#
sub GetData{
    my $self = shift;
    my $battle_no = shift;
    my $nodes = shift;
    
    $self->{ApNo} = $battle_no;

    my $drop_h4_node = $self->GetDropH4Node($nodes);
    $self->GetDropData($drop_h4_node);
    
    return;
}

#-----------------------------------#
#    『周囲の探索』ノード取得
#------------------------------------
#    引数｜ターン別参加者一覧ノード
#-----------------------------------#
sub GetDropH4Node{
    my $self  = shift;
    my $h4_nodes = shift;

    if (!scalar(@$h4_nodes)) {return;}

    foreach my $h4_node (@$h4_nodes) {
        if ($h4_node->as_text eq "周囲の探索") {
            return $h4_node;
        }
    }
}

#-----------------------------------#
#    ドロップデータ取得
#------------------------------------
#    引数｜ターン別参加者一覧ノード
#-----------------------------------#
sub GetDropData{
    my $self  = shift;
    my $h4_node = shift;

    if (!scalar($h4_node)) {return;}

    my @h4_rights = $h4_node->right;

    foreach my $h4_right (@h4_rights) {
        if ($h4_right !~ /HASH/ || $h4_right->tag ne "p") { next;}

        my $b_nodes = &GetNode::GetNode_Tag("b", \$h4_right);

        foreach my $b_node (@$b_nodes) {
            if ($b_node->as_text =~ /(.+) を獲得した！！/) {
                my $drop_id = $self->{CommonDatas}{ProperName}->GetOrAddId($1);
                $self->{Datas}{Data}->AddData(join(ConstData::SPLIT, ($self->{ApNo}, $drop_id) ));
    
                $self->{Datas}{New}->RecordNewDropData($self->{ApNo}, $drop_id);
            }
        }
    }

    return;
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
