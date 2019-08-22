#===================================================================
#        設定スキル取得パッケージ
#-------------------------------------------------------------------
#            (C) 2019 @white_mns
#===================================================================


# パッケージの使用宣言    ---------------#   
use strict;
use warnings;
require "./source/lib/Store_Data.pm";
require "./source/lib/Store_HashData.pm";
require "./source/new/NewSkill.pm";
use ConstData;        #定数呼び出し
use source::lib::GetNode;


#------------------------------------------------------------------#
#    パッケージの定義
#------------------------------------------------------------------#     
package Skill;

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
    ($self->{Date}, $self->{CommonDatas}) = @_;
    
    #初期化
    $self->{Datas}{Data}  = StoreData->new();
    $self->{Datas}{New}   = NewSkill->new();
    my $header_list = "";
   
    $header_list = [
                "e_no",
                "set_no",
                "skill_type_id",
                "type_id",
                "nature_id",
                "skill_id",
                "name",
                "timing_id",
                "use_number",
                "created_at",
    ];

    $self->{Datas}{Data}->Init($header_list);
    $self->{Datas}{New}->Init($self->{Date}, $self->{CommonDatas});
    
    #出力ファイル設定
    $self->{Datas}{Data}->SetOutputName( "./output/chara/skill_" . $self->{Date} . ".csv" );
    return;
}

#-----------------------------------#
#    データ取得
#------------------------------------
#    引数｜e_no,サブキャラ番号,スキルテーブルノード
#-----------------------------------#
sub GetData{
    my $self    = shift;
    my $e_no    = shift;
    my $div_cdatal_node = shift;
    
    $self->{ENo} = $e_no;

    $self->GetSkillData($div_cdatal_node);
    
    return;
}
#-----------------------------------#
#    スキルデータ取得
#------------------------------------
#    引数｜スキルテーブルノード
#-----------------------------------#
sub GetSkillData{
    my $self  = shift;
    my $div_cdatal_node = shift;

    my $span_marks_marki0_nodes = &GetNode::GetNode_Tag_Attr("span", "class", "marks marki0",  \$div_cdatal_node);
    
    foreach my $node (@$span_marks_marki0_nodes) {
        my $skill_node = $node->right;
        my @skill_child_nodes = $skill_node->content_list;

        if (scalar(@skill_child_nodes)<2) {next;}

        if ($skill_node->attr("style") eq "color:#409020;") {
            $self->GetSkillData_detail($node);

        } else {
            $self->GetSkillData_simple($node);
        }
    }

    return;
}
#-----------------------------------#
#    スキルデータ取得(～20190812)
#------------------------------------
#    引数｜スキル設定番号ノード
#-----------------------------------#
sub GetSkillData_detail{
    my $self  = shift;
    my $node = shift;

    my ($set_no, $skill_type_id, $type_id, $nature_id, $skill_id, $name, $timing_id, $use_number) = (0, -1, 0, 0, 0, "", 0, 0);

    $set_no = $node->as_text;

    my @right_nodes = $node->right;
    my $skill_node = $right_nodes[0];
    my @skill_child_nodes = $skill_node->content_list;

    $type_id = $skill_child_nodes[0]->attr("class");
    $type_id =~ s/type//;

    my $nature = $skill_child_nodes[1];
    $nature =~ s/\[//;
    $nature =~ s/\]//;
    $nature_id = $self->{CommonDatas}{ProperName}->GetOrAddId($nature);

    my $skill_name = $right_nodes[1]->as_text;
    my $condition_text = $right_nodes[3]->as_text;

    if ($condition_text =~ /\((.+)\/(.+)回\)/) {
        my $timing = $1;
        $timing_id = $self->{CommonDatas}{ProperName}->GetOrAddId($timing);

        $use_number = $2;
        $use_number = ($use_number =~ /∞/) ? 9999 : $use_number;
    }

    my $skill_data_node = $right_nodes[5];
    my @skill_data_child = $skill_data_node->content_list;
    my ($skill_update, $cost_id, $text) = (0, 0, "");

    if (scalar(@skill_data_child) >= 3) {
        my $cost = $skill_data_child[1]->as_text;
        $cost =~ s/【//;
        $cost =~ s/】//;
        $cost_id = $self->{CommonDatas}{ProperName}->GetOrAddId($cost);

        $text = $skill_data_child[2]->as_text;
        if ($text =~ /\[/) {
            $skill_update = 1;
        }
    }
    
    if ($skill_name ne ""){
        $skill_id = $self->{CommonDatas}{SkillData}->GetOrAddId($skill_update, [$skill_name, $cost_id, $text]);
        $self->{Datas}{Data}->AddData(join(ConstData::SPLIT, ($self->{ENo}, $set_no, $skill_type_id, $type_id, $nature_id, $skill_id, $name, $timing_id, $use_number, $self->{Date}) ));

        $self->{Datas}{New}->RecordNewSkillData($self->{Date}, $skill_id);
    }

    return;
}

#-----------------------------------#
#    スキルデータ取得(～20190812)
#------------------------------------
#    引数｜スキル設定番号ノード
#-----------------------------------#
sub GetSkillData_simple{
    my $self  = shift;
    my $node = shift;

    my ($set_no, $skill_type_id, $type_id, $nature_id, $skill_id, $name, $timing_id) = (0, -1, 0, 0, 0, "", 0);

    $set_no = $node->as_text;

    my $skill_node = $node->right;
    my @skill_child_nodes = $skill_node->content_list;

    $type_id = $skill_child_nodes[0]->attr("class");
    $type_id =~ s/type//;

    my $text_node = $skill_node->right;
    my $b_nodes = &GetNode::GetNode_Tag("b",  \$text_node);
    if (scalar(@$b_nodes)) {
        my $timing = $$b_nodes[0]->as_text;
        $timing =~ s/: //g;
        $timing_id = $self->{CommonDatas}{ProperName}->GetOrAddId($timing);
    }

    my $text_span_nodes = &GetNode::GetNode_Tag("span",  \$text_node);
    my $text = "";
    if (scalar(@$b_nodes)) {
        $text = $$text_span_nodes[0]->as_text;
    }

    $skill_id = $self->{CommonDatas}{SkillData}->GetOrAddId(0, [$skill_child_nodes[1], 0, $text]);

    $self->{Datas}{Data}->AddData(join(ConstData::SPLIT, ($self->{ENo}, $set_no, $skill_type_id, $type_id, $nature_id, $skill_id, $name, $timing_id, 0, $self->{Date}) ));

    $self->{Datas}{New}->RecordNewSkillData($self->{Date}, $skill_id);

    return;
}

#-----------------------------------#
#    出力
#------------------------------------
#    引数｜
#-----------------------------------#
sub Output{
    my $self = shift;
    
    foreach my $object( values %{ $self->{Datas} } ) {
        $object->Output();
    }
    return;
}
1;
