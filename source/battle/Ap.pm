#===================================================================
#        AP行動取得パッケージ
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
package Ap;

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
    $self->{Datas}{Ap}  = StoreData->new();
    my $header_list = "";
   
    $header_list = [
                "ap_no",
                "action_type",
                "garden_id",
                "progress",
                "party_num",
                "enemy_num",
                "battle_result",
                "special_battle",
                "is_practice",
                "created_at",
    ];

    $self->{Datas}{Ap}->Init($header_list);
    
    #出力ファイル設定
    $self->{Datas}{Ap}->SetOutputName( "./output/battle/ap.csv" );
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
    my $ap_no  = shift;
    $self->{CreatedAt}  = shift;
    my $h2_subtitle_node = shift;
    my $div_frameareab_nodes = shift;
    my $h3_nodes = shift;
    my $b_csred_node = shift;
    
    $self->{ApNo} = $ap_no;

    $self->{PartyNum} = $self->GetPartyNum($div_frameareab_nodes);
    $self->{EnemyNum} = $self->GetEnemyNum($div_frameareab_nodes);
    $self->{SpecialBattle} = $self->GetSpecialBattleFlag($b_csred_node);
    $self->{BattleResult} = $self->GetBattleResult($h3_nodes, $div_frameareab_nodes);
    $self->GetApData($h2_subtitle_node);

    return;
}

#-----------------------------------#
#    味方人数取得
#------------------------------------
#    引数｜ターン別参加者一覧ノード
#-----------------------------------#
sub GetPartyNum{
    my $self  = shift;
    my $div_frameareab_nodes = shift;

    if (!scalar(@$div_frameareab_nodes)) {return 0;}

    my $party_num = 0;

    my $a_nodes = &GetNode::GetNode_Tag("a", \$$div_frameareab_nodes[0]);

    return scalar(@$a_nodes);
}

#-----------------------------------#
#    敵人数取得
#------------------------------------
#    引数｜ターン別参加者一覧ノード
#-----------------------------------#
sub GetEnemyNum{
    my $self  = shift;
    my $div_frameareab_nodes = shift;

    if (!scalar(@$div_frameareab_nodes)) {return 0;}
    
    my $td_nodes = &GetNode::GetNode_Tag("td", \$$div_frameareab_nodes[0]);

    if (scalar(@$td_nodes) < 2) {return 0;}

    my @td_child = $$td_nodes[1]->content_list;

    return scalar(@td_child)-1; 
}

#-----------------------------------#
#    特殊戦フラグ取得
#------------------------------------
#    引数｜ターン別参加者一覧ノード
#-----------------------------------#
sub GetSpecialBattleFlag{
    my $self  = shift;
    my $b_csred_node = shift;

    if (!$b_csred_node) {return 0;}

    if ($b_csred_node->as_text eq "魔物が集団で襲いかかってきた！！") {return 1;}
    
    return 0; 
}


#-----------------------------------#
#    勝敗取得
#------------------------------------
#    引数｜勝敗テキストノード
#-----------------------------------#
sub GetBattleResult{
    my $self  = shift;
    my $h3_nodes = shift;
    my $div_frameareab_nodes = shift;

    if (!scalar(@$div_frameareab_nodes)) {return -99;}
   
    my $b_nodes = &GetNode::GetNode_Tag("b", \$$div_frameareab_nodes[0]);

    if (scalar(@$b_nodes)) {
        if ($$b_nodes[0]->as_text eq "花壇の作業レポート！") {
            return -2;
        }
    }

    my $h3_battle_finish = ""; 
    foreach my $h3_node (reverse @$h3_nodes) {
        if ($h3_node->as_text eq "Battle Finish!") {
            $h3_battle_finish = $h3_node;
            last;
        }
    }

    if (!$h3_battle_finish) { return -99;}

    my $battle_finish_right = $h3_battle_finish->right;

    my $text = $battle_finish_right->as_text;

    if    ($text =~ /左チームの勝利/)     { return 1; }
    elsif ($text =~ /右チームの勝利/)     { return -1; }
    elsif ($text =~ /左チームの敗北/)     { return -1; }
    elsif ($text =~ /決着が/)             { return 0; }

    return -99;
}

#-----------------------------------#
#    サブタイトル、進行度取得
#------------------------------------
#    引数｜サブタイトルノード
#-----------------------------------#
sub GetApData{
    my $self  = shift;
    my $h2_subtitle_node  = shift;


    if (!$h2_subtitle_node) { return 0; }

    my $subtitle = $h2_subtitle_node->as_text;

    if ($subtitle =~ /　　作業結果！/) {
        my $garden_id = 10000;
        my $progress = -1;
        my $action_type = 0;

        $self->{Datas}{Ap}->AddData(join(ConstData::SPLIT, ($self->{ApNo}, $action_type, $garden_id, $progress, $self->{PartyNum}, $self->{EnemyNum}, $self->{BattleResult}, $self->{SpecialBattle}, 0, $self->{CreatedAt})));

    } elsif ($subtitle =~ /　　練習戦！/) {
        my $garden_id = 20000;
        my $progress = -1;
        my $action_type = 3;

        $self->{Datas}{Ap}->AddData(join(ConstData::SPLIT, ($self->{ApNo}, $action_type, $garden_id, $progress, $self->{PartyNum}, $self->{EnemyNum}, $self->{BattleResult}, $self->{SpecialBattle}, 0, $self->{CreatedAt})));

    } elsif ($subtitle =~ /　　(\d+)\.(.+) \[(.+)\]/) {
        my $garden_id = $1;
        my $title = $2;
        my $progress = $3;
        my $action_type = 1;
        my $is_practice = 0;
        if ($subtitle =~ /(練習)/) { $is_practice = 1; }

        if ($progress !~ /^[0-9]+$/) {
            $progress = -11;
            $action_type = 2;
        }

        $self->{CommonDatas}{GardenName}->SetId($garden_id, $title);
        $self->{Datas}{Ap}->AddData(join(ConstData::SPLIT, ($self->{ApNo}, $action_type, $garden_id, $progress, $self->{PartyNum}, $self->{EnemyNum}, $self->{BattleResult}, $self->{SpecialBattle}, $is_practice, $self->{CreatedAt})));
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
