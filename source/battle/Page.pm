#===================================================================
#        ページ情報取得パッケージ
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
package Page;

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
    $self->{Datas}{Page}  = StoreData->new();
    my $header_list = "";
   
    $header_list = [
                "result_no",
                "generate_no",
                "battle_no",
                "story_id",
                "page_no",
                "party_num",
                "enemy_num",
                "battle_result",
    ];

    $self->{Datas}{Page}->Init($header_list);
    
    #出力ファイル設定
    $self->{Datas}{Page}->SetOutputName( "./output/battle/page.csv" );
    return;
}

#-----------------------------------#
#    データ取得
#------------------------------------
#    引数｜結果番号
#          ターン別参加者一覧ノード
#          タイトルデータノード
#-----------------------------------#
sub GetData{
    my $self = shift;
    my $battle_no  = shift;
    my $table_nodes = shift;
    my $b_node = shift;
    my $td_node = shift;
    
    $self->{BattleNo} = $battle_no;

    $self->{PartyNum} = $self->GetPartyNum($table_nodes);
    $self->{EnemyNum} = $self->GetEnemyNum($table_nodes);
    $self->{BattleResult} = $self->GetBattleResult($table_nodes, $td_node);
    $self->GetPageData($b_node);
    
    return;
}

#-----------------------------------#
#    味方人数取得
#------------------------------------
#    引数｜ターン別参加者一覧ノード
#-----------------------------------#
sub GetPartyNum{
    my $self  = shift;
    my $turn_table_nodes = shift;

    if (!scalar(@$turn_table_nodes)) {return 0;}

    my $party_num = 0;

    my $a_nodes = &GetNode::GetNode_Tag("a", \$$turn_table_nodes[0]);

    foreach my $a_node (@$a_nodes) {
        $party_num += 1;
    }

    return $party_num;
}

#-----------------------------------#
#    敵人数取得
#------------------------------------
#    引数｜ターン別参加者一覧ノード
#-----------------------------------#
sub GetEnemyNum{
    my $self  = shift;
    my $turn_table_nodes = shift;

    if (!scalar(@$turn_table_nodes)) {return 0;}

    my $enemy_num = 0;

    my $enemy_table = $$turn_table_nodes[1];

    if (!$enemy_table) { # バグによる開始時無抵抗敗北の結果に対応
        $enemy_table = $$turn_table_nodes[0];
    }

    my $tr_nodes = &GetNode::GetNode_Tag("tr", \$enemy_table);

    return scalar(@$tr_nodes) - 1;
}

#-----------------------------------#
#    勝敗取得
#------------------------------------
#    引数｜勝敗テキストノード
#-----------------------------------#
sub GetBattleResult{
    my $self  = shift;
    my $turn_table_nodes = shift;
    my $t6i_td_nodes = shift;

    if (!scalar(@$turn_table_nodes)) {return -99;}
   
    my $last_table = ""; 
    foreach my $table (reverse @$turn_table_nodes) {
        if ($table) {
            $last_table = $table;
            last;
        }
    }

    if (!$last_table) { return -99;}
    my @last_table_lefts = $last_table->left;
    my $last_table_left  = $last_table_lefts[scalar(@last_table_lefts)-1]; # バグによる開始時無抵抗敗北の結果に対応

    my $text = $last_table_left->as_text;

    if    ($text =~ /勝利/)     { return 1;}
    elsif ($text =~ /敗北/)     { return -1;}
    elsif ($text =~ /決着が/)   { return 0;}

    if (!scalar($t6i_td_nodes)) { return -99;}

    if ($$t6i_td_nodes[0]->as_text =~ /決着が/) { return 0;}

    return -99;
}

#-----------------------------------#
#    タイトル、進行度取得
#------------------------------------
#    引数｜名前データノード
#-----------------------------------#
sub GetPageData{
    my $self  = shift;
    my $b_node  = shift;

    my @children = $b_node->content_list;

    my $story = $children[0]->as_text;
    my $title = $children[1];
    $title =~ s/[=\s]//g;

    if ($story =~ /StoryNo\.(\d+) \[(\d+)\/(\d+)\]/) {
        my $story_no = $1;
        my $page_no = $2;
        my $max_page = $3;

        $self->{CommonDatas}{StoryData}->GetOrAddId(1, $story_no, [$title, $max_page]);
        $self->{Datas}{Page}->AddData(join(ConstData::SPLIT, ($self->{ResultNo}, $self->{GenerateNo}, $self->{BattleNo}, $story_no, $page_no, $self->{PartyNum}, $self->{EnemyNum}, $self->{BattleResult})));
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
