#===================================================================
#        敵情報取得パッケージ
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
package Enemy;

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
    my $header_list = "";
   
    $header_list = [
                "ap_no",
                "enemy_id",
                "suffix_id",
    ];

    $self->{Datas}{Data}->Init($header_list);
    
    #出力ファイル設定
    $self->{Datas}{Data}->SetOutputName( "./output/battle/enemy.csv" );
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

    $self->GetEnemyData($nodes);
    
    return;
}

#-----------------------------------#
#    敵データ取得
#------------------------------------
#    引数｜ターン別参加者一覧ノード
#-----------------------------------#
sub GetEnemyData{
    my $self  = shift;
    my $div_frameareab_nodes = shift;
    my $party_order = 0;

    if (!scalar(@$div_frameareab_nodes)) {return;}

    my $td_nodes = &GetNode::GetNode_Tag("td", \$$div_frameareab_nodes[0]);

    if (!scalar(@$td_nodes)) {return;}

    my $a_nodes = &GetNode::GetNode_Tag("a", \$$td_nodes[1]);

    if (scalar(@$a_nodes)) { return;} # 練習戦で右側PTをエネミーとして取得しない

    my @td_child = $$td_nodes[1]->content_list;

    foreach my $div_node (@td_child) {
        if ($div_node !~ /HASH/) { next; }
        my @div_child = $div_node->content_list;

        if (scalar(@div_child) < 2) { next; }

        my @div_child_child = $div_child[1]->content_list;

        if (scalar(@div_child_child) < 3) { next; }

        my $enemy_name = $div_child_child[0];
        my $suffix_id = 0;
        if ($enemy_name =~ s/([A-Z]+)$//) {
            $suffix_id = $self->{CommonDatas}{ProperName}->GetOrAddId($1);
        };

        my $line_node = $div_child_child[1];
        my $line_id = -1;

        if ($line_node->as_text =~ /前/) {
            $line_id = 0;
        } elsif ($line_node->as_text =~ /後/) {
            $line_id = 1;
        }

        my $type_node = $div_child_child[3];
        my $type_id = 0;

        if ($type_node->attr("class") =~ /type(\d+)/) {
            $type_id = $1;
        }

        my $enemy_id = $self->{CommonDatas}{EnemyData}->GetOrAddId(1, [$enemy_name, $line_id, $type_id]);

        $self->{Datas}{Data}->AddData(join(ConstData::SPLIT, ($self->{ApNo}, $enemy_id, $suffix_id) ));

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
